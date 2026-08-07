import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'slate_icons.dart';
import 'slate_theme.dart';

/// How much a button asserts itself.
enum SlateButtonKind {
  /// The one thing the user most likely wants: filled with the accent.
  primary,

  /// An outlined field-coloured button, for everything alongside it.
  secondary,

  /// No shape at rest; the box arrives on hover. For bars and toolbars.
  ghost,
}

class SlateButton extends StatefulWidget {
  const SlateButton({
    required this.label,
    required this.onPressed,
    this.kind = SlateButtonKind.secondary,
    this.icon,
    this.iconColor,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final SlateButtonKind kind;
  final SlateIconDraw? icon;

  /// Overrides the icon colour, for a control that confirms in place.
  final Color? iconColor;

  @override
  State<SlateButton> createState() => _SlateButtonState();
}

class _SlateButtonState extends State<SlateButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final palette = theme.palette;
    final enabled = widget.onPressed != null;

    Color background;
    Color foreground;
    Color? borderColor;
    switch (widget.kind) {
      case SlateButtonKind.primary:
        background = _hover ? _lift(palette.accent) : palette.accent;
        foreground = palette.onAccent;
        borderColor = palette.accent;
      case SlateButtonKind.secondary:
        background = _hover ? palette.hover : palette.field;
        foreground = palette.ink;
        borderColor = palette.fieldBorder;
      case SlateButtonKind.ghost:
        background = _hover ? palette.hover : const Color(0x00000000);
        foreground = palette.inkDim;
        borderColor = null;
    }
    if (!enabled) {
      foreground = palette.inkDim.withValues(alpha: 0.5);
      background = widget.kind == SlateButtonKind.primary
          ? palette.accent.withValues(alpha: 0.35)
          : background;
    }

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          height: theme.metrics.buttonHeight,
          padding: EdgeInsets.symmetric(
            horizontal: widget.kind == SlateButtonKind.ghost ? 8 : 13,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(theme.metrics.radius),
            border: borderColor == null ? null : Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.icon != null) ...<Widget>[
                SlateIcon(
                  widget.icon!,
                  size: 13,
                  color: widget.iconColor ?? foreground,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: theme.textStyle.copyWith(
                  color: widget.iconColor ?? foreground,
                  fontSize: theme.metrics.smallFontSize,
                  fontWeight: widget.kind == SlateButtonKind.primary
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Slightly brighter, for hover on a filled button.
  static Color _lift(Color base) {
    final hsl = HSLColor.fromColor(base);
    return hsl.withLightness((hsl.lightness + 0.06).clamp(0.0, 1.0)).toColor();
  }
}

/// A square button carrying only an icon.
class SlateIconButton extends StatefulWidget {
  const SlateIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.selected = false,
    this.danger = false,
    this.size,
    super.key,
  });

  final SlateIconDraw icon;
  final VoidCallback? onPressed;

  /// Required rather than optional: an icon with no name is unusable by anyone
  /// relying on a screen reader, and often by everyone else too.
  final String tooltip;

  final bool selected;

  /// Turns the hover red. For the window close button and destructive actions.
  final bool danger;

  final double? size;

  @override
  State<SlateIconButton> createState() => _SlateIconButtonState();
}

class _SlateIconButtonState extends State<SlateIconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final palette = theme.palette;
    final enabled = widget.onPressed != null;
    final side = widget.size ?? theme.metrics.controlHeight + 6;

    Color background = const Color(0x00000000);
    if (widget.selected) background = palette.selected;
    if (_hover && enabled) {
      background = widget.danger ? palette.danger : palette.hover;
    }

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Semantics(
            label: widget.tooltip,
            button: true,
            selected: widget.selected,
            child: Container(
              width: side,
              height: side,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(theme.metrics.radius),
              ),
              child: SlateIcon(
                widget.icon,
                color: !enabled
                    ? palette.inkDim.withValues(alpha: 0.4)
                    : widget.danger && _hover
                    ? const Color(0xFFFFFFFF)
                    : widget.selected
                    ? palette.accent
                    : palette.inkDim,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SlateCheckbox extends StatefulWidget {
  const SlateCheckbox({
    required this.value,
    required this.label,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  State<SlateCheckbox> createState() => _SlateCheckboxState();
}

class _SlateCheckboxState extends State<SlateCheckbox> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final palette = theme.palette;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        // The label is part of the target: a 13px box is a mean thing to ask
        // anyone to hit.
        onTap: () => widget.onChanged(!widget.value),
        child: Semantics(
          checked: widget.value,
          label: widget.label,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 13,
                height: 13,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.value ? palette.accent : palette.field,
                  border: Border.all(
                    color: widget.value
                        ? palette.accent
                        : _hover
                        ? palette.inkDim
                        : palette.fieldBorder,
                  ),
                  borderRadius: BorderRadius.circular(theme.metrics.radius - 1),
                ),
                child: widget.value
                    ? SlateIcon(
                        SlateIcons.check,
                        size: 10,
                        color: palette.onAccent,
                        weight: 2,
                      )
                    : null,
              ),
              const SizedBox(width: 7),
              Text(
                widget.label,
                style: theme.textStyle.copyWith(
                  fontSize: theme.metrics.smallFontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A row of mutually exclusive choices, all visible at once.
///
/// Use it instead of a [SlateSelect] when there are two or three options and
/// the choice changes what the controls beneath it mean — seeing both labels is
/// worth the width.
class SlateSegmented<T> extends StatelessWidget {
  const SlateSegmented({
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
    super.key,
  });

  final T value;
  final List<T> values;
  final String Function(T value) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final palette = theme.palette;
    return Container(
      height: theme.metrics.fieldHeight,
      decoration: BoxDecoration(
        color: palette.field,
        border: Border.all(color: palette.fieldBorder),
        borderRadius: BorderRadius.circular(theme.metrics.radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final option in values) ...<Widget>[
            if (option != values.first)
              Container(width: 1, color: palette.fieldBorder),
            _Segment(
              label: labelOf(option),
              selected: option == value,
              onPressed: () => onChanged(option),
            ),
          ],
        ],
      ),
    );
  }
}

class _Segment extends StatefulWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  State<_Segment> createState() => _SegmentState();
}

class _SegmentState extends State<_Segment> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final palette = theme.palette;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          color: widget.selected
              ? palette.selected
              : _hover
              ? palette.hover
              : const Color(0x00000000),
          child: Text(
            widget.label,
            style: theme.textStyle.copyWith(
              fontSize: theme.metrics.smallFontSize,
              color: widget.selected ? palette.accent : palette.inkDim,
            ),
          ),
        ),
      ),
    );
  }
}

