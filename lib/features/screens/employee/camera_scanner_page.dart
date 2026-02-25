import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../models/business_model.dart';
import '../../models/loyalty_program_model.dart';
import '../../providers/staff_scanner_provider.dart';

class CameraScannerPage extends StatefulWidget {
  final Business business;
  final String businessUserId;
  final String locationId;
  final LoyaltyProgram selectedProgram;

  const CameraScannerPage({
    super.key,
    required this.business,
    required this.businessUserId,
    required this.locationId,
    required this.selectedProgram,
  });

  @override
  State<CameraScannerPage> createState() => _CameraScannerPageState();
}

class _CameraScannerPageState extends State<CameraScannerPage> {
  final MobileScannerController _scannerController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _scannerController.start();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onQRCodeDetected(BarcodeCapture capture) async {
    final provider = Provider.of<StaffScannerProvider>(context, listen: false);
    if (provider.isProcessing || provider.scannedCustomerId != null) {
      return;
    }

    final String? raw = capture.barcodes.firstOrNull?.rawValue;
    final String? code = raw?.trim();
    if (code != null && code.isNotEmpty) {
      _scannerController.stop();

      final success = await provider.onQRCodeDetected(
        code: code,
        businessId: widget.business.id,
        businessUserId: widget.businessUserId,
        locationId: widget.locationId,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vula u shtua me sukses!'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back and reset
          Navigator.of(context).pop();
          provider.clearSelection();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.error?.message ?? 'Dështoi shtimi i vulës. Provo përsëri.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          // Reset so staff can scan another QR (same program stays selected)
          provider.resetScan();
          _scannerController.start();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StaffScannerProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Skano QR - ${widget.selectedProgram.name}'),
          ),
          body: provider.scannedCustomerId == null
              ? Stack(
                  children: [
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: _onQRCodeDetected,
                    ),
                    // Overlay with instructions
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Duke skanuar për: ${widget.selectedProgram.name}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Vendosni kodin QR brenda kornizës',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  color: provider.isProcessing ? Colors.blue[50] : Colors.green[50],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (provider.isProcessing)
                          const CircularProgressIndicator()
                        else
                          Icon(
                            Icons.check_circle,
                            size: 80,
                            color: Colors.green[700],
                          ),
                        const SizedBox(height: 16),
                        Text(
                          provider.isProcessing
                              ? 'Duke përpunuar...'
                              : 'Kodi QR u Skanua!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!provider.isProcessing) ...[
                          const SizedBox(height: 8),
                          Text(
                            'ID Klienti: ${provider.scannedCustomerId}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
