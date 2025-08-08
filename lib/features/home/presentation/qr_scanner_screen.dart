import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with WidgetsBindingObserver {
  late MobileScannerController cameraController;
  bool isScanning = true;
  String? scannedData;
  bool hasPermission = false;
  bool isTorchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeController();
    _requestCameraPermission();
  }

  void _initializeController() {
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
      returnImage: false, // Set false untuk performa yang lebih baik
    );
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.status;

    if (status.isDenied) {
      final result = await Permission.camera.request();
      setState(() {
        hasPermission = result.isGranted;
      });

      if (result.isDenied) {
        _showPermissionDialog();
      }
    } else if (status.isGranted) {
      setState(() {
        hasPermission = true;
      });
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Izin Kamera Diperlukan'),
            content: const Text(
              'Aplikasi memerlukan akses kamera untuk scan QR code meteran PLN. Silakan berikan izin di pengaturan aplikasi.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Kembali ke home
                },
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Buka Pengaturan'),
              ),
            ],
          ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (!isScanning || !mounted) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
        setState(() {
          isScanning = false;
          scannedData = barcode.rawValue;
        });

        // Haptic feedback
        _vibrate();

        // Handle result
        _handleQRResult(barcode.rawValue!);
      }
    }
  }

  void _vibrate() {
    // Simple vibration feedback
    try {
      // Using system channel for haptic feedback
      // SystemChannels.platform.invokeMethod('HapticFeedback.vibrate');
    } catch (e) {
      // Ignore if haptic feedback not available
    }
  }

  void _handleQRResult(String qrData) {
    // Stop scanner sementara
    cameraController.stop();

    // Validasi format QR code meteran PLN
    if (_isValidPLNMeter(qrData)) {
      _showSuccessDialog(qrData);
    } else {
      _showErrorDialog('QR Code tidak valid atau bukan meteran PLN');
    }
  }

  bool _isValidPLNMeter(String qrData) {
    // Validasi untuk QR meteran PLN
    // Format umum: 11-13 digit nomor meteran atau mengandung kata kunci PLN
    if (qrData.length < 8) return false;

    // Check if it's numeric meter number (11-13 digits)
    final numericPattern = RegExp(r'^\d{11,13}$');
    if (numericPattern.hasMatch(qrData)) return true;

    // Check if contains PLN related keywords
    final upperQR = qrData.toUpperCase();
    return upperQR.contains('PLN') ||
        upperQR.contains('METER') ||
        upperQR.contains('KWH') ||
        upperQR.contains('LISTRIK');
  }

  void _showSuccessDialog(String meterNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 32),
            ),
            title: const Text(
              'QR Code Berhasil Dipindai',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Data Meteran PLN:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    meterNumber,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Apakah Anda ingin melanjutkan proses pemasangan device SMARTI untuk meteran ini?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetScanner();
                },
                child: const Text('Scan Ulang'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Kembali ke home
                  _startInstallationProcess(meterNumber);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Lanjutkan Pemasangan'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 32,
              ),
            ),
            title: const Text(
              'Scan Gagal',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(message, textAlign: TextAlign.center),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetScanner();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
    );
  }

  void _resetScanner() {
    setState(() {
      isScanning = true;
      scannedData = null;
    });
    cameraController.start();
  }

  void _startInstallationProcess(String meterNumber) {
    // TODO: Navigate to installation process screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Memulai pemasangan untuk meter: $meterNumber'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _toggleTorch() async {
    try {
      await cameraController.toggleTorch();
      setState(() {
        isTorchOn = !isTorchOn;
      });
    } catch (e) {
      // Handle torch toggle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat mengaktifkan flash'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    switch (state) {
      case AppLifecycleState.resumed:
        if (hasPermission) {
          cameraController.start();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        cameraController.stop();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!hasPermission) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan QR Meteran PLN'),
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Meminta Izin Kamera...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Text(
                'Aplikasi memerlukan akses kamera\nuntuk scan QR code meteran PLN',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Meteran PLN'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _toggleTorch,
            icon: Icon(isTorchOn ? Icons.flash_on : Icons.flash_off),
          ),
          IconButton(
            onPressed: () {
              cameraController.switchCamera();
            },
            icon: const Icon(Icons.flip_camera_ios),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 80, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${error.errorDetails?.message ?? 'Terjadi kesalahan'}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Kembali'),
                    ),
                  ],
                ),
              );
            },
          ),

          // Overlay dengan frame scan
          CustomPaint(
            painter: ScannerOverlay(),
            child: Container(width: double.infinity, height: double.infinity),
          ),

          // Instructions
          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    color: Color(0xFF4CAF50),
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Arahkan kamera ke QR Code pada meteran PLN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pastikan QR Code berada dalam frame dan area terang',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!isScanning) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Memproses...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    super.dispose();
  }
}

// Custom painter untuk overlay scanner
class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.fill;

    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.width * 0.8,
    );

    // Draw overlay with transparent scan area
    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRect(scanArea)
        ..fillType = PathFillType.evenOdd,
      paint,
    );

    // Draw scan frame corners
    final cornerPaint =
        Paint()
          ..color = const Color(0xFF4CAF50)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;

    final cornerLength = 30.0;

    // Top-left corner
    canvas.drawLine(
      Offset(scanArea.left, scanArea.top + cornerLength),
      Offset(scanArea.left, scanArea.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanArea.left, scanArea.top),
      Offset(scanArea.left + cornerLength, scanArea.top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(scanArea.right - cornerLength, scanArea.top),
      Offset(scanArea.right, scanArea.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.top),
      Offset(scanArea.right, scanArea.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(scanArea.left, scanArea.bottom - cornerLength),
      Offset(scanArea.left, scanArea.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanArea.left, scanArea.bottom),
      Offset(scanArea.left + cornerLength, scanArea.bottom),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(scanArea.right - cornerLength, scanArea.bottom),
      Offset(scanArea.right, scanArea.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.bottom - cornerLength),
      Offset(scanArea.right, scanArea.bottom),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
