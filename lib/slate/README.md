# Slate

A compact widget kit for desktop tools, in the visual language editors and IDEs
converged on: flat surfaces, hairline rules instead of elevation, dense rows,
one restrained accent, and controls that reveal their affordance when you reach
for them rather than shouting it at rest.

It lives inside this repository for now. It is written to be lifted out into its
own package unchanged, which is why it holds nothing application-specific: no
controllers, no models, no localisations, no image-editor concepts. Every widget
takes the strings it displays as parameters, so the caller owns translation.

## Using it

Install the theme once, above everything that draws:

```dart
const slate = SlateThemeData.dark();   // or .light()

MaterialApp(
  theme: slate.toMaterialTheme(),
  builder: (context, child) => SlateTheme(data: slate, child: child!),
  home: const MyWindow(),
);
```

`toMaterialTheme()` exists because an app still gets Scaffold, Navigator,
dialogs and text selection from Material, and those must not arrive in a
different palette than the kit's own widgets.

Then read the theme wherever you need it:

```dart
final theme = context.slate;          // SlateThemeData
final palette = context.slateColors;  // SlatePalette
final metrics = context.slateMetrics; // SlateMetrics
```

## What is in it

| | |
|---|---|
| `SlatePalette` | Every colour, by the role a dense desktop interface actually has: chrome, panel, popover, border, separator, ink, field |
| `SlateMetrics` | Every size. Each control carries an explicit height |
| `SlateThemeData` / `SlateTheme` | The two above plus a font, and the inherited widget that carries them |
| `SlateIcons` / `SlateIcon` | A thin icon set drawn as paths on a 16-unit grid — no font, no asset, takes its colour from the caller |
| `SlateMenuBar` / `SlateMenuButton` / `SlateMenuItem` / `SlateSubmenu` / `SlateMenuSeparator` | An application menu that switches on hover the way a menu bar should |
| `SlateSelect` | A value picker that reads as text until you reach for it |
| `SlateButton` / `SlateIconButton` / `SlateCheckbox` / `SlateSegmented` / `SlateSlider` / `SlateField` / `SlateSeparator` | The controls a toolbar and a dialog need |
| `SlateDialog` / `SlateLabeledField` | A dialog drawn as a popover rather than a Material card |

## Two decisions worth knowing about

**The select has no box at rest.** A bordered, filled control is a heavy shape
sitting next to whatever label introduces it, and in a dense options row that
weight is what makes an interface look bulky even when the type is the right
size. The border and fill arrive on hover, where they are actually needed.

**Menu rows are plain widgets, not `MenuItemButton`s.** That is what lets them
be drawn exactly as designed. The cost is that closing the menu becomes their
own job, which `SlateMenuScope` handles — note that it is installed *above* the
`MenuAnchor`, because the panel is an overlay child and inherits only from the
anchor's ancestors. Putting the scope inside the anchor's `builder` compiles
fine and silently does nothing.

## Icons

Add one as a static method on `SlateIcons` that paints into a 16×16 box with the
`Paint` it is handed:

```dart
static void arrowRight(Canvas canvas, Paint stroke) {
  canvas
    ..drawLine(const Offset(3, 8), const Offset(13, 8), stroke)
    ..drawPath(
      Path()
        ..moveTo(9, 4)
        ..lineTo(13, 8)
        ..lineTo(9, 12),
      stroke,
    );
}
```

Keeping every glyph on one grid with one stroke weight is most of what makes an
editor interface feel like a single piece of software, so match the existing
ones rather than tracing something from elsewhere.
