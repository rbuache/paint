import 'package:flutter/material.dart';

import 'slate_metrics.dart';
import 'slate_palette.dart';

/// The kit's theme: a palette, a set of metrics, and a font.
@immutable
class SlateThemeData {
  const SlateThemeData({
    required this.palette,
    this.metrics = SlateMetrics.standard,
    this.fontFamily,
  });

  const SlateThemeData.dark({SlateMetrics metrics = SlateMetrics.standard})
    : this(palette: SlatePalette.dark, metrics: metrics);

  const SlateThemeData.light({SlateMetrics metrics = SlateMetrics.standard})
    : this(palette: SlatePalette.light, metrics: metrics);

  final SlatePalette palette;
  final SlateMetrics metrics;

  /// Null uses the platform's interface font, which is what a desktop tool
  /// should do unless it has a reason not to.
  final String? fontFamily;

  TextStyle get textStyle => TextStyle(
    color: palette.ink,
    fontSize: metrics.fontSize,
    fontFamily: fontFamily,
    // Chrome is not prose: the ambient reading line height inflates every
    // control that does not pin its own size.
    height: 1.3,
  );

  TextStyle get dimTextStyle => textStyle.copyWith(
    color: palette.inkDim,
    fontSize: metrics.smallFontSize,
  );

  /// A dialog or panel heading. Weight rather than size does the work, which is
  /// what keeps a dense interface from growing a second type scale.
  TextStyle get titleStyle => textStyle.copyWith(fontWeight: FontWeight.w600);

  /// The heading over a group of controls.
  TextStyle get sectionStyle => textStyle.copyWith(
    color: palette.inkDim,
    fontSize: metrics.smallFontSize,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  BoxDecoration get popoverDecoration => BoxDecoration(
    color: palette.popover,
    border: Border.all(color: palette.border),
    borderRadius: BorderRadius.circular(metrics.popoverRadius),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: palette.shadow,
        blurRadius: 20,
        offset: const Offset(0, 6),
      ),
    ],
  );

  /// A Material theme aligned to this one.
  ///
  /// The kit does not use Material's widgets for anything it draws itself, but
  /// an app still gets Scaffold, Navigator and text selection from Material,
  /// and those must not arrive in a different palette.
  ThemeData toMaterialTheme() {
    final scheme =
        (palette.isDark ? const ColorScheme.dark() : const ColorScheme.light())
            .copyWith(
              brightness: palette.brightness,
              primary: palette.accent,
              onPrimary: palette.onAccent,
              surface: palette.background,
              onSurface: palette.ink,
              outline: palette.border,
              outlineVariant: palette.separator,
              error: palette.danger,
            );

    // Typography carries the geometry (sizes and weights) and the colour set
    // separately; ThemeData normally merges them by locale and brightness, and
    // skipping that merge leaves every text style without a colour.
    final typography = Typography.material2021(colorScheme: scheme);
    final text = typography.englishLike.merge(
      palette.isDark ? typography.white : typography.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      fontFamily: fontFamily,
      visualDensity: VisualDensity.compact,
      splashFactory: NoSplash.splashFactory,
      textTheme: text.apply(
        fontFamily: fontFamily,
        bodyColor: palette.ink,
        displayColor: palette.ink,
      ),
      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 1,
        color: palette.separator,
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 500),
        textStyle: TextStyle(
          fontSize: metrics.smallFontSize,
          color: palette.ink,
          fontFamily: fontFamily,
        ),
        decoration: BoxDecoration(
          color: palette.popover,
          border: Border.all(color: palette.border),
          borderRadius: BorderRadius.circular(metrics.radius),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: palette.shadow,
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.popover,
        contentTextStyle: TextStyle(
          color: palette.ink,
          fontSize: metrics.fontSize,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(metrics.radius),
          side: BorderSide(color: palette.border),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: palette.accent,
        selectionColor: palette.accent.withValues(alpha: 0.32),
        selectionHandleColor: palette.accent,
      ),
    );
  }
}

/// Makes a [SlateThemeData] available to the widgets below it.
class SlateTheme extends InheritedWidget {
  const SlateTheme({required this.data, required super.child, super.key});

  final SlateThemeData data;

  /// The nearest theme. Falls back to the dark palette rather than throwing,
  /// so a widget rendered outside a [SlateTheme] still draws something sane.
  static SlateThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<SlateTheme>();
    return theme?.data ?? const SlateThemeData.dark();
  }

  @override
  bool updateShouldNotify(SlateTheme oldWidget) => data != oldWidget.data;
}

/// Shorthand for the palette and metrics, which is most of what widgets want.
extension SlateThemeContext on BuildContext {
  SlateThemeData get slate => SlateTheme.of(this);
  SlatePalette get slateColors => SlateTheme.of(this).palette;
  SlateMetrics get slateMetrics => SlateTheme.of(this).metrics;
}
