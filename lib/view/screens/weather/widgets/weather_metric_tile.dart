import 'dart:math';

import 'package:flutter/material.dart';
import 'package:weather_test/theme/weather_theme.dart';
import 'package:weather_test/widgets/widgets.dart';

enum WeatherMetricVisual { none, wind, pressure, visibility, sunrise, sunset }

class WeatherMetricTile extends StatelessWidget {
  const WeatherMetricTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.accent = WeatherTheme.primarySky,
    this.progress,
    this.progressKey,
    this.visual = WeatherMetricVisual.none,
    this.visualKey,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final double? progress;
  final Key? progressKey;
  final WeatherMetricVisual visual;
  final Key? visualKey;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return WeatherGlassCard(
      padding: const EdgeInsets.all(14),
      child: SizedBox(
        height: 156,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accent, size: 22),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelLarge?.copyWith(
                      color: WeatherTheme.onGlassPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (visual != WeatherMetricVisual.none) ...[
              Center(
                  child: _MetricVisual(visual: visual, visualKey: visualKey)),
              const SizedBox(height: 12),
            ],
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: textTheme.headlineSmall?.copyWith(
                  color: WeatherTheme.onGlassPrimary,
                  fontWeight: FontWeight.w900,
                  height: 0.95,
                ),
              ),
            ),
            if (progress != null) ...[
              const SizedBox(height: 12),
              _HumidityProgressBar(
                key: progressKey,
                value: progress!.clamp(0, 1).toDouble(),
                accent: accent,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricVisual extends StatelessWidget {
  const _MetricVisual({required this.visual, required this.visualKey});

  final WeatherMetricVisual visual;
  final Key? visualKey;

  @override
  Widget build(BuildContext context) {
    return switch (visual) {
      WeatherMetricVisual.wind => SizedBox.square(
          dimension: 58,
          child: CustomPaint(
            key: visualKey,
            painter: _WindGaugePainter(),
          ),
        ),
      WeatherMetricVisual.pressure => SizedBox(
          width: 88,
          height: 42,
          child: CustomPaint(
            key: visualKey,
            painter: _PressureGaugePainter(),
          ),
        ),
      WeatherMetricVisual.visibility => SizedBox(
          width: 92,
          height: 42,
          child: CustomPaint(
            key: visualKey,
            painter: _VisibilityRangePainter(),
          ),
        ),
      WeatherMetricVisual.sunrise => SizedBox(
          width: 92,
          height: 42,
          child: CustomPaint(
            key: visualKey,
            painter: _SunPathPainter(isSunrise: true),
          ),
        ),
      WeatherMetricVisual.sunset => SizedBox(
          width: 92,
          height: 42,
          child: CustomPaint(
            key: visualKey,
            painter: _SunPathPainter(isSunrise: false),
          ),
        ),
      WeatherMetricVisual.none => const SizedBox.shrink(),
    };
  }
}

class _HumidityProgressBar extends StatelessWidget {
  const _HumidityProgressBar({
    super.key,
    required this.value,
    required this.accent,
  });

  final double value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0, 1).toDouble();

    return Container(
      height: 13,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: WeatherTheme.onGlassSecondary.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: WeatherTheme.onGlassPrimary.withValues(alpha: 0.2),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          FractionallySizedBox(
            key: const ValueKey('humidity-progress-fill'),
            widthFactor: clampedValue,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: [
                    WeatherTheme.onGlassPrimary.withValues(alpha: 0.88),
                    accent.withValues(alpha: 0.94),
                    const Color(0xFF67E8F9),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.34),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment(clampedValue * 2 - 1, 0),
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: WeatherTheme.onGlassPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: WeatherTheme.twilight.withValues(alpha: 0.18),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisibilityRangePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height * 0.56;
    final hazePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = WeatherTheme.onGlassSecondary.withValues(alpha: 0.46);

    for (var i = 0; i < 3; i += 1) {
      final y = centerY - 12 + i * 12;
      canvas.drawLine(
        Offset(10 + i * 8, y),
        Offset(size.width - 10 - i * 8, y),
        hazePaint,
      );
    }

    final horizonPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = WeatherTheme.onGlassPrimary.withValues(alpha: 0.58);
    canvas.drawLine(
      Offset(12, size.height - 7),
      Offset(size.width - 12, size.height - 7),
      horizonPaint,
    );

    final markerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = WeatherTheme.rainAccent.withValues(alpha: 0.9);
    final marker = Path()
      ..moveTo(size.width * 0.5, 8)
      ..quadraticBezierTo(size.width * 0.64, 20, size.width * 0.5, 33)
      ..quadraticBezierTo(size.width * 0.36, 20, size.width * 0.5, 8)
      ..close();
    canvas.drawPath(marker, markerPaint);

    canvas.drawCircle(
      Offset(size.width * 0.5, 20),
      5,
      Paint()
        ..style = PaintingStyle.fill
        ..color = WeatherTheme.onGlassPrimary.withValues(alpha: 0.88),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WindGaugePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 9;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = WeatherTheme.onGlassSecondary.withValues(alpha: 0.72);

    canvas.drawCircle(center, radius, ringPaint);

    final accentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = WeatherTheme.rainAccent.withValues(alpha: 0.46);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.7,
      1.1,
      false,
      accentPaint,
    );

    final needlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = WeatherTheme.onGlassPrimary;
    final needle = Path()
      ..moveTo(center.dx - radius + 3, center.dy)
      ..lineTo(center.dx - radius + 17, center.dy - 8)
      ..lineTo(center.dx - radius + 14, center.dy + 8)
      ..close();
    canvas.drawPath(needle, needlePaint);

    _drawDirection(canvas, size, 'N', center.translate(0, -radius + 7));
    _drawDirection(canvas, size, 'E', center.translate(radius - 7, 0));
    _drawDirection(canvas, size, 'S', center.translate(0, radius - 7));
    _drawDirection(canvas, size, 'W', center.translate(-radius + 7, 0));
  }

  void _drawDirection(Canvas canvas, Size size, String text, Offset center) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: WeatherTheme.onGlassPrimary,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PressureGaugePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(8, 6, size.width - 16, size.height * 1.45);
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = WeatherTheme.onGlassSecondary.withValues(alpha: 0.5);
    final valuePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = WeatherTheme.onGlassPrimary.withValues(alpha: 0.72);

    canvas.drawArc(rect, 3.05, 3.15, false, trackPaint);
    canvas.drawArc(rect, 3.05, 2.15, false, valuePaint);

    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = WeatherTheme.onGlassPrimary.withValues(alpha: 0.54);

    for (var i = 0; i <= 22; i++) {
      final angle = 3.05 + (3.15 / 22) * i;
      final outer = Offset(
        rect.center.dx + (rect.width / 2 + 1) * cos(angle),
        rect.center.dy + (rect.height / 2 + 1) * sin(angle),
      );
      final inner = Offset(
        rect.center.dx + (rect.width / 2 - 6) * cos(angle),
        rect.center.dy + (rect.height / 2 - 6) * sin(angle),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SunPathPainter extends CustomPainter {
  const _SunPathPainter({required this.isSunrise});

  final bool isSunrise;

  @override
  void paint(Canvas canvas, Size size) {
    final horizonY = size.height - 9;
    final horizonPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = WeatherTheme.onGlassSecondary.withValues(alpha: 0.58);

    canvas.drawLine(
      Offset(8, horizonY),
      Offset(size.width - 8, horizonY),
      horizonPaint,
    );

    final pathRect = Rect.fromLTWH(13, 6, size.width - 26, size.height + 12);
    final pathPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [
          WeatherTheme.onGlassPrimary.withValues(alpha: 0.42),
          WeatherTheme.sunnyAccent.withValues(alpha: 0.9),
          WeatherTheme.rainAccent.withValues(alpha: 0.46),
        ],
      ).createShader(pathRect);

    canvas.drawArc(pathRect, pi, pi, false, pathPaint);

    final sunCenter = isSunrise
        ? Offset(size.width * 0.36, horizonY - 15)
        : Offset(size.width * 0.66, horizonY - 6);
    final sunPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isSunrise
          ? WeatherTheme.sunnyAccent
          : WeatherTheme.onGlassMuted.withValues(alpha: 0.92);

    canvas.drawCircle(sunCenter, 8, sunPaint);
    canvas.drawCircle(
      sunCenter,
      14,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = sunPaint.color.withValues(alpha: 0.22),
    );
  }

  @override
  bool shouldRepaint(covariant _SunPathPainter oldDelegate) {
    return oldDelegate.isSunrise != isSunrise;
  }
}
