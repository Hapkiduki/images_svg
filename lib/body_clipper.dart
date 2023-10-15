import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class BodyClipper extends CustomClipper<Path> {
  final String stringPath;

  const BodyClipper(this.stringPath);

  @override
  Path getClip(Size size) {
    final path = parseSvgPathData(stringPath);
    final Matrix4 matrix4 = Matrix4.rotationZ(1);
    matrix4.scale(.4, .4);
    return path.transform(matrix4.storage).shift(
          Offset(size.width * .66, -size.height * .2),
        );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
