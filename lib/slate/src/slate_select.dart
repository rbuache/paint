import 'package:flutter/material.dart';

import 'slate_icons.dart';
import 'slate_menu.dart';
import 'slate_theme.dart';

/// A value picker that reads as text until you reach for it.
///
/// The trigger has no border and no fill at rest — just the value and a
/// chevron. A bordered, filled box is a heavy shape sitting next to whatever
/// label introduces it, and in a dense options row that weight is what makes
/// the interface look bulky even when the type is the right size. The
/// affordance arrives on hover, where it is actually needed.
class SlateSelect<T> extends StatefulWidget {
  const SlateSelect({
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
    this.minWidth = 0,
    super.key,
  });

  final T value;
  final List<T> values;
  final String Function(T value) labelOf;
  final ValueChanged<T> onChanged;

  /// Set this when several selects sit side by side and should not jump about
  /// as their values change width.
  final double minWidth;

  @override
  State<SlateSelect<T>> createState() => _SlateSelectState<T>();
}

class _SlateSelectState<T> extends State<SlateSelect<T>> {
  final MenuController _controller = MenuController();
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;

    // The scope wraps the anchor, not the trigger: the value list is an overlay
    // child and inherits from the anchor's ancestors only.
    return SlateMenuScope(
      controller: _controller,
      parent: null,
      child: MenuAnchor(
        controller: _controller,
        style: slateMenuStyle(theme),
        alignmentOffset: const Offset(0, 4),
        menuChildren: <Widget>[
          for (final value in widget.values)
            _SelectRow(
              label: widget.labelOf(value),
              selected: value == widget.value,
              onPressed: () => widget.onChanged(value),
            ),
        ],
        builder: (context, controller, _) {
          final lit = _hover || controller.isOpen;
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hover = true),
            onExit: (_) => setState(() => _hover = false),
            child: GestureDetector(
              onTap: () =>
                  controller.isOpen ? controller.close() : controller.open(),
              child: Container(
                height: theme.metrics.controlHeight,
                constraints: BoxConstraints(minWidth: widget.minWidth),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: lit ? theme.palette.hover : const Color(0x00000000),
                  borderRadius: BorderRadius.circular(theme.metrics.radius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        widget.labelOf(widget.value),
                        style: theme.textStyle.copyWith(
                          fontSize: theme.metrics.smallFontSize,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    SlateIcon(
                      SlateIcons.chevronDown,
                      size: 11,
                      color: theme.palette.inkDim,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A row in the value list. Tighter than a menu row: it carries a value, not a
/// command with a shortcut.
class _SelectRow extends StatefulWidget {
  const _SelectRow({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  State<_SelectRow> createState() => _SelectRowState();
}

class _SelectRowState extends State<_SelectRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () {
          SlateMenuScope.maybeOf(context)?.closeAll();
          widget.onPressed();
        },
        child: Container(
          height: theme.metrics.compactRowHeight,
          constraints: const BoxConstraints(minWidth: 118),
          padding: const EdgeInsets.symmetric(horizontal: 9),
          color: _hover ? theme.palette.selected : const Color(0x00000000),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.label,
                  style: theme.textStyle.copyWith(
                    fontSize: theme.metrics.smallFontSize,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.selected)
                SlateIcon(
                  SlateIcons.check,
                  size: 11,
                  color: theme.palette.accent,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
