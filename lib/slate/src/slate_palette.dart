import 'dart:ui' show Brightness, Color;

import 'package:flutter/foundation.dart';

/// Every colour the kit draws with.
///
/// Deliberately a plain value class rather than a Material `ColorScheme`: the
/// roles here are the ones a dense desktop interface actually has — chrome,
/// popover, hairline, field — and mapping those onto Material's semantic slots
/// loses exactly the distinctions the design depends on.
@immutable
class SlatePalette {
  const SlatePalette({
    required this.background,
    required this.chrome,
    required this.panel,
    required this.popover,
    required this.border,
    required this.separator,
    required this.ink,
    required this.inkDim,
    required this.accent,
    required this.onAccent,
    required this.hover,
    required this.selected,
    required this.field,
    required this.fieldBorder,
    required this.danger,
    required this.shadow,
    required this.brightness,
  });

  /// The window behind everything.
  final Color background;

  /// Title bar and menu row.
  final Color chrome;

  /// Secondary bars: tool options, status, side panels.
  final Color panel;

  /// Menus, dropdowns, dialogs.
  final Color popover;

  /// Outline of a popover or a field.
  final Color border;

  /// Hairline rules between rows and bars. Quieter than [border].
  final Color separator;

  final Color ink;

  /// Labels, shortcuts, and anything the eye should skip.
  final Color inkDim;

  final Color accent;

  /// Text and icons drawn on top of [accent].
  final Color onAccent;

  final Color hover;

  /// Background of the row under the cursor in a menu, or a chosen value.
  final Color selected;

  final Color field;
  final Color fieldBorder;

  /// Destructive actions: the window close button, delete.
  final Color danger;

  final Color shadow;

  final Brightness brightness;

  bool get isDark => brightness == Brightness.dark;

  /// The palette the specimens were designed against.
  static const SlatePalette dark = SlatePalette(
    background: Color(0xFF16181C),
    chrome: Color(0xFF1C1F24),
    panel: Color(0xFF1C1F24),
    popover: Color(0xFF202429),
    border: Color(0xFF2E343C),
    separator: Color(0xFF272C33),
    ink: Color(0xFFD8DDE4),
    inkDim: Color(0xFF8A939F),
    accent: Color(0xFFE0A33E),
    onAccent: Color(0xFF1B1206),
    hover: Color(0xFF242931),
    selected: Color(0xFF2E2A22),
    field: Color(0xFF191C21),
    fieldBorder: Color(0xFF333A43),
    danger: Color(0xFFE04A3F),
    shadow: Color(0x6B000000),
    brightness: Brightness.dark,
  );

  static const SlatePalette light = SlatePalette(
    background: Color(0xFFFFFFFF),
    chrome: Color(0xFFF2F4F7),
    panel: Color(0xFFF6F7F9),
    popover: Color(0xFFFFFFFF),
    border: Color(0xFFDDE1E7),
    separator: Color(0xFFE7EAEF),
    ink: Color(0xFF22262C),
    inkDim: Color(0xFF6B747F),
    accent: Color(0xFFA8681A),
    onAccent: Color(0xFFFFFFFF),
    hover: Color(0xFFEDEFF3),
    selected: Color(0xFFFBF0DF),
    field: Color(0xFFFFFFFF),
    fieldBorder: Color(0xFFD3D8DF),
    danger: Color(0xFFD4392E),
    shadow: Color(0x21161C24),
    brightness: Brightness.light,
  );

  SlatePalette copyWith({Color? accent, Color? onAccent}) {
    return SlatePalette(
      background: background,
      chrome: chrome,
      panel: panel,
      popover: popover,
      border: border,
      separator: separator,
      ink: ink,
      inkDim: inkDim,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      hover: hover,
      selected: selected,
      field: field,
      fieldBorder: fieldBorder,
      danger: danger,
      shadow: shadow,
      brightness: brightness,
    );
  }
}
