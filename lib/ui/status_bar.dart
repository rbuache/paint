import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/canvas_controller.dart';
import '../controller/document_controller.dart';
import '../controller/selection_controller.dart';
import '../controller/viewport_controller.dart';
import '../core/theme/app_theme.dart';
import '../l10n/generated/app_localizations.dart';
import 'app_actions.dart';

/// Cursor position, image size and zoom, along the bottom edge.
class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final documents = context.watch<DocumentController>();
    final canvas = context.watch<CanvasController>();
    final viewport = context.watch<ViewportController>();
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelSmall;

    final cursor = canvas.cursorImagePosition;

    return Container(
      height: AppTheme.barHeight,
      color: scheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 110,
            child: Text(
              cursor == null
                  ? ''
                  : l10n.statusPosition(cursor.dx.floor(), cursor.dy.floor()),
              style: textStyle,
            ),
          ),
          if (documents.isReady)
            Text(
              l10n.statusSize(
                documents.document.width,
                documents.document.height,
              ),
              style: textStyle,
            ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.remove, size: 16),
            tooltip: l10n.actionZoomOut,
            onPressed: viewport.zoomOut,
          ),
          SizedBox(
            width: 120,
            child: Slider(
              value: _zoomToSlider(viewport.zoom),
              onChanged: (value) => viewport.zoomTo(_sliderToZoom(value)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 16),
            tooltip: l10n.actionZoomIn,
            onPressed: viewport.zoomIn,
          ),
          SizedBox(
            width: 52,
            child: Text(
              l10n.statusZoom((viewport.zoom * 100).round()),
              style: textStyle,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.fit_screen_outlined, size: 16),
            tooltip: l10n.actionZoomFit,
            onPressed: viewport.fitToWindow,
          ),
          IconButton(
            icon: const Icon(Icons.crop_original_outlined, size: 16),
            tooltip: l10n.actionZoomNormal,
            onPressed: viewport.zoomToActualSize,
          ),
          const SizedBox(width: 8),
          VerticalDivider(
            width: 1,
            indent: 7,
            endIndent: 7,
            color: scheme.outlineVariant,
          ),
          const SizedBox(width: 8),
          const CopyToClipboardButton(),
        ],
      ),
    );
  }

  /// Slider position for [zoom], on a log scale.
  ///
  /// A linear slider would spend most of its travel above 100% and make the
  /// small zoom levels impossible to hit.
  static double _zoomToSlider(double zoom) {
    final clamped = zoom.clamp(
      ViewportController.minZoom,
      ViewportController.maxZoom,
    );
    final min = math.log(ViewportController.minZoom);
    final max = math.log(ViewportController.maxZoom);
    return ((math.log(clamped) - min) / (max - min)).clamp(0.0, 1.0);
  }

  static double _sliderToZoom(double slider) {
    final min = math.log(ViewportController.minZoom);
    final max = math.log(ViewportController.maxZoom);
    return math.exp(min + slider * (max - min));
  }
}

/// Puts the drawing on the system clipboard, ready to paste into a chat, a
/// document or anything else.
///
/// It sits in the corner rather than only in the Edit menu because the common
/// reason to open this editor at all is to sketch something quickly and paste
/// it somewhere; burying that behind a menu makes the fastest path the least
/// discoverable one. The work is delegated to [AppActions.copy], so the button,
/// the menu item and Ctrl+C are one implementation.
class CopyToClipboardButton extends StatefulWidget {
  const CopyToClipboardButton({super.key});

  /// How long the button stays in its confirming state.
  static const Duration confirmationDuration = Duration(seconds: 2);

  @override
  State<CopyToClipboardButton> createState() => _CopyToClipboardButtonState();
}

class _CopyToClipboardButtonState extends State<CopyToClipboardButton> {
  bool _copied = false;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    final copied = await AppActions(context).copy();
    // A failed copy reports itself through a message; confirming here too would
    // contradict it.
    if (!mounted || !copied) return;
    // Confirming in place rather than with a snack bar: a snack bar would cover
    // this corner of the window, and the feedback belongs on the control that
    // was pressed.
    setState(() => _copied = true);
    _reset?.cancel();
    _reset = Timer(CopyToClipboardButton.confirmationDuration, () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final hasSelection = context.watch<SelectionController>().hasSelection;

    return Tooltip(
      message: hasSelection ? l10n.copySelectionTooltip : l10n.copyImageTooltip,
      child: TextButton.icon(
        onPressed: _copy,
        icon: Icon(
          _copied ? Icons.check : Icons.content_copy_outlined,
          size: 15,
          color: _copied ? scheme.primary : null,
        ),
        label: Text(
          _copied ? l10n.copiedToClipboard : l10n.actionCopyToClipboard,
          style: TextStyle(
            fontSize: 12,
            color: _copied ? scheme.primary : null,
          ),
        ),
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 26),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }
}
