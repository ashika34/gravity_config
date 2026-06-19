import 'package:flutter/material.dart';

class CommonWaveDesign extends StatelessWidget {
  final double heightFactor;
  final double minHeight;
  final double maxHeight;

  const CommonWaveDesign({
    super.key,
    this.heightFactor = 0.22,
    this.minHeight = 120,
    this.maxHeight = 240,
  });

  @override
  Widget build(BuildContext context) {
    final height = (MediaQuery.sizeOf(context).height * heightFactor)
        .clamp(minHeight, maxHeight)
        .toDouble();
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _CommonWavePainter()),
      ),
    );
  }
}

class _CommonWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paleWave = Paint()..color = const Color(0xFFFFDDE2).withAlpha(202);
    final midWave = Paint()..color = const Color(0xFFFFC0C9).withAlpha(184);
    final deepWave = Paint()..color = const Color(0xFFFFA7B3).withAlpha(174);

    final palePath = Path()
      ..moveTo(0, size.height * 0.12)
      ..cubicTo(
        size.width * 0.22,
        size.height * -0.02,
        size.width * 0.36,
        size.height * 0.48,
        size.width * 0.56,
        size.height * 0.30,
      )
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.12,
        size.width * 0.88,
        size.height * 0.04,
        size.width,
        size.height * 0.14,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(palePath, paleWave);

    final midPath = Path()
      ..moveTo(0, size.height * 0.44)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.16,
        size.width * 0.44,
        size.height * 0.48,
        size.width * 0.62,
        size.height * 0.51,
      )
      ..cubicTo(
        size.width * 0.82,
        size.height * 0.54,
        size.width * 0.91,
        size.height * 0.40,
        size.width,
        size.height * 0.08,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(midPath, midWave);

    final deepPath = Path()
      ..moveTo(0, size.height * 0.70)
      ..cubicTo(
        size.width * 0.23,
        size.height * 0.56,
        size.width * 0.40,
        size.height * 0.64,
        size.width * 0.58,
        size.height * 0.84,
      )
      ..cubicTo(
        size.width * 0.75,
        size.height * 1.04,
        size.width * 0.88,
        size.height * 1.00,
        size.width,
        size.height * 0.88,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(deepPath, deepWave);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
