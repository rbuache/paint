import 'package:flutter/material.dart';

import 'slate_controls.dart';
import 'slate_theme.dart';

/// A dialog drawn as a popover rather than a Material card.
///
/// The shape, border and shadow are the same ones a menu uses, so the two do
/// not read as coming from different applications. The title and the action row
/// are separated by hairlines instead of padding alone, which is what lets the
/// body stay tight without the dialog turning into an undifferentiated block.
///
/// Return it from `showDialog`'s builder; it supplies its own [Dialog] wrapper.
class SlateDialog extends StatelessWidget {
  const SlateDialog({
    required this.title,
    required this.content,
    required this.actions,
    this.width = 340,
    super.key,
  });

  final String title;
  final Widget content;

  /// Laid out right-aligned, in the order given. The confirming action goes
  /// last, which is the convention on this platform.
  final List<Widget> actions;

  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    return Dialog(
      backgroundColor: const Color(0x00000000),
      elevation: 0,
      child: Container(
        width: width,
        decoration: theme.popoverDecoration,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(theme.metrics.pad + 4, 11, 11, 11),
              child: Text(title, style: theme.titleStyle),
            ),
            const SlateSeparator(),
            Padding(
              padding: EdgeInsets.all(theme.metrics.pad + 4),
              child: content,
            ),
            const SlateSeparator(),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  for (final action in actions) ...<Widget>[
                    if (action != actions.first) const SizedBox(width: 8),
                    action,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A field with its name above it.
///
/// The label sits outside the box rather than floating into its border: a
/// floating label animates, overlaps the outline, and costs vertical space that
/// a compact dialog does not have.
class SlateLabeledField extends StatelessWidget {
  const SlateLabeledField({
    required this.label,
    required this.child,
    super.key,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.slate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: theme.dimTextStyle),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}
