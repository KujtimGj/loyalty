import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business_user_model.dart';
import '../models/business_model.dart';

class BusinessUserProvider with ChangeNotifier {
  BusinessUser? _currentBusinessUser;
  Business? _currentBusiness;
  bool _isLoading = false;
  String? _error;

  BusinessUser? get currentBusinessUser => _currentBusinessUser;
  Business? get currentBusiness => _currentBusiness;
  bool get isLoggedIn => _currentBusinessUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  BusinessUserProvider() {
    _loadBusinessUserFromStorage();
  }

  /// Load business user from shared preferences
  Future<void> _loadBusinessUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('business_user');
      final businessJson = prefs.getString('business');

      if (userJson != null) {
        final userData = json.decode(userJson);
        _currentBusinessUser = BusinessUser.fromJson(userData);
        
        if (businessJson != null) {
          final businessData = json.decode(businessJson);
          _currentBusiness = Business.fromJson(businessData);
        }
        
        print('🟢 [BusinessUserProvider] Loaded business user from storage: ${_currentBusinessUser?.name}');
        notifyListeners();
      }
    } catch (e) {
      print('❌ [BusinessUserProvider] Error loading business user from storage: $e');
    }
  }

  /// Save business user to shared preferences
  Future<void> _saveBusinessUserToStorage(BusinessUser user, Business? business) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('business_user', json.encode(user.toJson()));
      if (business != null) {
        await prefs.setString('business', json.encode(business.toJson()));
      }
      print('🟢 [BusinessUserProvider] Saved business user to storage: ${user.name}');
    } catch (e) {
      print('❌ [BusinessUserProvider] Error saving business user to storage: $e');
    }
  }

  /// Clear business user from shared preferences
  Future<void> _clearBusinessUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('business_user');
      await prefs.remove('business');
      print('🟢 [BusinessUserProvider] Cleared business user from storage');
    } catch (e) {
      print('❌ [BusinessUserProvider] Error clearing business user from storage: $e');
    }
  }

  /// Set the current business user
  void setBusinessUser(BusinessUser user, Business? business) {
    print('🟢 [BusinessUserProvider] Setting business user: ${user.name}');
    _currentBusinessUser = user;
    _currentBusiness = business;
    _error = null;
    _saveBusinessUserToStorage(user, business);
    notifyListeners();
  }

  /// Logout business user
  Future<void> logout() async {
    print('🟢 [BusinessUserProvider] Logging out...');
    _currentBusinessUser = null;
    _currentBusiness = null;
    _error = null;
    await _clearBusinessUserFromStorage();
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
