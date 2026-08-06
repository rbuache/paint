import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../l10n/generated/app_localizations.dart';
import '../model/tool_settings.dart';
import '../tools/tool_registry.dart';
import 'tool_labels.dart';

/// Options for the active tool, shown as a single compact row under the menu.
///
/// Only the options the active tool declares are built, so the row never shows
/// a control that does nothing.
class ToolOptionsBar extends StatelessWidget {
  const ToolOptionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<ToolSettings>();
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final tool = ToolRegistry.byId(settings.activeTool);
    final options = tool?.options ?? const <ToolOption>{};

    return Container(
      height: AppTheme.barHeight,
      color: scheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          Text(
            toolLabel(l10n, settings.activeTool),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          if (options.isNotEmpty) const _Separator(),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  if (options.contains(ToolOption.size))
                    _SliderOption(
                      label: l10n.optionSize,
                      value: settings.strokeWidth,
                      min: 1,
                      max: 64,
                      suffix: 'px',
                      onChanged: (value) => settings.strokeWidth = value,
                    ),
                  if (options.contains(ToolOption.tip))
                    _EnumOption<BrushTip>(
                      label: l10n.optionTip,
                      value: settings.brushTip,
                      values: BrushTip.values,
                      labelFor: (tip) => switch (tip) {
                        BrushTip.round => l10n.optionTipRound,
                        BrushTip.square => l10n.optionTipSquare,
                        BrushTip.slashForward => l10n.optionTipSlash,
                        BrushTip.slashBackward => l10n.optionTipBackslash,
                      },
                      onChanged: (tip) => settings.brushTip = tip,
                    ),
                  if (options.contains(ToolOption.fillStyle))
                    _EnumOption<FillStyle>(
                      label: l10n.optionFillStyle,
                      value: settings.fillStyle,
                      values: FillStyle.values,
                      labelFor: (style) => switch (style) {
                        FillStyle.outline => l10n.optionFillOutline,
                        FillStyle.filled => l10n.optionFillSolid,
                        FillStyle.outlineAndFill => l10n.optionFillBoth,
                      },
                      onChanged: (style) => settings.fillStyle = style,
                    ),
                  if (options.contains(ToolOption.cornerRadius))
                    _SliderOption(
                      label: l10n.optionCornerRadius,
                      value: settings.cornerRadius,
                      min: 0,
                      max: 64,
                      suffix: 'px',
                      onChanged: (value) => settings.cornerRadius = value,
                    ),
                  if (options.contains(ToolOption.tolerance))
                    _SliderOption(
                      label: l10n.optionTolerance,
                      value: settings.tolerance.toDouble(),
                      min: 0,
                      max: 255,
                      onChanged: (value) => settings.tolerance = value.round(),
                    ),
                  if (options.contains(ToolOption.contiguous))
                    _CheckOption(
                      label: l10n.optionContiguous,
                      value: settings.contiguous,
                      onChanged: (value) => settings.contiguous = value,
                    ),
                  if (options.contains(ToolOption.antiAlias))
                    _CheckOption(
                      label: l10n.optionAntiAlias,
                      value: settings.antiAlias,
                      onChanged: (value) => settings.antiAlias = value,
                    ),
                  if (options.contains(ToolOption.eraseToSecondary))
                    _CheckOption(
                      label: l10n.optionEraseToSecondary,
                      value: settings.eraseToSecondary,
                      onChanged: (value) => settings.eraseToSecondary = value,
                    ),
                  if (options.contains(ToolOption.selectionTransparent))
                    _CheckOption(
                      label: l10n.optionSelectionTransparent,
                      value: settings.selectionTransparent,
                      onChanged: (value) =>
                          settings.selectionTransparent = value,
                    ),
                  if (options.contains(ToolOption.text)) const _TextOptions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Text-specific controls: family, size, weight, slant, underline, alignment.
class _TextOptions extends StatelessWidget {
  const _TextOptions();

  /// Families that are present on essentially every desktop Linux install.
  /// Fontconfig aliases the first three, so they resolve even on a minimal
  /// system.
  static const List<String> families = <String>[
    'Sans',
    'Serif',
    'Monospace',
    'DejaVu Sans',
    'Liberation Sans',
    'Ubuntu',
    'Noto Sans',
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<ToolSettings>();
    final l10n = AppLocalizations.of(context);

    return Row(
      children: <Widget>[
        _OptionLabel(l10n.optionFontFamily),
        SizedBox(
          width: 150,
          child: DropdownButtonFormField<String>(
            initialValue: families.contains(settings.fontFamily)
                ? settings.fontFamily
                : families.first,
            isDense: true,
            items: <DropdownMenuItem<String>>[
              for (final family in families)
                DropdownMenuItem<String>(
                  value: family,
                  child: Text(family, style: const TextStyle(fontSize: 12)),
                ),
            ],
            onChanged: (value) {
              if (value != null) settings.fontFamily = value;
            },
          ),
        ),
        const _Separator(),
        _SliderOption(
          label: l10n.optionFontSize,
          value: settings.fontSize,
          min: 6,
          max: 144,
          suffix: 'pt',
          onChanged: (value) => settings.fontSize = value,
        ),
        const _Separator(),
        _ToggleIcon(
          icon: Icons.format_bold,
          tooltip: l10n.optionBold,
          value: settings.bold,
          onChanged: (value) => settings.bold = value,
        ),
        _ToggleIcon(
          icon: Icons.format_italic,
          tooltip: l10n.optionItalic,
          value: settings.italic,
          onChanged: (value) => settings.italic = value,
        ),
        _ToggleIcon(
          icon: Icons.format_underlined,
          tooltip: l10n.optionUnderline,
          value: settings.underline,
          onChanged: (value) => settings.underline = value,
        ),
        const _Separator(),
        _ToggleIcon(
          icon: Icons.format_align_left,
          tooltip: l10n.optionAlignLeft,
          value: settings.textAlign == TextAlign.left,
          onChanged: (_) => settings.textAlign = TextAlign.left,
        ),
        _ToggleIcon(
          icon: Icons.format_align_center,
          tooltip: l10n.optionAlignCenter,
          value: settings.textAlign == TextAlign.center,
          onChanged: (_) => settings.textAlign = TextAlign.center,
        ),
        _ToggleIcon(
          icon: Icons.format_align_right,
          tooltip: l10n.optionAlignRight,
          value: settings.textAlign == TextAlign.right,
          onChanged: (_) => settings.textAlign = TextAlign.right,
        ),
        const _Separator(),
        _CheckOption(
          label: l10n.optionOpaqueBackground,
          value: settings.textOpaqueBackground,
          onChanged: (value) => settings.textOpaqueBackground = value,
        ),
      ],
    );
  }
}

class _SliderOption extends StatelessWidget {
  const _SliderOption({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.suffix,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String? suffix;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _OptionLabel(label),
        SizedBox(
          width: 110,
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 42,
          child: Text(
            suffix == null ? '${value.round()}' : '${value.round()} $suffix',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}

class _EnumOption<T> extends StatelessWidget {
  const _EnumOption({
    required this.label,
    required this.value,
    required this.values,
    required this.labelFor,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T) labelFor;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _OptionLabel(label),
        SizedBox(
          width: 150,
          child: DropdownButtonFormField<T>(
            initialValue: value,
            isDense: true,
            items: <DropdownMenuItem<T>>[
              for (final option in values)
                DropdownMenuItem<T>(
                  value: option,
                  child: Text(
                    labelFor(option),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
            onChanged: (selected) {
              if (selected != null) onChanged(selected);
            },
          ),
        ),
        const _Separator(),
      ],
    );
  }
}

class _CheckOption extends StatelessWidget {
  const _CheckOption({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Checkbox(
          value: value,
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: (checked) => onChanged(checked ?? false),
        ),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Text(label, style: Theme.of(context).textTheme.labelSmall),
        ),
        const _Separator(),
      ],
    );
  }
}

class _ToggleIcon extends StatelessWidget {
  const _ToggleIcon({
    required this.icon,
    required this.tooltip,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String tooltip;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 26,
          height: 24,
          decoration: BoxDecoration(
            color: value ? scheme.secondaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 16),
        ),
      ),
    );
  }
}

class _OptionLabel extends StatelessWidget {
  const _OptionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: VerticalDivider(
        width: 1,
        indent: 7,
        endIndent: 7,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}
