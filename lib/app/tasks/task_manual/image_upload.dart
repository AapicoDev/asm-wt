import 'dart:io';
import 'package:asm_wt/app/tasks/task_manual/task_manual_controller.dart';
import 'package:asm_wt/app/tasks/task_manual/watermark_image.dart';
import 'package:asm_wt/models/location_model.dart';
import 'package:asm_wt/util/full_screen_image.dart';
import 'package:asm_wt/util/get_location.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ImageUploadModel {
  File? imageFile;
  String imageUrl;
  bool isUploaded;
  bool uploading;

  ImageUploadModel({
    this.imageFile,
    this.imageUrl = '',
    this.isUploaded = false,
    this.uploading = false,
  });
}

class SingleImageUpload extends StatefulWidget {
  final List<String> labels;
  final int imageCount;
  final Function(List<ImageUploadModel>) onImagesUpdated;

  const SingleImageUpload({
    Key? key,
    required this.labels,
    required this.imageCount,
    required this.onImagesUpdated,
  }) : super(key: key);

  @override
  _SingleImageUploadState createState() => _SingleImageUploadState();
}

class _SingleImageUploadState extends State<SingleImageUpload> {
  late List<dynamic> images;
  final ImagePicker _picker = ImagePicker();
  LocationModel? locationdata;
  bool isLoading = false; // Loading state

  @override
  void initState() {
    super.initState();
    images = List.filled(widget.imageCount, "Add Image");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      child: Stack(
        children: [
          buildGridView(),
          if (isLoading) // Show the loading indicator when isLoading is true
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget buildGridView() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: widget.imageCount,
      childAspectRatio: 1,
      children: List.generate(images.length, (index) {
        if (images[index] is ImageUploadModel) {
          ImageUploadModel uploadModel = images[index] as ImageUploadModel;
          return Column(
            children: [
              Text(widget.labels[index]),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        FullscreenImageViewer.show(
                            context, uploadModel.imageFile!.path,
                            isLocalFile: true);
                      },
                      child: Image.file(
                        uploadModel.imageFile!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    Positioned(
                      right: 5,
                      top: 5,
                      child: InkWell(
                        child: const Icon(
                          Icons.remove_circle,
                          size: 20,
                          color: Colors.red,
                        ),
                        onTap: () {
                          setState(() {
                            images[index] = "Add Image";
                            _updateImages();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              Text(widget.labels[index]),
              Container(
                height: 120,
                width: 120,
                child: Card(
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _onAddImageClick(index),
                  ),
                ),
              ),
            ],
          );
        }
      }),
    );
  }

  Future<void> _onAddImageClick(int index) async {
    setState(() {
      isLoading = true; // Set loading to true when starting the process
    });

    var cameraDevice = index != 1 ? CameraDevice.front : CameraDevice.rear;
    debugPrint("index: $cameraDevice");
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: cameraDevice,
    );
    Position? position = await getCurrentLocation();
    if (position != null) {
      print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
      // check location's name
      final taskProvider =
          Provider.of<TaskManualProvider>(context, listen: false);
      locationdata =
          await taskProvider.getAreaName(position.latitude, position.longitude);
    } else {
      print("Location could not be retrieved");
    }

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
    if (image != null) {
      var locationString = '${position?.latitude}, ${position?.longitude}';
      File waterMarkImage = await drawOnXFile(image,
          '${locationdata != null ? locationdata!.nameTh + "\n🌏 " + locationString : locationString}\n⏰ ${formattedDate}');
      File optimizedImage = await _optimizeImage(waterMarkImage);

      setState(() {
        images[index] = ImageUploadModel(imageFile: optimizedImage);
        _updateImages();
        isLoading = false; // Set loading to false after the image is processed
      });
    } else {
      setState(() {
        isLoading = false; // Set loading to false if no image is selected
      });
    }
  }

  // // Optimize image by resizing and compressing it
  // Future<File> _optimizeImage(File imageFile) async {
  //   final Uint8List imageBytes = await imageFile.readAsBytes();
  //   img.Image? decodedImage = img.decodeImage(imageBytes);

  //   if (decodedImage != null) {
  //     // Resize the image to a maximum width/height (e.g., 800px)
  //     img.Image resizedImage = img.copyResize(decodedImage, width: 800);

  //     // Encode the image to reduce file size (jpeg quality 85)
  //     Uint8List optimizedBytes =
  //         Uint8List.fromList(img.encodeJpg(resizedImage, quality: 85));

  //     // Save the optimized image to a temporary file
  //     final String tempPath =
  //         '${imageFile.parent.path}/optimized_${imageFile.path.split('/').last}';
  //     final File optimizedFile =
  //         await File(tempPath).writeAsBytes(optimizedBytes);

  //     return optimizedFile;
  //   }

  //   return imageFile;
  // }

  Future<File> _optimizeImage(File imageFile) async {
    final Uint8List? result = await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      minWidth: 800,
      minHeight: 800,
      quality: 85,
      rotate: 0,
    );
    final File optimizedFile = await File(imageFile.parent.path +
            '/optimized_${imageFile.uri.pathSegments.last}')
        .writeAsBytes(result!);
    return optimizedFile;
  }

  void _updateImages() {
    List<ImageUploadModel> updatedImages = images
        .where((image) => image is ImageUploadModel)
        .cast<ImageUploadModel>()
        .toList();
    widget.onImagesUpdated(updatedImages);
  }
}
