import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../controller/viewport_controller.dart';
import '../core/theme/app_theme.dart';
import '../model/paint_document.dart';
import '../model/selection.dart';
import '../tools/tool.dart';

/// Draws the document, the transparency checkerboard and the live tool preview.
class CanvasPainter extends CustomPainter {
  CanvasPainter({
    required this.document,
    required this.viewport,
    required this.gesture,
    required this.selection,
    required this.colors,
    required Listenable repaint,
  }) : super(repaint: repaint);

  /// Size of one checkerboard square on screen. Fixed in screen space so the
  /// pattern reads as "behind the image" rather than as image content.
  static const double checkerSize = 8;

  final PaintDocument document;
  final ViewportController viewport;
  final ToolGesture? gesture;
  final Selection? selection;
  final CanvasColors colors;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawRect(ui.Offset.zero & size, ui.Paint()..color = colors.backdrop);

    final imageRect = viewport.imageScreenRect;
    if (imageRect.isEmpty) return;

    _paintCheckerboard(canvas, imageRect);

    final zoom = viewport.zoom;
    // Crisp pixels once magnified — a paint program that blurs at 800% is
    // unusable for touching up individual pixels.
    final filterQuality = zoom >= 1
        ? ui.FilterQuality.none
        : ui.FilterQuality.medium;

    canvas.save();
    canvas.clipRect(imageRect);
    canvas.translate(viewport.origin.dx, viewport.origin.dy);
    canvas.scale(zoom);

    final documentRect = document.bounds;
    // The layer isolates the preview so an eraser stroke, which composites with
    // BlendMode.clear, punches through the image instead of the checkerboard.
    canvas.saveLayer(documentRect, ui.Paint());
    for (final layer in document.layers) {
      if (!layer.visible) continue;
      canvas.drawImage(
        layer.image,
        ui.Offset.zero,
        ui.Paint()
          ..filterQuality = filterQuality
          ..color = ui.Color.fromRGBO(0, 0, 0, layer.opacity),
      );
    }
    gesture?.draw(canvas);
    _paintFloatingSelection(canvas);
    canvas.restore();

    // Overlays are chrome, not pixels: outside the layer so they are never
    // affected by the preview's blend mode and never end up committed.
    gesture?.drawOverlay(canvas, zoom);
    _paintSelectionOutline(canvas, zoom);

    canvas.restore();

    canvas.drawRect(
      imageRect.deflate(0.5),
      ui.Paint()
        ..color = colors.canvasBorder
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  /// Lifted selection pixels, drawn wherever the selection has been dragged to.
  void _paintFloatingSelection(ui.Canvas canvas) {
    final current = selection;
    final floating = current?.floating;
    if (current == null || floating == null) return;
    canvas.drawImageRect(
      floating,
      ui.Rect.fromLTWH(
        0,
        0,
        floating.width.toDouble(),
        floating.height.toDouble(),
      ),
      current.currentBounds,
      ui.Paint()..filterQuality = ui.FilterQuality.medium,
    );
  }

  /// Marching ants plus resize handles.
  ///
  /// The outline is drawn twice — a dark dashed line over a light solid one —
  /// so it stays visible over both light and dark image content.
  void _paintSelectionOutline(ui.Canvas canvas, double zoom) {
    final current = selection;
    if (current == null || current.isEmpty) return;

    final path = current.transformedPath;
    final width = 1 / zoom;

    canvas.drawPath(
      path,
      ui.Paint()
        ..color = colors.marchingAntsLight
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = width * 2,
    );
    canvas.drawPath(
      _dashed(path, 4 / zoom),
      ui.Paint()
        ..color = colors.marchingAntsDark
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = width * 2,
    );

    final handleSize = 7 / zoom;
    final bounds = current.currentBounds;
    for (final handle in SelectionHandle.values) {
      final centre = ui.Offset(
        bounds.left + bounds.width * handle.anchor.dx,
        bounds.top + bounds.height * handle.anchor.dy,
      );
      final rect = ui.Rect.fromCenter(
        center: centre,
        width: handleSize,
        height: handleSize,
      );
      canvas.drawRect(rect, ui.Paint()..color = colors.handleFill);
      canvas.drawRect(
        rect,
        ui.Paint()
          ..color = colors.handleBorder
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = width,
      );
    }
  }

  /// Splits [source] into dashes of [dashLength], leaving equal gaps.
  static ui.Path _dashed(ui.Path source, double dashLength) {
    final result = ui.Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final next = distance + dashLength;
        if (draw) {
          result.addPath(
            metric.extractPath(distance, next.clamp(0, metric.length)),
            ui.Offset.zero,
          );
        }
        distance = next;
        draw = !draw;
      }
    }
    return result;
  }

  void _paintCheckerboard(ui.Canvas canvas, ui.Rect imageRect) {
    canvas.save();
    canvas.clipRect(imageRect);
    canvas.drawRect(imageRect, ui.Paint()..color = colors.checkerLight);

    final dark = ui.Paint()..color = colors.checkerDark;
    // Anchor the pattern to the image origin so it does not crawl while
    // panning.
    final startX =
        imageRect.left -
        (imageRect.left - viewport.origin.dx) % (checkerSize * 2);
    final startY =
        imageRect.top -
        (imageRect.top - viewport.origin.dy) % (checkerSize * 2);

    for (var y = startY; y < imageRect.bottom; y += checkerSize) {
      final rowOdd = (((y - startY) / checkerSize).round() % 2) == 1;
      for (
        var x = startX + (rowOdd ? checkerSize : 0);
        x < imageRect.right;
        x += checkerSize * 2
      ) {
        canvas.drawRect(ui.Rect.fromLTWH(x, y, checkerSize, checkerSize), dark);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) {
    return oldDelegate.document != document ||
        oldDelegate.gesture != gesture ||
        oldDelegate.selection != selection ||
        oldDelegate.colors != colors;
  }
}