/// A thin slider sized for a toolbar rather than a settings page.
class SlateSlider extends StatelessWidget {
  const SlateSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.width = 92,
    super.key,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final palette = theme.palette;
    return SizedBox(
      width: width,
      height: theme.metrics.controlHeight,
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: 3,
          activeTrackColor: palette.accent,
          inactiveTrackColor: palette.border,
          thumbColor: palette.accent,
          overlayColor: palette.accent.withValues(alpha: 0.14),
          thumbShape: const RoundSliderThumbShape(
            enabledThumbRadius: 5.5,
            elevation: 0,
            pressedElevation: 0,
          ),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 11),
          trackShape: const RectangularSliderTrackShape(),
        ),
        child: Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// A single-line text input.
class SlateField extends StatelessWidget {
  const SlateField({
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.width,
    this.textAlign = TextAlign.start,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.hint,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final double? width;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    final palette = theme.palette;
    return SizedBox(
      width: width,
      height: theme.metrics.fieldHeight,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textAlign: textAlign,
        inputFormatters: inputFormatters,
        cursorWidth: 1,
        cursorColor: palette.accent,
        style: theme.textStyle.copyWith(fontSize: theme.metrics.smallFontSize),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: palette.field,
          hintText: hint,
          hintStyle: theme.dimTextStyle,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(theme.metrics.radius),
            borderSide: BorderSide(color: palette.fieldBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(theme.metrics.radius),
            borderSide: BorderSide(color: palette.fieldBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(theme.metrics.radius),
            borderSide: BorderSide(color: palette.accent),
          ),
        ),
      ),
    );
  }
}

/// A hairline. [vertical] separates controls inside a row; horizontal
/// separates bars.
class SlateSeparator extends StatelessWidget {
  const SlateSeparator({this.vertical = false, this.inset = 0, super.key});

  final bool vertical;

  /// Pulls the line in from both ends, so it reads as a divider between
  /// controls rather than a structural edge.
  final double inset;

  @override
  Widget build(BuildContext context) {
    final color = context.slateColors.separator;
    return vertical
        ? Container(
            width: 1,
            margin: EdgeInsets.symmetric(vertical: inset),
            color: color,
          )
        : Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: inset),
            color: color,
          );
  }
}
