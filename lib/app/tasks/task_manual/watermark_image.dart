import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For XFile
import 'package:path_provider/path_provider.dart'; // For saving file
import 'package:flutter/services.dart'; // For byte data handling
import 'package:uuid/uuid.dart'; // To generate unique identifiers

Future<File> drawOnXFile(XFile xFile, String watermarkText) async {
  // Load the XFile as ui.Image
  final Uint8List bytes = await xFile.readAsBytes();
  final ui.Image image = await decodeImageFromList(bytes);

  // Create a PictureRecorder and Canvas to record the drawing
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(
    recorder,
    Rect.fromPoints(
        Offset.zero, Offset(image.width.toDouble(), image.height.toDouble())),
  );

  // Draw the original image
  canvas.drawImage(image, Offset.zero, Paint());

  // Now, draw additional things like a rectangle or text
  // var backgroundPaint = Paint()..color = Colors.white;
  // Draw a red rectangle
  // canvas.drawRect(Rect.fromLTWH(50, 50, 1300, 400), backgroundPaint);

  // Draw text
  var textPainter = TextPainter(
    text: TextSpan(
      text: watermarkText,
      style: TextStyle(
        fontSize: 65,
        // Stroke effect
        foreground: Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.0, // Stroke effect
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(canvas, Offset(60, 60));

  // Finish recording and create an Image
  final ui.Picture picture = recorder.endRecording();
  final ui.Image newImage = await picture.toImage(image.width, image.height);

  // Convert the ui.Image to bytes (PNG format)
  final ByteData? byteData =
      await newImage.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List pngBytes = byteData!.buffer.asUint8List();

  // Get app directory
  final Directory directory = await getApplicationDocumentsDirectory();

  // Generate a unique filename
  final String uniqueId = Uuid().v4(); // Generate a unique identifier
  final String filePath =
      '${directory.path}/modified_image_$uniqueId.png'; // Unique file path
  final File file = File(filePath);

  // Write the bytes to the file
  await file.writeAsBytes(pngBytes);

  // Return the File object
  return file;
}
