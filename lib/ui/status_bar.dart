import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/canvas_controller.dart';
import '../controller/document_controller.dart';
import '../controller/viewport_controller.dart';
import '../core/theme/app_theme.dart';
import '../l10n/generated/app_localizations.dart';

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
