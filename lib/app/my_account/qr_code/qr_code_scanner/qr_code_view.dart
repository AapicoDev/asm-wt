import 'package:asm_wt/app/my_account/qr_code/qr_code_scanner/qr_code_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:asm_wt/assets/static_data.dart';
import 'package:asm_wt/widget/button_outline_widget.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrCodeView extends StatefulWidget {
  final String? id;

  const QrCodeView({Key? key, this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QrCodeViewState();
}

class _QrCodeViewState extends StateMVC<QrCodeView> {
  late QrCodeController con;

  _QrCodeViewState() : super(QrCodeController()) {
    con = controller as QrCodeController;
  }

  void _onQRViewCreated(QRViewController? controller) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    setState(() {
      con.controller = controller;
    });

    controller?.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        var data = scanData.code?.split('/');

        setState(() {
          con.qrCodeId = data?[1];
        });

        if (data?[0] == StaticQrCodeType.vehicle) {
          setState(() {
            con.isQrCodeCorrect = true;
          });

          controller.pauseCamera();
          showModalBottomSheet<String>(
              context: context,
              enableDrag: true,
              isDismissible: true,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0))),
              builder: (context) {
                return StatefulBuilder(
                    builder: (BuildContext context, setState) => con
                                .currentview ==
                            0
                        ? SizedBox(
                            height: width / 2,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                    decoration: const BoxDecoration(
                                        color: Color.fromRGBO(158, 158, 158, 1),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    height: height / 80,
                                    width: width / 7),
                                SizedBox(height: height / 70),
                                Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                      translate('app_bar.vehicle_check_list'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium),
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal:
                                                          StaticDataConfig
                                                              .app_padding),
                                              child: LayoutBuilder(builder:
                                                  (context, constraints) {
                                                return Column(
                                                  children: [
                                                    ButtonOutlineWidget(
                                                        title: translate(
                                                            "button.check_in"),
                                                        icon: Icons
                                                            .file_download_outlined,
                                                        onPressed: () {
                                                          con.onCheckInPressed(
                                                              context,
                                                              setState);
                                                        }),
                                                    ButtonOutlineWidget(
                                                        title: translate(
                                                            "button.check_out"),
                                                        icon: Icons
                                                            .file_upload_outlined,
                                                        onPressed: () {}),
                                                  ],
                                                );
                                              })),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(
                            height: width / 2,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                    decoration: const BoxDecoration(
                                        color: Color.fromRGBO(158, 158, 158, 1),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    height: height / 80,
                                    width: width / 7),
                                SizedBox(height: height / 70),
                                Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                      translate(
                                          'text_header.qr_code_task_list'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium),
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal:
                                                          StaticDataConfig
                                                              .app_padding),
                                              child: LayoutBuilder(builder:
                                                  (context, constraints) {
                                                return Column(
                                                  children: [],
                                                );
                                              })),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ));
              }).whenComplete(() {
            controller.resumeCamera();
            con.setDefaultIsQrCodeCorrect();
          });
        } else {}
      }
    });
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 400.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: con.qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: con.isQrCodeCorrect
              ? Theme.of(context).colorScheme.background
              : Theme.of(context).colorScheme.onBackground,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => con.onPermissionSet(context, ctrl, p),
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            size: 30,
            color: theme.colorScheme.onPrimary,
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: Column(
        children: <Widget>[
          Expanded(flex: 7, child: _buildQrView(context)),
          Expanded(
              flex: 1,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: StaticDataConfig.app_padding - 10,
                      right: StaticDataConfig.app_padding - 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.construction,
                          size: 30,
                        ),
                        Text(translate('message.under_dev')),
                      ]),
                ),
              )),
        ],
      ),
      //  bottomSheet: con.qrCodeId?.code != null
      //               ?

      //               : Container()
    );
  }
}
