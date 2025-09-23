import 'dart:io';

import 'package:connect_card/screens/card_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QrScanTest extends StatefulWidget{

  State<QrScanTest> createState() => _QRScanTestState();

}

class _QRScanTestState extends State<QrScanTest> {

  final GlobalKey globalKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  bool isFront = true;
  bool isToggleFlash = false;


  @override
  void reassemble() {
    super.reassemble();
    if(Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void switchCamera() async {
    await controller!.flipCamera();
    setState(() {
      isFront = !isFront;
    });
  }

  void toggleFlash() async {
    await controller!.toggleFlash();
    setState(() {
      isToggleFlash = !isToggleFlash;
    });
  }

  void handleScannedData() {
    if(result != null) {
      final scannedUrl = result!.code.toString();
      if(scannedUrl.startsWith('http://45.12.255.231:8000/')) {
        final uri = Uri.parse(scannedUrl);
        final pathSegments = uri.pathSegments;
        if(pathSegments.length >= 2) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CardPreviewPage(cardId: pathSegments[1],)));
        }
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(isFront ? Icons.camera_front : Icons.camera_rear),
            onPressed: switchCamera),
            IconButton(
              icon: Icon(isToggleFlash ? Icons.flash_on : Icons.flash_off),
              onPressed: toggleFlash)
        ],
      ),
      body: Column(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: QRView(
            key: globalKey,
            onQRViewCreated: onQrViewCamera,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.blue,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 8,
              cutOutSize: MediaQuery.of(context).size.width * 0.7,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (result != null)
                Text(
                  '${result!.code}',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                if (result != null)
                  ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: result!.code.toString()));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Скопировано в буфер обмена')),
                      );
                    },
                    child: const Text('Копировать'),
                  ),
              ],
            ),
          ),
        ),
      ],
    )
    );
  }


  void onQrViewCamera(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scannedData) {
      setState(() {
        result = scannedData;
      });
    });

  }
  
}