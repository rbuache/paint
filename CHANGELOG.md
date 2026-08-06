# Changelog

All notable changes to this project are recorded here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
