import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({Key? key}) : super(key: key);

  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String result = 'Наведите камеру на QR-код';
  bool hasPermission = false;
  bool isFlashOn = false;
  bool isFrontCamera = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    setState(() {
      hasPermission = status.isGranted;
      isLoading = false;
    });
    
    if (!hasPermission) {
      final result = await Permission.camera.request();
      setState(() {
        hasPermission = result.isGranted;
      });
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null) {
        await HapticFeedback.vibrate();
        setState(() {
          result = 'Найдено: ${scanData.code}';
        });
        
        // Опционально: закрыть сканер после успешного чтения
        // await controller.pauseCamera();
        // if (mounted) {
        //   Navigator.pop(context, scanData.code);
        // }
      }
    });
  }

  Future<void> _toggleFlash() async {
    if (controller != null) {
      await controller?.toggleFlash();
      setState(() {
        isFlashOn = !isFlashOn;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (controller != null) {
      await controller?.flipCamera();
      setState(() {
        isFrontCamera = !isFrontCamera;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сканирование QR-кода'),
        centerTitle: true,
        actions: [
          if (hasPermission)
            IconButton(
              icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
              onPressed: _toggleFlash,
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: hasPermission
          ? FloatingActionButton(
              onPressed: _switchCamera,
              child: Icon(isFrontCamera ? Icons.camera_front : Icons.camera_rear),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_photography, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Требуется доступ к камере',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkCameraPermission,
              child: const Text('Запросить разрешение'),
            ),
            TextButton(
              onPressed: () => openAppSettings(),
              child: const Text('Открыть настройки'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
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
                Text(
                  result,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                if (result.startsWith('Найдено:'))
                  ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: result.replaceFirst('Найдено: ', '')));
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
    );
  }
}