import 'package:flutter/foundation.dart';
import '../models/customer_loyalty_card_model.dart';
import '../controllers/customer_loyalty_card_controller.dart';
import '../../core/failures.dart';

class CustomerLoyaltyCardProvider with ChangeNotifier {
  List<CustomerLoyaltyCard> _cards = [];
  bool _isLoading = false;
  Failure? _failure;

  List<CustomerLoyaltyCard> get cards => _cards;
  bool get isLoading => _isLoading;
  Failure? get failure => _failure;
  bool get hasError => _failure != null;

  /// Get the current stamp count for a loyalty program (by program id).
  /// Returns 0 if the user has no card for that program.
  int getStampsForProgram(String loyaltyProgramId) {
    try {
      final card = _cards.firstWhere(
        (c) => c.loyaltyProgramId == loyaltyProgramId,
      );
      return card.currentStamps;
    } catch (_) {
      return 0;
    }
  }

  /// Fetch all loyalty cards for the given customer id.
  Future<void> fetchForCustomer(String customerId) async {
    if (customerId.isEmpty) {
      _cards = [];
      notifyListeners();
      return;
    }
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final result = await CustomerLoyaltyCardController.getLoyaltyCardsByCustomer(
      customerId: customerId,
    );

    result.fold(
      (f) {
        _failure = f;
        _cards = [];
      },
      (list) {
        _cards = list;
        _failure = null;
      },
    );
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _failure = null;
    notifyListeners();
  }

  void clearCards() {
    _cards = [];
    _failure = null;
    notifyListeners();
  }
}
