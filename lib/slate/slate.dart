/// Slate — a compact widget kit for desktop tools.
///
/// The look is the one editors and IDEs converged on: flat surfaces, hairline
/// rules instead of elevation, dense rows, one restrained accent, and controls
/// that show their affordance when you reach for them rather than shouting it
/// at rest.
///
/// The kit is deliberately free of anything application-specific — no
/// controllers, no models, no localisations. Widgets take the strings they
/// display as parameters, so the caller owns translation. That is what makes it
/// liftable into a package unchanged.
///
/// Wrap the app once and every widget below finds the theme:
///
/// ```dart
/// const slate = SlateThemeData.dark();
/// MaterialApp(
///   theme: slate.toMaterialTheme(),
///   builder: (context, child) => SlateTheme(data: slate, child: child!),
/// );
/// ```
library;

export 'src/slate_controls.dart';
export 'src/slate_dialog.dart';
export 'src/slate_icons.dart';
export 'src/slate_menu.dart';
export 'src/slate_metrics.dart';
export 'src/slate_palette.dart';
export 'src/slate_select.dart';
export 'src/slate_theme.dart';
