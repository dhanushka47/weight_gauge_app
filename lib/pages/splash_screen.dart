import 'dart:async';
import 'package:flutter/material.dart';
import '../dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    );

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: const Size(200, 200),
              painter: FilamentPainter(progress: _controller),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  Icon(Icons.print, color: Colors.amber, size: 40),
                  const SizedBox(height: 8),
                  Icon(Icons.receipt_long, color: Colors.amber, size: 40),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Weight Gauge',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FilamentPainter extends CustomPainter {
  final Animation<double> progress;

  FilamentPainter({required this.progress}) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    // Flutter version of the SVG filament path
    path.moveTo(100, 40);
    path.lineTo(100, 80);
    path.cubicTo(100, 100, 60, 100, 60, 130);
    path.quadraticBezierTo(100, 160, 140, 180);
    path.lineTo(60, 180);

    final paint = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Animate the path drawing
    final metrics = path.computeMetrics();
    final drawPath = Path();
    for (var metric in metrics) {
      final length = metric.length * progress.value;
      drawPath.addPath(metric.extractPath(0, length), Offset.zero);
    }

    canvas.drawPath(drawPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
