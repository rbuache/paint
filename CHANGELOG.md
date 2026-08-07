# Changelog

All notable changes to this project are recorded here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- A **Copy** button in the bottom-right corner, next to the zoom controls, so a
  quick sketch can go straight onto the clipboard and into a chat or document
  without opening a menu. It copies the selection when there is one and the
  whole image otherwise, and confirms in place for a couple of seconds.

### Changed

- The whole interface is redrawn with **Slate**, a compact widget kit written
  for this application and kept free of anything specific to it, in
  [`lib/slate/`](lib/slate/README.md). Menus, dropdowns, dialogs, buttons,
  sliders and separators are now one coherent set rather than Material's
  defaults: flat surfaces, hairline rules instead of elevation, tighter rows,
  and a thin icon set drawn as paths so every glyph matches at any size.
  Dropdowns in particular no longer sit in a heavy bordered box — they read as
  their value until the pointer reaches them. **Help ▸ About Paint** is part of
  that: it was the last window still drawn by Material, and it no longer opens a
  separate licence browser.
- The system title bar is replaced by one the application draws itself, so the
  menus, the document name and the window buttons share a single row in the
  app's own colours instead of a system bar stacked on a separate menu row.
  That is one row of chrome less, and the window reads as one piece. Dragging
  the bar moves the window, double-clicking it maximises, and the window edges
  resize as usual.
- The mouse wheel now zooms around the pointer instead of scrolling. Shift and
  the wheel scrolls sideways, and dragging with the middle button still pans in
  any direction.

### Fixed

- **Copying an image to the clipboard never worked.** The clipboard package
  used for it does not implement image writing on Linux and silently reported
  "not implemented", so Copy and Cut appeared to succeed and put nothing
  anywhere. The application now writes the clipboard through GTK directly, and
  reports a failure instead of claiming a copy that did not happen. Cut no
  longer deletes the pixels unless the copy succeeded.
- **Zooming in made the window unresponsive.** The transparency checkerboard
  was drawn across the whole scaled image rather than the visible area, which
  at 6400% on a 640x440 image meant about nine million squares per frame.
- **Zooming in painted over the rest of the interface.** The canvas did not
  clip to its own bounds, so at high zoom the image covered the menu bar, the
  tool palette and the colour panel, and swallowed clicks meant for them.
- Selection outlines no longer generate tens of thousands of dashes per frame
  on a large selection at high zoom.

## [0.1.0] - 2026-08-06

First release: a complete, usable editor with parity against classic MS Paint.

### Added

- **Tools** — pencil, brush (round, square and two calligraphic slash tips),
  eraser (to transparent or to the secondary colour), fill bucket with
  tolerance and a contiguous/global switch, colour picker, text, line, curve,
  rectangle, rounded rectangle, ellipse and polygon.
- **Selection** — rectangular and free-form, with floating move, eight resize
  handles, arrow-key nudge, delete, invert, select all and crop to selection.
- **Colours** — primary and secondary swatches with right-click drawing, the
  classic 28-colour palette, a custom colour editor with HSV, RGB, alpha and
  hex entry, and a remembered list of mixed colours.
- **Image operations** — flip horizontal and vertical, rotate by 90/180/270,
  resize by pixels or percentage, canvas size with a nine-point anchor,
  stretch and skew, invert colours and clear image.
- **Undo and redo** governed by a memory budget rather than a step count, so
  small edits give a very deep history.
- **Files** — open and save PNG, JPEG, BMP, GIF, TIFF, TGA and ICO; open WebP,
  Photoshop and Netpbm. Recent files, an unsaved-changes guard, and a file
  path accepted on the command line.
- **Drag and drop** of image files onto the window.
- **Clipboard** copy and paste of images, pasted as a floating selection.
- **View** — zoom from 2% to 6400% with Ctrl+scroll around the pointer,
  fit-to-window, actual size, middle-button panning and a status bar showing
  cursor position, image size and zoom.
- **Appearance** — a sober Material 3 theme in light, dark or follow-system.
- **Internationalization** wired up through ARB files, English for now.
- **Packaging** — Debian package with desktop entry, MIME associations,
  hicolor icons, AppStream metadata and a man page; an AppImage; and a signed
  APT repository published to GitHub Pages.

[Unreleased]: https://github.com/rbuache/paint/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/rbuache/paint/releases/tag/v0.1.0
