import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/generated/app_localizations.dart';
import '../ops/transform_ops.dart';

/// Result of the New Image dialog.
class NewImageSpec {
  const NewImageSpec({
    required this.width,
    required this.height,
    required this.background,
  });

  final int width;
  final int height;
  final Color background;
}

Future<NewImageSpec?> showNewImageDialog(
  BuildContext context, {
  required Size initialSize,
  required Color secondaryColor,
}) {
  return showDialog<NewImageSpec>(
    context: context,
    builder: (context) => _NewImageDialog(
      initialSize: initialSize,
      secondaryColor: secondaryColor,
    ),
  );
}

class _NewImageDialog extends StatefulWidget {
  const _NewImageDialog({
    required this.initialSize,
    required this.secondaryColor,
  });

  final Size initialSize;
  final Color secondaryColor;

  @override
  State<_NewImageDialog> createState() => _NewImageDialogState();
}

class _NewImageDialogState extends State<_NewImageDialog> {
  late final TextEditingController _width;
  late final TextEditingController _height;
  int _backgroundIndex = 0;

  @override
  void initState() {
    super.initState();
    _width = TextEditingController(
      text: widget.initialSize.width.round().toString(),
    );
    _height = TextEditingController(
      text: widget.initialSize.height.round().toString(),
    );
  }

  @override
  void dispose() {
    _width.dispose();
    _height.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.newImageTitle),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: _IntField(label: l10n.fieldWidth, controller: _width),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _IntField(
                    label: l10n.fieldHeight,
                    controller: _height,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _backgroundIndex,
              decoration: InputDecoration(labelText: l10n.fieldBackground),
              items: <DropdownMenuItem<int>>[
                DropdownMenuItem<int>(
                  value: 0,
                  child: Text(l10n.backgroundWhite),
                ),
                DropdownMenuItem<int>(
                  value: 1,
                  child: Text(l10n.backgroundTransparent),
                ),
                DropdownMenuItem<int>(
                  value: 2,
                  child: Text(l10n.backgroundSecondaryColor),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _backgroundIndex = value ?? 0),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.buttonCancel),
        ),
        FilledButton(
          onPressed: () {
            final width = int.tryParse(_width.text) ?? 0;
            final height = int.tryParse(_height.text) ?? 0;
            if (width < 1 || height < 1) return;
            Navigator.of(context).pop(
              NewImageSpec(
                width: width.clamp(1, 20000),
                height: height.clamp(1, 20000),
                background: switch (_backgroundIndex) {
                  1 => const Color(0x00000000),
                  2 => widget.secondaryColor,
                  _ => const Color(0xFFFFFFFF),
                },
              ),
            );
          },
          child: Text(l10n.buttonOk),
        ),
      ],
    );
  }
}

/// Result of the Resize Image dialog.
class ResizeSpec {
  const ResizeSpec({
    required this.width,
    required this.height,
    required this.smooth,
  });

  final int width;
  final int height;
  final bool smooth;
}

Future<ResizeSpec?> showResizeDialog(
  BuildContext context, {
  required int currentWidth,
  required int currentHeight,
}) {
  return showDialog<ResizeSpec>(
    context: context,
    builder: (context) =>
        _ResizeDialog(currentWidth: currentWidth, currentHeight: currentHeight),
  );
}

class _ResizeDialog extends StatefulWidget {
  const _ResizeDialog({
    required this.currentWidth,
    required this.currentHeight,
  });

  final int currentWidth;
  final int currentHeight;

  @override
  State<_ResizeDialog> createState() => _ResizeDialogState();
}

class _ResizeDialogState extends State<_ResizeDialog> {
  late final TextEditingController _width = TextEditingController(
    text: widget.currentWidth.toString(),
  );
  late final TextEditingController _height = TextEditingController(
    text: widget.currentHeight.toString(),
  );
  bool _percent = false;
  bool _keepAspect = true;
  bool _smooth = true;

  @override
  void dispose() {
    _width.dispose();
    _height.dispose();
    super.dispose();
  }

  void _switchUnit(bool percent) {
    if (percent == _percent) return;
    setState(() {
      _percent = percent;
      if (percent) {
        _width.text = '100';
        _height.text = '100';
      } else {
        _width.text = widget.currentWidth.toString();
        _height.text = widget.currentHeight.toString();
      }
    });
  }

