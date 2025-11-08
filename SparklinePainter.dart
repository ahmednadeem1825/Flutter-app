import 'package:flutter/material.dart';
import 'dart:math';

class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  SparklinePainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    double maxY = data.reduce(max);
    double minY = data.reduce(min);

    final normalized = data.map((e) {
      if (maxY == minY) return 0.5;
      return (e - minY) / (maxY - minY);
    }).toList();

    final dx = size.width / (normalized.length - 1);

    for (int i = 0; i < normalized.length; i++) {
      final x = i * dx;
      final y = size.height * (1 - normalized[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
