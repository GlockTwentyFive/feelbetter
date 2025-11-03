import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

const _size = 1024;
final _backgroundColor = img.ColorRgba8(0, 0, 0, 0);
final _foregroundColor = img.ColorRgba8(225, 0, 30, 255);

void main() {
  final image = img.Image(width: _size, height: _size, numChannels: 4);
  img.fill(image, color: _backgroundColor);

  _drawHeart(image);
  _drawRays(image);

  final output = File('assets/icon/app_icon.png');
  output.parent.createSync(recursive: true);
  output.writeAsBytesSync(img.encodePng(image));
  stdout.writeln('Generated ${output.path}');
}

void _drawHeart(img.Image image) {
  final points = <img.Point>[];
  for (int i = 0; i < 720; i++) {
    final t = i / 720 * 2 * pi;
    final x = 16 * pow(sin(t), 3);
    final y = 13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t);

    final nx = (x + 16) / 32; // 0..1
    final ny = (y + 17) / 34; // 0..1 (approx range of formula)

    final px = ((nx * 0.72) + 0.14) * _size;
    final py = ((1 - ny) * 0.70 + 0.20) * _size;
    points.add(img.Point(px.round(), py.round()));
  }

  img.fillPolygon(image, vertices: points, color: _foregroundColor);
}

void _drawRays(img.Image image) {
  final centerX = _size / 2;
  final centerY = _size * 0.42;
  final innerRadius = _size * 0.35;
  final outerRadiusLong = _size * 0.49;
  final outerRadiusShort = _size * 0.44;
  final rayAngles = <double>[];

  for (int i = 0; i < 24; i++) {
    rayAngles.add(i * (360 / 24));
  }

  for (int i = 0; i < rayAngles.length; i++) {
    final angle = rayAngles[i] * pi / 180;
    final isLong = i % 2 == 0;
    final outerRadius = isLong ? outerRadiusLong : outerRadiusShort;

    final startX = centerX + innerRadius * cos(angle);
    final startY = centerY + innerRadius * sin(angle);
    final endX = centerX + outerRadius * cos(angle);
    final endY = centerY + outerRadius * sin(angle);

    img.drawLine(image,
        x1: startX.round(),
        y1: startY.round(),
        x2: endX.round(),
        y2: endY.round(),
        color: _foregroundColor,
        thickness: isLong ? 18 : 12);
  }
}
