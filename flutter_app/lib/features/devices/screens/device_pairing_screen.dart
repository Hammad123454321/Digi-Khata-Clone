import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/device_utils.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/sync/sync_service.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../core/localization/app_localizations.dart';

// Conditional import for QR scanner (not available on web)
import 'package:mobile_scanner/mobile_scanner.dart'
    if (dart.library.html) 'package:digikhata_clone/features/devices/screens/qr_scanner_stub.dart';

class DevicePairingScreen extends StatefulWidget {
  const DevicePairingScreen({super.key});

  @override
  State<DevicePairingScreen> createState() => _DevicePairingScreenState();
}

class _DevicePairingScreenState extends State<DevicePairingScreen> {
  String? _pairingToken;
  bool _isGenerating = false;
  bool _isScanning = false;
  MobileScannerController? _scannerController;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _scannerController = MobileScannerController();
    }
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  Future<void> _generatePairingToken() async {
    setState(() => _isGenerating = true);

    try {
      final isOnline = await getIt<SyncService>().isOnline();
      if (!isOnline) {
        setState(() => _isGenerating = false);
        if (mounted) {
          final loc = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.onlineRequired),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      final apiClient = getIt<ApiClient>();
      final response = await apiClient.get(ApiConstants.devicePairingToken);
      final token = response.data['pairing_token'] as String;

      setState(() {
        _pairingToken = token;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.failedToGeneratePairingToken
                  .replaceAll('{error}', e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pairDevice(String scannedToken) async {
    try {
      final isOnline = await getIt<SyncService>().isOnline();
      if (!isOnline) {
        if (mounted) {
          final loc = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.onlineRequired),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      final deviceId = await DeviceUtils.getDeviceId();
      final deviceName = await DeviceUtils.getDeviceName();
      final deviceType = DeviceUtils.getDeviceType();

      final apiClient = getIt<ApiClient>();
      await apiClient.post(
        ApiConstants.devicePair,
        data: {
          'device_id': deviceId,
          'device_name': deviceName,
          'device_type': deviceType,
          'pairing_token': scannedToken,
        },
      );

      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.devicePairedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                loc.failedToPairDevice.replaceAll('{error}', e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onQRCodeDetect(String code) {
    if (code.isNotEmpty && !_isScanning) {
      setState(() => _isScanning = true);
      _pairDevice(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.devicePairing),
          bottom: TabBar(
            tabs: [
              Tab(text: loc.generateQr),
              Tab(text: loc.scanQr),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Generate QR Code Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AppCard(
                    child: Column(
                      children: [
                        Text(
                          loc.generatePairingQrCode,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          loc.generateQrDescription,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        if (_pairingToken != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: QrImageView(
                              data: _pairingToken!,
                              version: QrVersions.auto,
                              size: 250,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            loc.pairingToken,
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            _pairingToken!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 32),
                          AppButton(
                            onPressed:
                                _isGenerating ? null : _generatePairingToken,
                            isLoading: _isGenerating,
                            label: loc.generateQrCode,
                            icon: Icons.qr_code,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Scan QR Code Tab
            kIsWeb
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          loc.qrScannerNotAvailableOnWeb,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.useMobileAppToScan,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: _scannerController != null
                            ? MobileScanner(
                                controller: _scannerController!,
                                onDetect: (capture) {
                                  if (capture.barcodes.isNotEmpty) {
                                    final barcode = capture.barcodes.first;
                                    if (barcode.rawValue != null) {
                                      _onQRCodeDetect(barcode.rawValue!);
                                    }
                                  }
                                },
                              )
                            : const Center(child: CircularProgressIndicator()),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              loc.scanQrFromAnotherDevice,
                              style: theme.textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              loc.pointCameraAtQr,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
