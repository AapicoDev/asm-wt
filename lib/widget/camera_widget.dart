// import 'dart:io';

// import 'package:asm_wt/app/tasks/check_In/check_In_view.dart';
// import 'package:asm_wt/assets/static_data.dart';
// import 'package:asm_wt/util/custom_func.dart';
// import 'package:asm_wt/widget/app_bar_widget.dart';
// import 'package:asm_wt/widget/button_widget.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// // ignore: depend_on_referenced_packages
// import 'package:camera/camera.dart';
// import 'package:flutter_translate/flutter_translate.dart';

// int step = 1;
// List<XFile> takenPhotos = [];

// class CameraWidget extends StatefulWidget {
//   final List<CameraDescription>? cameras;

//   const CameraWidget({Key? key, this.cameras}) : super(key: key);
//   @override
//   State<CameraWidget> createState() => _CameraWidgetState();
// }

// class _CameraWidgetState extends State<CameraWidget> {
//   late CameraController _cameraController;
//   bool _isRearCameraSelected = true;

//   Future initCamera(CameraDescription cameraDescription) async {
// // create a CameraController
//     _cameraController =
//         CameraController(cameraDescription, ResolutionPreset.high);
// // Next, initialize the controller. This returns a Future.
//     try {
//       await _cameraController.initialize().then((_) {
//         if (!mounted) return;
//         setState(() {});
//       });
//     } on CameraException catch (e) {
//       debugPrint("camera error $e");
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     // initialize the rear camera
//     initCamera(widget.cameras![0]);
//   }

//   @override
//   void dispose() {
//     // Dispose of the controller when the widget is disposed.
//     _cameraController.dispose();
//     super.dispose();
//   }

//   Future takePicture() async {
//     if (!_cameraController.value.isInitialized) {
//       return null;
//     }
//     if (_cameraController.value.isTakingPicture) {
//       return null;
//     }
//     try {
//       await _cameraController.setFlashMode(FlashMode.off);
//       XFile picture = await _cameraController.takePicture();
//       // ignore: use_build_context_synchronously
//       Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) => PreviewPage(
//                     picture: picture,
//                   )));
//     } on CameraException catch (e) {
//       debugPrint('Error occured while taking picture: $e');
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     var theme = Theme.of(context);

//     return Scaffold(
//         body: SafeArea(
//       child: Stack(children: [
//         (_cameraController.value.isInitialized)
//             ? CameraPreview(_cameraController)
//             : Container(
//                 color: Colors.black,
//                 child: const Center(child: CircularProgressIndicator())),
//         Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               height: MediaQuery.of(context).size.height * 0.20,
//               decoration: const BoxDecoration(
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//                   color: Colors.black),
//               child:
//                   Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
//                 Expanded(
//                     child: IconButton(
//                   padding: EdgeInsets.zero,
//                   iconSize: 30,
//                   icon: Icon(
//                       _isRearCameraSelected
//                           ? CupertinoIcons.switch_camera
//                           : CupertinoIcons.switch_camera_solid,
//                       color: Colors.white),
//                   onPressed: () {
//                     setState(
//                         () => _isRearCameraSelected = !_isRearCameraSelected);
//                     initCamera(widget.cameras![_isRearCameraSelected ? 0 : 1]);
//                   },
//                 )),
//                 Expanded(
//                     child: IconButton(
//                   onPressed: takePicture,
//                   iconSize: 50,
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                   icon: Icon(Icons.circle, color: theme.colorScheme.primary),
//                 )),
//                 const Spacer(),
//               ]),
//             )),
//       ]),
//     ));
//   }
// }

// // ignore: must_be_immutable
// class PreviewPage extends StatelessWidget {
//   PreviewPage({Key? key, required this.picture}) : super(key: key);

//   final XFile picture;

//   @override
//   Widget build(BuildContext context) {
//     Future<void> onTakePhotoPress() async {
//       takenPhotos.add(picture);
//       if (step == 3) {
//         step = 1;
//         Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => CheckInView(
//                 imagePath: takenPhotos,
//               ),
//             )).then((value) => {takenPhotos = [], debugPrint('+++++++++++')});
//       } else {
//         step = step + 1;
//         Navigator.pop(context);
//       }
//     }

//     return Scaffold(
//       appBar: AppBarWidget(
//         isDiscard: false,
//         type: StaticModelType.manu,

//         title: '${translate('app_bar.preview_image')} $step',
//         leadingBack: true,
//         backIcon: Icons.arrow_back,
//         // iconTitle: translate('button.help'),
//         iconTitle: '',
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(StaticDataConfig.app_padding),
//         child: Center(
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             Image.file(File(picture.path), fit: BoxFit.cover, width: 250),
//             const SizedBox(height: 20),
//             Text(picture.name),
//             const SizedBox(height: 20),
//             ButtonWidget(
//                 enable: false,
//                 fullStyle: true,
//                 title: translate('button.retake_pic'),
//                 onPressed: () => {}),
//             const SizedBox(height: 10),
//             ButtonWidget(
//                 enable: true,
//                 fullStyle: true,
//                 title: step < 3
//                     ? translate('button.next')
//                     : translate('button.save'),
//                 onPressed: () async {
//                   onTakePhotoPress();
//                 }),
//           ]),
//         ),
//       ),
//     );
//   }
// }
