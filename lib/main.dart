import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final canvasSize = const Size(300, 300);

  final numPoints = 100;

  final steps = 4000;

  final r = 0.1;

  late var initialRandom = List<List<double>>.generate(
    numPoints,
    (i) => List<double>.generate(
      numPoints,
      (j) => i == 0 || i == numPoints - 1 || j == 0 || j == numPoints - 1 ? 0 : Random().nextDouble() * 50,
    ),
  );

  late var initialMiddle = List<List<double>>.generate(
    numPoints,
    (i) => List<double>.generate(
      numPoints,
      (j) => i == 0 || i == numPoints - 1 || j == 0 || j == numPoints - 1
          ? 0
          : i > numPoints / 4 && i < 3 * numPoints / 4 && j > numPoints / 4 && j < 3 * numPoints / 4
              ? 50
              : 0,
    ),
  );

  late var initial = initialMiddle;

  late final newState = List<List<double>>.from(initial);

  void blur() async {
    for (int t = 0; t < steps; t++) {
      for (int i = 1; i < numPoints - 1; i++) {
        for (int j = 1; j < numPoints - 1; j++) {
          newState[i][j] = (initial[i - 1][j] + initial[i + 1][j] + initial[i][j - 1] + initial[i][j + 1]) / 4;
        }
      }
      setState(() {
        initial = newState;
      });
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  void heat() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    // final hx = canvasSize.width / numPoints;
    // const ht = 0.1;
    // const kc = 1;
    // final r = (ht * kc) / (hx * hx);

    for (int t = 0; t < steps; t++) {
      for (int i = 1; i < numPoints - 1; i++) {
        for (int j = 1; j < numPoints - 1; j++) {
          newState[i][j] =
              initial[i][j] + r * (initial[i][j + 1] + initial[i + 1][j] + initial[i][j - 1] + initial[i - 1][j] - 4 * initial[i][j]);
        }
      }
      setState(() {
        initial = newState;
      });
      await Future.delayed(const Duration(milliseconds: 5));
    }
    print('Done');
  }

  @override
  void initState() {
    super.initState();

    // blur.call();
    heat();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: canvasSize.height,
        width: canvasSize.width,
        child: CustomPaint(
          painter: HeatPainter(
            canvasSize: canvasSize,
            numPoints: numPoints,
            initial: initial,
          ),
        ),
      ),
    );
  }
}

class HeatPainter extends CustomPainter {
  HeatPainter({
    required this.canvasSize,
    required this.numPoints,
    required this.initial,
  });

  final Size canvasSize;

  final int numPoints;

  final List<List<double>> initial;

  @override
  void paint(Canvas canvas, Size size) {
    const alpha = 2.0;
    const deltaX = 1.0;
    const deltaT = (deltaX * deltaX) / (4 * alpha);
    const gamma = (alpha * deltaT) / (deltaX * deltaX);

    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < numPoints; i++) {
      for (int j = 0; j < numPoints; j++) {
        final x = i * canvasSize.width / numPoints;
        final y = j * canvasSize.height / numPoints;
        final point = Offset(x, y);

        paint.color = Color.fromRGBO((255 * (initial[i][j] / 50)).toInt(), 0, 255 - (255 * (initial[i][j] / 50)).toInt(), 1);
        canvas.drawCircle(point, 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant HeatPainter oldDelegate) {
    return true;
  }
}