  /// Mirrors the edited axis onto the other one while the ratio is locked.
  void _syncAspect({required bool fromWidth}) {
    if (!_keepAspect) return;
    if (_percent) {
      final source = fromWidth ? _width : _height;
      final target = fromWidth ? _height : _width;
      target.text = source.text;
      return;
    }
    final ratio = widget.currentWidth / widget.currentHeight;
    if (fromWidth) {
      final value = int.tryParse(_width.text);
      if (value != null) _height.text = (value / ratio).round().toString();
    } else {
      final value = int.tryParse(_height.text);
      if (value != null) _width.text = (value * ratio).round().toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.resizeImageTitle),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SegmentedButton<bool>(
              segments: <ButtonSegment<bool>>[
                ButtonSegment<bool>(
                  value: false,
                  label: Text(l10n.fieldUnitPixels),
                ),
                ButtonSegment<bool>(
                  value: true,
                  label: Text(l10n.fieldUnitPercent),
                ),
              ],
              selected: <bool>{_percent},
              onSelectionChanged: (selection) => _switchUnit(selection.first),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: _IntField(
                    label: l10n.fieldWidth,
                    controller: _width,
                    onChanged: (_) => _syncAspect(fromWidth: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _IntField(
                    label: l10n.fieldHeight,
                    controller: _height,
                    onChanged: (_) => _syncAspect(fromWidth: false),
                  ),
                ),
              ],
            ),
            CheckboxListTile(
              value: _keepAspect,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.fieldMaintainAspectRatio),
              onChanged: (value) {
                setState(() => _keepAspect = value ?? true);
                _syncAspect(fromWidth: true);
              },
            ),
            CheckboxListTile(
              value: _smooth,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.optionAntiAlias),
              onChanged: (value) => setState(() => _smooth = value ?? true),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.buttonCancel),
        ),
        FilledButton(
          onPressed: () {
            final rawWidth = int.tryParse(_width.text) ?? 0;
            final rawHeight = int.tryParse(_height.text) ?? 0;
            final width = _percent
                ? (widget.currentWidth * rawWidth / 100).round()
                : rawWidth;
            final height = _percent
                ? (widget.currentHeight * rawHeight / 100).round()
                : rawHeight;
            if (width < 1 || height < 1) return;
            Navigator.of(context).pop(
              ResizeSpec(
                width: width.clamp(1, 20000),
                height: height.clamp(1, 20000),
                smooth: _smooth,
              ),
            );
          },
          child: Text(l10n.buttonOk),
        ),
      ],
    );
  }
}

/// Result of the Canvas Size dialog.
class CanvasSizeSpec {
  const CanvasSizeSpec({
    required this.width,
    required this.height,
    required this.anchor,
  });

  final int width;
  final int height;
  final CanvasAnchor anchor;
}

Future<CanvasSizeSpec?> showCanvasSizeDialog(
  BuildContext context, {
  required int currentWidth,
  required int currentHeight,
}) {
  return showDialog<CanvasSizeSpec>(
    context: context,
    builder: (context) => _CanvasSizeDialog(
      currentWidth: currentWidth,
      currentHeight: currentHeight,
    ),
  );
}

class _CanvasSizeDialog extends StatefulWidget {
  const _CanvasSizeDialog({
    required this.currentWidth,
    required this.currentHeight,
  });

  final int currentWidth;
  final int currentHeight;

  @override
  State<_CanvasSizeDialog> createState() => _CanvasSizeDialogState();
}

class _CanvasSizeDialogState extends State<_CanvasSizeDialog> {
  late final TextEditingController _width = TextEditingController(
    text: widget.currentWidth.toString(),
  );
  late final TextEditingController _height = TextEditingController(
    text: widget.currentHeight.toString(),
  );
  CanvasAnchor _anchor = CanvasAnchor.topLeft;

  @override
  void dispose() {
    _width.dispose();
    _height.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.canvasSizeTitle),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: _IntField(label: l10n.fieldWidth, controller: _width),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _IntField(
                    label: l10n.fieldHeight,
                    controller: _height,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.fieldAnchor,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Center(
              child: _AnchorGrid(
                value: _anchor,
                onChanged: (anchor) => setState(() => _anchor = anchor),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.buttonCancel),
        ),
        FilledButton(
          onPressed: () {
            final width = int.tryParse(_width.text) ?? 0;
            final height = int.tryParse(_height.text) ?? 0;
            if (width < 1 || height < 1) return;
            Navigator.of(context).pop(
              CanvasSizeSpec(
                width: width.clamp(1, 20000),
                height: height.clamp(1, 20000),
                anchor: _anchor,
              ),
            );
          },
          child: Text(l10n.buttonOk),
        ),
      ],
    );
  }
}

