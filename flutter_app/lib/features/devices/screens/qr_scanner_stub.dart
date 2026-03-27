// Stub for QR scanner on web platform
import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';

class MobileScannerController {
  void dispose() {}
}

class MobileScanner extends StatelessWidget {
  const MobileScanner({
    super.key,
    required this.controller,
    this.onDetect,
  });

  final MobileScannerController controller;
  final void Function(dynamic capture)? onDetect;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Text(loc.qrScannerNotAvailableOnWeb),
    );
  }
}

class BarcodeCapture {
  final List<Barcode> barcodes;
  BarcodeCapture({required this.barcodes});
}

class Barcode {
  final String? rawValue;
  Barcode({this.rawValue});
}
