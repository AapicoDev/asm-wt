import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

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

  @override
  void initState() {
    super.initState();
    images = List.filled(widget.imageCount, "Add Image");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      child: buildGridView(),
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
                    Image.file(
                      uploadModel.imageFile!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.scaleDown,
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
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      // Optimize the image before setting it
      File optimizedImage = await _optimizeImage(File(image.path));
      setState(() {
        images[index] = ImageUploadModel(imageFile: optimizedImage);
        _updateImages();
      });
    }
  }

  // Optimize image by resizing and compressing it
  Future<File> _optimizeImage(File imageFile) async {
    final Uint8List imageBytes = await imageFile.readAsBytes();
    img.Image? decodedImage = img.decodeImage(imageBytes);

    if (decodedImage != null) {
      // Resize the image to a maximum width/height (e.g., 800px)
      img.Image resizedImage = img.copyResize(decodedImage, width: 800);

      // Encode the image to reduce file size (jpeg quality 85)
      Uint8List optimizedBytes =
          Uint8List.fromList(img.encodeJpg(resizedImage, quality: 85));

      // Save the optimized image to a temporary file
      final String tempPath =
          '${imageFile.parent.path}/optimized_${imageFile.path.split('/').last}';
      final File optimizedFile =
          await File(tempPath).writeAsBytes(optimizedBytes);

      return optimizedFile;
    }

    return imageFile;
  }

  void _updateImages() {
    List<ImageUploadModel> updatedImages = images
        .where((image) => image is ImageUploadModel)
        .cast<ImageUploadModel>()
        .toList();
    widget.onImagesUpdated(updatedImages);
  }
}
