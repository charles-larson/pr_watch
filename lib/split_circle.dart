import 'package:flutter/material.dart';

class SplitCircle extends StatelessWidget {
  final Color colorLeft;
  final Color colorRight;
  final bool showStar;

  const SplitCircle({
    Key? key,
    required this.colorLeft,
    required this.colorRight,
    this.showStar = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(20, 20),
          painter: _SplitCirclePainter(
            colorLeft: colorLeft,
            colorRight: colorRight,
          ),
        ),
        if (showStar)
          const Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.star,
              color: Colors.black,
              size: 16,
            ),
          ),
      ],
    );
  }
}

class _SplitCirclePainter extends CustomPainter {
  final Color colorLeft;
  final Color colorRight;

  _SplitCirclePainter({
    required this.colorLeft,
    required this.colorRight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    drawLeftHalfCircle(canvas, size, colorLeft);
    drawRightHalfCircle(canvas, size, colorRight);
  }

  void drawLeftHalfCircle(Canvas canvas, Size size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();

    path.moveTo(size.width / 2, 0);
    path.arcToPoint(
      Offset(size.width / 2, size.height),
      radius: Radius.circular(size.width / 2),
      clockwise: false,
    );
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width / 2, 0);

    canvas.drawPath(path, paint);
  }

  void drawRightHalfCircle(Canvas canvas, Size size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();

    path.moveTo(size.width / 2, 0);
    path.arcToPoint(
      Offset(size.width / 2, size.height),
      radius: Radius.circular(size.width / 2),
      clockwise: true,
    );
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width / 2, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
