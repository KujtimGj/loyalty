import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/loyalty_program_model.dart';
import '../controllers/loyalty_program_controller.dart';
import '../controllers/business_customer_controller.dart';
import '../controllers/customer_loyalty_card_controller.dart';
import '../controllers/stamp_transaction_controller.dart';
import '../../core/failures.dart';

/// Extracts customer ID from scanned QR payload.
/// Supports: plain customer ID string, or JSON like {"customerId": "..."}.
String? parseCustomerIdFromQR(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.startsWith('{')) {
    try {
      final map = json.decode(trimmed) as Map<String, dynamic>;
      final id = map['customerId'] ?? map['customer_id'] ?? map['id'];
      if (id is String && id.isNotEmpty) return id.trim();
      return null;
    } catch (_) {
      return trimmed;
    }
  }
  return trimmed;
}

class StaffScannerProvider with ChangeNotifier {
  String? _scannedCustomerId;
  LoyaltyProgram? _selectedProgram;
  List<LoyaltyProgram> _loyaltyPrograms = [];
  bool _isLoadingPrograms = false;
  bool _isProcessing = false;
  bool _isScanningEnabled = false;
  Failure? _error;

  String? get scannedCustomerId => _scannedCustomerId;
  LoyaltyProgram? get selectedProgram => _selectedProgram;
  List<LoyaltyProgram> get loyaltyPrograms => _loyaltyPrograms;
  bool get isLoadingPrograms => _isLoadingPrograms;
  bool get isProcessing => _isProcessing;
  bool get isScanningEnabled => _isScanningEnabled;
  Failure? get error => _error;
  bool get hasError => _error != null;

  /// Load loyalty programs for a business
  Future<void> loadLoyaltyPrograms(String businessId) async {
    _isLoadingPrograms = true;
    _error = null;
    notifyListeners();

    print('🔵 [StaffScannerProvider] Loading loyalty programs for business: $businessId');

    final result = await LoyaltyProgramController.fetchLoyaltyProgramsByBusiness(
      businessId,
    );

    result.fold(
      (failure) {
        print('❌ [StaffScannerProvider] Failed to load programs: ${failure.message}');
        _error = failure;
        _loyaltyPrograms = [];
        _isLoadingPrograms = false;
      },
      (programs) {
        print('✅ [StaffScannerProvider] Fetched ${programs.length} total programs');
        final activePrograms = programs.where((p) => p.isActive).toList();
        print('✅ [StaffScannerProvider] Found ${activePrograms.length} active programs');
        
        // Debug: Print all programs and their active status
        for (var program in programs) {
          print('📋 [StaffScannerProvider] Program: ${program.name}, Active: ${program.isActive}, ID: ${program.id}');
        }
        
        // Show all programs (including inactive) so user can see them
        // Inactive programs will be visually indicated in the UI
        _loyaltyPrograms = programs;
        _error = null;
        _isLoadingPrograms = false;
      },
    );

    notifyListeners();
  }

  /// Toggle selection of a loyalty program
  void selectProgram(LoyaltyProgram program) {
    // If clicking the same program, deselect it
    if (_selectedProgram?.id == program.id) {
      _selectedProgram = null;
      _isScanningEnabled = false;
    } else {
      // Otherwise, select the new program
      _selectedProgram = program;
      _isScanningEnabled = false; // Don't enable scanning until "Scan Here" is clicked
    }
    _scannedCustomerId = null;
    _error = null;
    notifyListeners();
  }

  /// Enable scanning and prepare for QR code scan
  void enableScanning() {
    if (_selectedProgram != null) {
      _isScanningEnabled = true;
      _scannedCustomerId = null;
      _error = null;
      notifyListeners();
    }
  }

  /// Clear selected program and reset scanning
  void clearSelection() {
    _selectedProgram = null;
    _scannedCustomerId = null;
    _isScanningEnabled = false;
    _error = null;
    notifyListeners();
  }

  /// Handle QR code detection - automatically adds stamp when program is selected
  Future<bool> onQRCodeDetected({
    required String code,
    required String businessId,
    required String businessUserId,
    required String locationId,
  }) async {
    if (_isProcessing || _scannedCustomerId != null || _selectedProgram == null) {
      return false;
    }

    final customerId = parseCustomerIdFromQR(code);
    if (customerId == null || customerId.isEmpty) {
      _error = ValidationFailure('Invalid QR code: could not read customer ID');
      notifyListeners();
      return false;
    }

    print('🟡 [StaffScannerProvider] QR Code scanned, customer ID: $customerId');
    _scannedCustomerId = customerId;
    _error = null;
    notifyListeners();

    // Automatically add stamp for the selected program
    return await addStamp(
      businessId: businessId,
      businessUserId: businessUserId,
      locationId: locationId,
      program: _selectedProgram!,
    );
  }

  /// Reset the scanned customer ID (but keep selected program)
  void resetScan() {
    _scannedCustomerId = null;
    _error = null;
    notifyListeners();
  }

  /// Add a stamp for a customer and loyalty program
  Future<bool> addStamp({
    required String businessId,
    required String businessUserId,
    required String locationId,
    required LoyaltyProgram program,
  }) async {
    if (_scannedCustomerId == null) return false;

    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      // Step 1: Get or create business-customer relationship
      final bcResult = await BusinessCustomerController.getOrCreateBusinessCustomer(
        businessId: businessId,
        customerId: _scannedCustomerId!,
      );

      final businessCustomer = await bcResult.fold(
        (failure) {
          _error = failure;
          _isProcessing = false;
          notifyListeners();
          return null;
        },
        (bc) => bc,
      );

      if (businessCustomer == null) return false;

      // Step 2: Get or create customer loyalty card
      final cardResult = await CustomerLoyaltyCardController.getOrCreateLoyaltyCard(
        businessCustomerId: businessCustomer.id,
        loyaltyProgramId: program.id,
      );

      final loyaltyCard = await cardResult.fold(
        (failure) {
          _error = failure;
          _isProcessing = false;
          notifyListeners();
          return null;
        },
        (card) => card,
      );

      if (loyaltyCard == null) return false;

      // Step 3: Create stamp transaction
      final transactionResult = await StampTransactionController.createStampTransaction(
        customerLoyaltyCardId: loyaltyCard.id,
        businessUserId: businessUserId,
        locationId: locationId,
        stampsAdded: 1,
        source: 'manual',
      );

      return transactionResult.fold(
        (failure) {
          _error = failure;
          _isProcessing = false;
          notifyListeners();
          return false;
        },
        (transaction) {
          _isProcessing = false;
          _scannedCustomerId = null;
          _selectedProgram = null;
          _isScanningEnabled = false;
          _error = null;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _error = NetworkFailure('Unexpected error: ${e.toString()}');
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
