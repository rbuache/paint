import 'package:flutter/foundation.dart';

/// Sizes and spacing.
///
/// Every control carries an explicit height. Left to their intrinsic sizes,
/// controls inherit the ambient line height and grow to fill whatever row they
/// are in — which is what makes an interface look inflated even when the type
/// is the right size.
@immutable
class SlateMetrics {
  const SlateMetrics({
    this.radius = 4,
    this.popoverRadius = 6,
    this.rowHeight = 24,
    this.compactRowHeight = 21,
    this.controlHeight = 20,
    this.fieldHeight = 22,
    this.buttonHeight = 23,
    this.barHeight = 30,
    this.windowBarHeight = 36,
    this.fontSize = 13,
    this.smallFontSize = 12,
    this.iconSize = 15,
    this.gap = 8,
    this.pad = 10,
  });

  /// Controls and hover shapes.
  final double radius;

  /// Menus, dropdowns and dialogs, which sit above everything and read better
  /// slightly rounder.
  final double popoverRadius;

  /// A menu row: a command with a shortcut needs the room.
  final double rowHeight;

  /// A row in a value list, which carries less and can be tighter.
  final double compactRowHeight;

  /// Inline controls living inside a bar.
  final double controlHeight;

  final double fieldHeight;
  final double buttonHeight;

  /// Tool options and status rows.
  final double barHeight;

  /// The merged title and menu row.
  final double windowBarHeight;

  final double fontSize;
  final double smallFontSize;
  final double iconSize;

  /// Space between adjacent controls.
  final double gap;

  /// Padding inside a bar or popover.
  final double pad;

  static const SlateMetrics standard = SlateMetrics();

  /// Everything scaled, for a denser or roomier build of the same design.
  SlateMetrics scaled(double factor) {
    return SlateMetrics(
      radius: radius,
      popoverRadius: popoverRadius,
      rowHeight: rowHeight * factor,
      compactRowHeight: compactRowHeight * factor,
      controlHeight: controlHeight * factor,
      fieldHeight: fieldHeight * factor,
      buttonHeight: buttonHeight * factor,
      barHeight: barHeight * factor,
      windowBarHeight: windowBarHeight * factor,
      fontSize: fontSize * factor,
      smallFontSize: smallFontSize * factor,
      iconSize: iconSize * factor,
      gap: gap * factor,
      pad: pad * factor,
    );
  }
}
