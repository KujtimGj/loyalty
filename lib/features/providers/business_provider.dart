import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../models/business_model.dart';
import '../controllers/business_controller.dart';
import '../../core/failures.dart';

class BusinessProvider with ChangeNotifier {
  List<Business> _businesses = [];
  bool _isLoading = false;
  Failure? _failure;

  List<Business> get businesses => _businesses;
  bool get isLoading => _isLoading;
  Failure? get failure => _failure;
  String? get error => _failure?.toString();
  bool get hasError => _failure != null;

  /// Fetch all businesses from the API
  /// Updates the businesses list and notifies listeners
  Future<void> fetchAllBusinesses() async {
    
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final result = await BusinessController.fetchAllBusinesses();

    result.fold(
      (failure) {
        _failure = failure;
        _businesses = [];
      },
      (businesses) {
        _businesses = businesses;
        _failure = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch a single business by ID
  Future<Either<Failure, Business>> fetchBusinessById(String id) async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final result = await BusinessController.fetchBusinessById(id);

    result.fold(
      (failure) {
        _failure = failure;
      },
      (business) {
        _failure = null;
      },
    );

    _isLoading = false;
    notifyListeners();

    return result;
  }

  /// Clear the error state
  void clearError() {
    _failure = null;
    notifyListeners();
  }

  /// Clear all businesses
  void clearBusinesses() {
    _businesses = [];
    _failure = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Get businesses filtered by subscription status
  List<Business> getActiveBusinesses() {
    return _businesses
        .where((business) => business.subscriptionStatus == 'active')
        .toList();
  }

  /// Get businesses filtered by plan
  List<Business> getBusinessesByPlan(String plan) {
    return _businesses.where((business) => business.plan == plan).toList();
  }
}
