# Design decisions

Why the project is built the way it is. Each entry records the choice, the
alternatives that were weighed, and what would justify revisiting it.

---

## 1. Flutter, targeting Linux desktop

**Choice.** Flutter 3.44.8, GTK embedder, Linux only for now.

**Why.** A paint program is one big custom-drawn surface with a conventional
chrome around it. Flutter gives a retained-mode scene graph, a real `Canvas`
API and GPU compositing without hand-writing a renderer, and its widget set
covers the chrome. The alternatives each cost more: GTK4 + Cairo means writing
every control's styling by hand; Qt means a heavier toolchain and licence
questions; Electron means shipping a browser to draw rectangles.

**Cost.** A ~25 MB bundle and a runtime dependency on the Flutter engine. For a
desktop application installed once, that is acceptable.

**Revisit if.** The engine's input latency ever becomes the limiting factor for
freehand drawing. It is not today.

---

## 2. Single-layer raster for v1, with the layer list already in place

**Choice.** `PaintDocument` holds a `List<Layer>` that always has exactly one
entry, and the UI has no layers panel.

**Why.** Classic Paint has no layers, and the whole point of this editor is that
it is simple. But retrofitting layers into a document that hard-codes a single
bitmap means touching the model, the history and every image operation. Carrying
the list from the start costs about forty lines and makes layers an additive
change to the UI later.

**Revisit.** M2, together with a native `.paintproj` format — layers that cannot
be saved are a trap.

---

## 3. Preview and commit share one `draw` method

**Choice.** `ToolGesture.draw(Canvas)` is called both to render the live preview
each frame and once more when the gesture is committed to the bitmap.

**Why.** The obvious alternative — a preview painter plus a separate commit path
— has two implementations of the same drawing and they drift. The user then sees
one thing while dragging and gets another on release, which is the single most
irritating bug class in a drawing program. Sharing the method makes that
impossible by construction.

**Cost.** The gesture must also declare its `bounds`, and a tool that
under-reports them gets its edit clipped. The commit clips to the declared
bounds deliberately, so an under-reporting tool fails visibly during development
rather than silently corrupting the undo history.

---

## 4. Strokes are not rasterised while dragging

**Choice.** The in-progress stroke is drawn as a preview over the bitmap and
only baked in on pointer-up.

**Why.** Rasterising on every pointer-move means a full-canvas
`Picture.toImage()` per event. On a 4000×3000 image that is ~48 MB of texture
work per move — unusable. Drawing the preview on top is free.

---

## 5. Undo is bounded by memory, not by a step count

**Choice.** `History` evicts oldest-first to stay under a byte budget (512 MB by
default). Drawing tools store only the dirty rectangle; whole-canvas operations
store full snapshots.

**Why.** A step count is the wrong unit: 50 steps is nothing on a 200×200
sprite and is several gigabytes on a large photograph. A memory budget gives a
very deep history exactly when entries are cheap, which matches what people
actually want, and it cannot OOM the process.

**Detail.** The newest entry is never evicted, even if it alone exceeds the
budget — being unable to undo the change you just made is worse than briefly
exceeding a soft limit.

---

## 6. `pasteboard` for the clipboard, not `super_clipboard`

**Choice.** `pasteboard` ^0.5.0.

**Why.** `super_clipboard` is the richer package, but it depends on
`super_native_extensions`, which builds through Cargokit and therefore needs a
**Rust toolchain in CI**. That is a large, slow dependency for one feature.
`pasteboard` ships a plain C++/GTK plugin and covers reading and writing images,
which is all that is needed.

**Revisit if.** Rich-text or multi-format clipboard payloads are ever needed.

---

## 7. Pixel operations work in straight alpha

**Choice.** `ImageUtils.toStraightRgbaBytes` / `fromStraightRgbaBytes` convert at
the boundary; everything in `ops/` sees non-premultiplied RGBA.

