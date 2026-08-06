import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../l10n/generated/app_localizations.dart';
import '../model/tool_settings.dart';
import '../tools/tool_registry.dart';
import 'tool_labels.dart';

/// The vertical tool strip down the left edge.
class ToolPalette extends StatelessWidget {
  const ToolPalette({super.key});

  /// Two columns, like Paint's palette — narrow enough to leave the canvas the
  /// window, wide enough that the icons stay legible.
  static const int columns = 2;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<ToolSettings>();
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: AppTheme.toolButtonSize * columns + 12,
      color: scheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 1,
          runSpacing: 1,
          children: <Widget>[
            for (final tool in ToolRegistry.tools)
              _ToolButton(
                toolId: tool.id,
                selected: settings.activeTool == tool.id,
                onPressed: () => settings.activeTool = tool.id,
              ),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.toolId,
    required this.selected,
    required this.onPressed,
  });

  final ToolId toolId;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = toolLabel(AppLocalizations.of(context), toolId);

    return Tooltip(
      message: '$label  (${ToolRegistry.shortcutFor(toolId)})',
      child: SizedBox.square(
        dimension: AppTheme.toolButtonSize,
        child: Material(
          color: selected ? scheme.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(4),
            child: Semantics(
              label: label,
              selected: selected,
              button: true,
              child: Icon(
                ToolRegistry.iconFor(toolId),
                size: 17,
                color: selected
                    ? scheme.onSecondaryContainer
                    : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