/// The nine-cell anchor picker, laid out the way the values read.
class _AnchorGrid extends StatelessWidget {
  const _AnchorGrid({required this.value, required this.onChanged});

  final CanvasAnchor value;
  final ValueChanged<CanvasAnchor> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 96,
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          for (final anchor in CanvasAnchor.values)
            InkWell(
              onTap: () => onChanged(anchor),
              child: Container(
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: anchor == value
                      ? scheme.primary
                      : scheme.surfaceContainerHighest,
                  border: Border.all(color: scheme.outlineVariant),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Result of the Stretch and Skew dialog.
class StretchSkewSpec {
  const StretchSkewSpec({
    required this.stretchX,
    required this.stretchY,
    required this.skewX,
    required this.skewY,
  });

  final double stretchX;
  final double stretchY;
  final double skewX;
  final double skewY;
}

Future<StretchSkewSpec?> showStretchSkewDialog(BuildContext context) {
  return showDialog<StretchSkewSpec>(
    context: context,
    builder: (context) => const _StretchSkewDialog(),
  );
}

class _StretchSkewDialog extends StatefulWidget {
  const _StretchSkewDialog();

  @override
  State<_StretchSkewDialog> createState() => _StretchSkewDialogState();
}

class _StretchSkewDialogState extends State<_StretchSkewDialog> {
  final TextEditingController _stretchX = TextEditingController(text: '100');
  final TextEditingController _stretchY = TextEditingController(text: '100');
  final TextEditingController _skewX = TextEditingController(text: '0');
  final TextEditingController _skewY = TextEditingController(text: '0');

  @override
  void dispose() {
    _stretchX.dispose();
    _stretchY.dispose();
    _skewX.dispose();
    _skewY.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.stretchSkewTitle),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${l10n.sectionStretch}  (${l10n.fieldUnitPercent})',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: _IntField(
                    label: l10n.fieldHorizontal,
                    controller: _stretchX,
                    allowNegative: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _IntField(
                    label: l10n.fieldVertical,
                    controller: _stretchY,
                    allowNegative: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              '${l10n.sectionSkew}  (${l10n.unitDegrees})',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: _IntField(
                    label: l10n.fieldHorizontal,
                    controller: _skewX,
                    allowNegative: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _IntField(
                    label: l10n.fieldVertical,
                    controller: _skewY,
                    allowNegative: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.buttonCancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              StretchSkewSpec(
                // Skew is clamped short of 90°, where the tangent diverges and
                // the result would be an infinitely wide canvas.
                stretchX: (double.tryParse(_stretchX.text) ?? 100).clamp(
                  1.0,
                  1000.0,
                ),
                stretchY: (double.tryParse(_stretchY.text) ?? 100).clamp(
                  1.0,
                  1000.0,
                ),
                skewX: (double.tryParse(_skewX.text) ?? 0).clamp(-89.0, 89.0),
                skewY: (double.tryParse(_skewY.text) ?? 0).clamp(-89.0, 89.0),
              ),
            );
          },
          child: Text(l10n.buttonOk),
        ),
      ],
    );
  }
}

/// What the user chose when closing a document with unsaved changes.
enum UnsavedChoice { save, discard, cancel }

Future<UnsavedChoice> showUnsavedChangesDialog(
  BuildContext context,
  String documentName,
) async {
  final l10n = AppLocalizations.of(context);
  final choice = await showDialog<UnsavedChoice>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.unsavedTitle),
      content: Text(l10n.unsavedMessage(documentName)),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(UnsavedChoice.cancel),
          child: Text(l10n.buttonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(UnsavedChoice.discard),
          child: Text(l10n.buttonDiscard),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(UnsavedChoice.save),
          child: Text(l10n.buttonSave),
        ),
      ],
    ),
  );
  // Dismissing with Escape means "don't close", the safe default.
  return choice ?? UnsavedChoice.cancel;
}

class _IntField extends StatelessWidget {
  const _IntField({
    required this.label,
    required this.controller,
    this.onChanged,
    this.allowNegative = false,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool allowNegative;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(
          allowNegative ? RegExp(r'^-?\d*') : RegExp(r'\d*'),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
