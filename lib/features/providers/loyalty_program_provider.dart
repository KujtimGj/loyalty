import 'package:flutter/foundation.dart';
import '../models/loyalty_program_model.dart';
import '../controllers/loyalty_program_controller.dart';
import '../../core/failures.dart';

class LoyaltyProgramProvider with ChangeNotifier {
  List<LoyaltyProgram> _loyaltyPrograms = [];
  List<LoyaltyProgram> _collectedLoyaltyPrograms = [];
  bool _isLoading = false;
  bool _isLoadingCollected = false;
  Failure? _failure;

  List<LoyaltyProgram> get loyaltyPrograms => _loyaltyPrograms;
  List<LoyaltyProgram> get collectedLoyaltyPrograms => _collectedLoyaltyPrograms;
  bool get isLoading => _isLoading;
  bool get isLoadingCollected => _isLoadingCollected;
  Failure? get failure => _failure;
  String? get error => _failure?.toString();
  bool get hasError => _failure != null;

  Future<void> fetchAllLoyaltyPrograms() async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final result = await LoyaltyProgramController.fetchAllLoyaltyPrograms();

    result.fold(
      (failure) {
        _failure = failure;
        _loyaltyPrograms = [];
      },
      (programs) {
        _loyaltyPrograms = programs;
        _failure = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch loyalty programs for a specific business
  Future<void> fetchLoyaltyProgramsByBusiness(String businessId) async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final result = await LoyaltyProgramController.fetchLoyaltyProgramsByBusiness(businessId);

    result.fold(
      (failure) {
        _failure = failure;
        _loyaltyPrograms = [];
      },
      (programs) {
        _loyaltyPrograms = programs;
        _failure = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch active loyalty programs for a specific business
  Future<void> fetchActiveLoyaltyProgramsByBusiness(String businessId) async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final result = await LoyaltyProgramController.fetchActiveLoyaltyProgramsByBusiness(businessId);

    result.fold(
      (failure) {
        _failure = failure;
        _loyaltyPrograms = [];
      },
      (programs) {
        _loyaltyPrograms = programs;
        _failure = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch incomplete loyalty programs for a customer
  /// Returns programs where customer has stamps but hasn't completed them
  Future<void> fetchIncompleteLoyaltyProgramsByCustomer(String customerId) async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final result = await LoyaltyProgramController.fetchIncompleteLoyaltyProgramsByCustomer(customerId);

    result.fold(
      (failure) {
        _failure = failure;
        _loyaltyPrograms = [];
      },
      (programs) {
        _loyaltyPrograms = programs;
        _failure = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch collected loyalty programs for a customer (rewards they've redeemed)
  Future<void> fetchCollectedLoyaltyProgramsByCustomer(String customerId) async {
    _isLoadingCollected = true;
    notifyListeners();

    final result = await LoyaltyProgramController.fetchCollectedLoyaltyProgramsByCustomer(customerId);

    result.fold(
      (failure) {
        _collectedLoyaltyPrograms = [];
      },
      (programs) {
        _collectedLoyaltyPrograms = programs;
      },
    );

    _isLoadingCollected = false;
    notifyListeners();
  }

  /// Get only active loyalty programs
  List<LoyaltyProgram> getActiveLoyaltyPrograms() {
    return _loyaltyPrograms.where((program) => program.isActive).toList();
  }

  /// Clear the error state
  void clearError() {
    _failure = null;
    notifyListeners();
  }

  /// Clear all loyalty programs
  void clearLoyaltyPrograms() {
    _loyaltyPrograms = [];
    _collectedLoyaltyPrograms = [];
    _failure = null;
    _isLoading = false;
    _isLoadingCollected = false;
    notifyListeners();
  }
}