**Why.** The engine stores premultiplied alpha, where a 50%-transparent red is
`(128, 0, 0, 128)`. Users — and the tolerance arithmetic in the flood fill —
reason in straight alpha, where it is `(255, 0, 0, 128)`. Doing the conversion
once at the boundary keeps every operation in the space where its logic reads
correctly.

**Cost.** One pass over the buffer in each direction, and a rounding error of at
most one level per channel at low alpha.

---

## 8. Edits are serialised through a promise chain

**Choice.** Every mutation goes through `DocumentController._serialize`.

**Why.** Rasterising is asynchronous. Two commits started close together would
both read the same bitmap and the second would overwrite the first, silently
losing a stroke. Queueing is a handful of lines and removes the whole class of
bug.

---

## 9. An in-app menu bar rather than a native GTK one

**Choice.** Flutter's `MenuBar`, drawn inside the window.

**Why.** Flutter's `PlatformMenuBar` has no Linux backend, so a native menu would
mean a custom platform channel and hand-written GTK menu construction. The
in-app menu also keeps the sober theme consistent across the entire window.

**Cost.** The menu does not integrate with a global menu bar on desktops that
have one.

---

## 10. The release baseline is glibc 2.35

**Choice.** Release binaries are built inside an `ubuntu:22.04` container even
though CI runs on a newer runner.

**Why.** A binary built on Ubuntu 24.04 requires glibc 2.39 and simply will not
start on Ubuntu 22.04 or Debian 12 — which between them are most of the installed
base. Building against the older glibc runs everywhere from 22.04 upwards. It
also means `dpkg-shlibdeps` produces the pre-`t64` package names that those
releases actually ship.

**Cost.** The release job installs its toolchain into a bare container on every
run, about a minute.

---

## 11. A self-hosted APT repository, not a Launchpad PPA

**Choice.** A signed repository generated by `apt-ftparchive` and served from
GitHub Pages.

**Why.** It was the only option that is fully automatic from a git tag and works
on **both** Debian and Ubuntu. A PPA is more familiar to Ubuntu users, but
Launchpad's builders have no network access, so the Flutter SDK *and* the entire
pub cache — around a gigabyte — would have to be vendored into the source
tarball, and a separate build maintained per Ubuntu series.

**Cost.** Users add a keyring and a sources file by hand rather than running
`add-apt-repository`. The published `paint.sources` file makes that two commands.

**Alternatives kept open.** Snap (Snapcraft has an official Flutter extension and
is the easiest *store* route), Flatpak (best cross-distro reach, but the SDK must
be vendored in the manifest), and a PPA. All are documented in
[PACKAGING.md](PACKAGING.md).

---

## 12. Runtime dependencies are computed, never written by hand

**Choice.** `packaging/build_deb.sh` runs `dpkg-shlibdeps` over the binary and
the bundled engine libraries.

**Why.** A hand-written `Depends:` line is correct on the day it is written and
wrong after the next engine upgrade. Computing it means the package is right by
construction. A conservative fallback list exists only for building on a
non-Debian host.

---

## 13. Internationalization before it is needed

**Choice.** Every user-visible string goes through ARB files and
`AppLocalizations`, with English as the only locale, plus a CI check that fails
on hardcoded literals.

**Why.** Retrofitting i18n means auditing the entire UI by hand. Doing it up
front costs one indirection per string and makes a new language a matter of
dropping in one file. The CI check is what stops the discipline eroding.

---

## 14. `provider` over a larger state-management package

**Choice.** Six `ChangeNotifier`s wired up with `provider`.

**Why.** The state here is small and genuinely mutable — a bitmap, a selection, a
zoom level. Riverpod, Bloc or a redux-style store would add ceremony without
removing any of the real complexity, which lives in the pixel handling rather
than in the state graph. `CustomPainter` repaints from a `Listenable.merge`, so
the reactive surface is one line.

**Revisit if.** Multi-document tabs arrive and document lifetime becomes
non-trivial.
