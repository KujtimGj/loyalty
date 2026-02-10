import 'package:flutter/foundation.dart';
import '../models/loyalty_program_model.dart';
import '../controllers/loyalty_program_controller.dart';
import '../../core/failures.dart';

class LoyaltyProgramProvider with ChangeNotifier {
  List<LoyaltyProgram> _loyaltyPrograms = [];
  bool _isLoading = false;
  Failure? _failure;

  List<LoyaltyProgram> get loyaltyPrograms => _loyaltyPrograms;
  bool get isLoading => _isLoading;
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
    _failure = null;
    _isLoading = false;
    notifyListeners();
  }
}
