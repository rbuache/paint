# Manual test checklist

CI covers the analyzer, the unit tests, the package layout and an install smoke
test. It cannot tell you whether drawing feels right. Work through this before
tagging a release.

## Start-up

- [ ] `paint` opens on a blank canvas at the size last used.
- [ ] `paint photo.png` opens that file.
- [ ] `paint /does/not/exist.png` still starts, on a blank canvas.
- [ ] Double-clicking an image in the file manager opens it in Paint, and Paint
      appears under "Open With".
- [ ] The window and taskbar show the application icon.

## Drawing

- [ ] Each tool draws, and what appears while dragging matches what remains on
      release.
- [ ] Pencil lands on exact pixels — check at 800% zoom.
- [ ] Brush size and each of the four tips behave as labelled.
- [ ] Eraser clears to transparent; with "erase to secondary colour" it paints
      instead.
- [ ] Right-dragging swaps the colours, for both strokes and shape fills.
- [ ] `Shift` constrains lines to 45° and boxes to squares and circles.
- [ ] `Ctrl` draws a shape from its centre.
- [ ] Curve: drag a line, then bend it twice.
- [ ] Polygon: click vertices, close by clicking the first one; `Escape` closes
      on what has been drawn.
- [ ] Fill respects the tolerance slider and the contiguous switch.
- [ ] Fill on a large image does not freeze the window.
- [ ] Colour picker sets the primary colour, and the secondary on right-click.

## Text

- [ ] Clicking with the text tool opens an editor at that point.
- [ ] **Typing letters that are also tool shortcuts inserts them** rather than
      switching tool — type "Hello, Paint" and check every character arrives.
- [ ] Font family, size, bold, italic, underline and alignment all take effect.
- [ ] `Ctrl+Enter` commits; `Escape` discards; clicking away commits.
- [ ] Committed text lands where the editor showed it.

## Selection

- [ ] Rectangular and free-form selections both mark a region with marching ants.
- [ ] Dragging inside moves the selection and leaves a hole behind.
- [ ] "Transparent selection" leaves a transparent hole; off, it leaves the
      secondary colour.
- [ ] The eight handles resize; edges cannot cross.
- [ ] Arrow keys nudge one pixel.
- [ ] Cut, copy, paste, delete, select all, deselect, invert, crop to selection.
- [ ] Deselecting stamps a moved selection down; undo puts it back.

## Image operations

- [ ] Flip, rotate 90/180/270, invert colours, clear image.
- [ ] Resize by pixels and by percentage, with the aspect lock on and off.
- [ ] Canvas size against several anchors; new area uses the secondary colour.
- [ ] Stretch and skew, including negative skew angles.

## Undo

- [ ] Undo and redo across every tool and every image operation.
- [ ] Drawing after undoing discards the redo branch.
- [ ] Draw two hundred short strokes, then undo back through all of them.
- [ ] On a very large image, deep history does not exhaust memory.

## Files

- [ ] Open and re-save each writable format; reopen and compare.
- [ ] Open a WebP and a PSD; confirm Save As does not offer them.
- [ ] Saving a JPEG flattens transparency onto white rather than black.
- [ ] Save As with no extension typed produces a `.png`.
- [ ] Recent files list works and skips files that have been deleted.
- [ ] Editing marks the title with `*`; saving clears it.
- [ ] New, Open and closing the window all prompt when there are unsaved changes,
      and Cancel really cancels.

## Drag, drop and clipboard

- [ ] Dropping an image on the window opens it, with the overlay hint showing.
- [ ] Dropping a non-image does nothing.
- [ ] Copy from Paint, paste into GIMP — transparency survives.
- [ ] Copy from Firefox or GIMP, paste into Paint — it arrives as a floating
      selection.
- [ ] Pasting an image larger than the canvas grows the canvas.

## View

- [ ] `Ctrl+scroll` zooms around the pointer.
- [ ] Zoom slider, fit-to-window and actual size.
- [ ] At 800% pixels are crisp, not blurred.
- [ ] Middle-drag pans; the image cannot be dragged entirely off screen.
- [ ] The status bar tracks the cursor and shows the image size and zoom.

## Appearance and accessibility

- [ ] Light, dark and follow-system, persisted across a restart.
- [ ] Marching ants stay visible over both light and dark image content.
- [ ] Tab reaches every control; focus is always visible.
- [ ] Tooltips name every tool and give its shortcut.

## Packaging

- [ ] `sudo apt install ./paint_<version>_amd64.deb` on a clean Ubuntu 22.04.
- [ ] The launcher entry appears without logging out.
- [ ] `paint` runs from `PATH`; `man paint` renders.
- [ ] `sudo apt remove paint` leaves nothing behind in `/usr/lib/paint`.
- [ ] The AppImage runs on a distribution that is not Debian-derived.
- [ ] A clean container can add the APT repository and install from it.
- [ ] Bumping the version and republishing makes `apt upgrade` offer the update.
