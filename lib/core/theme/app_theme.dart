import 'package:flutter/material.dart';

/// Colours the editor needs that are not part of [ColorScheme].
///
/// These describe the drawing surface rather than the chrome, so they are kept
/// separate from the Material palette and resolved per brightness.
@immutable
class CanvasColors extends ThemeExtension<CanvasColors> {
  const CanvasColors({
    required this.backdrop,
    required this.checkerLight,
    required this.checkerDark,
    required this.canvasBorder,
    required this.marchingAntsLight,
    required this.marchingAntsDark,
    required this.handleFill,
    required this.handleBorder,
  });

  /// Area around the image.
  final Color backdrop;

  /// The two squares of the transparency checkerboard.
  final Color checkerLight;
  final Color checkerDark;

  /// Hairline around the image bounds.
  final Color canvasBorder;

  /// The two dash colours of the selection outline. They alternate so the
  /// outline stays visible over both light and dark pixels.
  final Color marchingAntsLight;
  final Color marchingAntsDark;

  /// Selection resize handles.
  final Color handleFill;
  final Color handleBorder;

  static const CanvasColors light = CanvasColors(
    backdrop: Color(0xFFE8E9EB),
    checkerLight: Color(0xFFFFFFFF),
    checkerDark: Color(0xFFD6D8DB),
    canvasBorder: Color(0x33000000),
    marchingAntsLight: Color(0xFFFFFFFF),
    marchingAntsDark: Color(0xFF000000),
    handleFill: Color(0xFFFFFFFF),
    handleBorder: Color(0xFF3F4A5A),
  );

  static const CanvasColors dark = CanvasColors(
    backdrop: Color(0xFF1B1D20),
    checkerLight: Color(0xFF4A4D52),
    checkerDark: Color(0xFF3A3D42),
    canvasBorder: Color(0x55FFFFFF),
    marchingAntsLight: Color(0xFFFFFFFF),
    marchingAntsDark: Color(0xFF000000),
    handleFill: Color(0xFF23262A),
    handleBorder: Color(0xFFC9CDD4),
  );

  @override
  CanvasColors copyWith({
    Color? backdrop,
    Color? checkerLight,
    Color? checkerDark,
    Color? canvasBorder,
    Color? marchingAntsLight,
    Color? marchingAntsDark,
    Color? handleFill,
    Color? handleBorder,
  }) {
    return CanvasColors(
      backdrop: backdrop ?? this.backdrop,
      checkerLight: checkerLight ?? this.checkerLight,
      checkerDark: checkerDark ?? this.checkerDark,
      canvasBorder: canvasBorder ?? this.canvasBorder,
      marchingAntsLight: marchingAntsLight ?? this.marchingAntsLight,
      marchingAntsDark: marchingAntsDark ?? this.marchingAntsDark,
      handleFill: handleFill ?? this.handleFill,
      handleBorder: handleBorder ?? this.handleBorder,
    );
  }

  @override
  CanvasColors lerp(ThemeExtension<CanvasColors>? other, double t) {
    if (other is! CanvasColors) return this;
    return CanvasColors(
      backdrop: Color.lerp(backdrop, other.backdrop, t)!,
      checkerLight: Color.lerp(checkerLight, other.checkerLight, t)!,
      checkerDark: Color.lerp(checkerDark, other.checkerDark, t)!,
      canvasBorder: Color.lerp(canvasBorder, other.canvasBorder, t)!,
      marchingAntsLight: Color.lerp(
        marchingAntsLight,
        other.marchingAntsLight,
        t,
      )!,
      marchingAntsDark: Color.lerp(
        marchingAntsDark,
        other.marchingAntsDark,
        t,
      )!,
      handleFill: Color.lerp(handleFill, other.handleFill, t)!,
      handleBorder: Color.lerp(handleBorder, other.handleBorder, t)!,
    );
  }
}

/// Sober, low-chroma Material 3 themes for the editor chrome.
///
/// The chrome is deliberately neutral so the image being edited is the only
/// saturated thing on screen. Elevation is replaced by hairline dividers and a
/// single restrained accent marks selection and focus.
abstract final class AppTheme {
  /// Neutral slate — just enough hue that selected and disabled states stay
  /// distinguishable without the UI reading as "blue".
  static const Color seed = Color(0xFF546070);

  /// Height of the toolbar and status bar rows. Kept tight so the canvas gets
  /// the window.
  static const double barHeight = 34;
  static const double toolButtonSize = 30;

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.neutral,
    );
    final isLight = brightness == Brightness.light;

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      visualDensity: VisualDensity.compact,
      scaffoldBackgroundColor: scheme.surface,
      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 1,
        color: scheme.outlineVariant,
      ),
      splashFactory: NoSplash.splashFactory,
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 600),
        textStyle: TextStyle(fontSize: 12, color: scheme.onInverseSurface),
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      iconTheme: IconThemeData(size: 18, color: scheme.onSurfaceVariant),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(toolButtonSize),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          elevation: const WidgetStatePropertyAll(3),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
      ),
      sliderTheme: const SliderThemeData(
        trackHeight: 2,
        overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      extensions: <ThemeExtension<dynamic>>[
        isLight ? CanvasColors.light : CanvasColors.dark,
      ],
    );
  }
}

/// Convenience access to [CanvasColors] from a [BuildContext].
extension CanvasColorsContext on BuildContext {
  CanvasColors get canvasColors =>
      Theme.of(this).extension<CanvasColors>() ?? CanvasColors.light;
}
