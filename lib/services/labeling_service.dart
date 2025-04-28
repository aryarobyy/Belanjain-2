// import 'dart:ui' as ui;
//
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
//
// class LabelingService extends CustomPainter {
//   LabelingService(this.labels);
//
//   final List<ImageLabel> labels;
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final ui.ParagraphBuilder builder = ui.ParagraphBuilder(
//       ui.ParagraphStyle(
//           textAlign: TextAlign.left,
//           fontSize: 23,
//           textDirection: TextDirection.ltr),
//     );
//
//     builder.pushStyle(ui.TextStyle(color: Colors.green));
//     for (final ImageLabel label in labels) {
//       builder.addText('Label: ${label.label}, '
//           'Confidence: ${label.confidence.toStringAsFixed(2)}\n');
//     }
//     builder.pop();
//
//     canvas.drawParagraph(
//       builder.build()
//         ..layout(ui.ParagraphConstraints(
//           width: size.width,
//         )),
//       const Offset(0, 0),
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return oldDelegate != labels;
//   }
// }