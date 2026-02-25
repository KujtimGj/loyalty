import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dartz/dartz.dart';
import '../models/user_model.dart';
import '../controllers/auth_controller.dart';
import '../../core/failures.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  Failure? _failure;

  User? get currentUser => _currentUser;
  String? get userId => _currentUser?.id;
  String? get token => _token;
  bool get isLoggedIn => _currentUser != null && _token != null;
  bool get isLoading => _isLoading;
  Failure? get failure => _failure;
  String? get error => _failure?.toString();
  bool get hasError => _failure != null;

  UserProvider() {
    _loadUserFromStorage();
  }

  /// Load user and token from shared preferences
  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      final token = prefs.getString('token');

      if (userJson != null && token != null) {
        final userData = json.decode(userJson);
        _currentUser = User.fromJson(userData);
        _token = token;
        print('🟢 [UserProvider] Loaded user from storage: ${_currentUser?.name}');
        notifyListeners();
      }
    } catch (e) {
      print('❌ [UserProvider] Error loading user from storage: $e');
    }
  }

  /// Save user and token to shared preferences
  Future<void> _saveUserToStorage(User user, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(user.toJson()));
      await prefs.setString('token', token);
      print('🟢 [UserProvider] Saved user to storage: ${user.name}');
    } catch (e) {
      print('❌ [UserProvider] Error saving user to storage: $e');
    }
  }

  /// Clear user and token from shared preferences
  Future<void> _clearUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      await prefs.remove('token');
      print('🟢 [UserProvider] Cleared user from storage');
    } catch (e) {
      print('❌ [UserProvider] Error clearing user from storage: $e');
    }
  }

  /// Sign up a new user
  Future<Either<Failure, User>> signup({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    print('🟢 [UserProvider] Starting signup...');
    final result = await AuthController.signup(
      name: name,
      phone: phone,
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        print('❌ [UserProvider] Signup failed: ${failure.message}');
        _failure = failure;
        _isLoading = false;
        notifyListeners();
        return Left(failure);
      },
      (authResponse) {
        print('✅ [UserProvider] Signup successful: ${authResponse.user.name}');
        _currentUser = authResponse.user;
        _token = authResponse.token;
        _failure = null;
        _isLoading = false;
        if (authResponse.token.isNotEmpty) {
          _saveUserToStorage(authResponse.user, authResponse.token);
        }
        notifyListeners();
        return Right(authResponse.user);
      },
    );
  }

  /// Login user
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    print('🟢 [UserProvider] Starting login...');
    final result = await AuthController.login(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        print('❌ [UserProvider] Login failed: ${failure.message}');
        _failure = failure;
        _isLoading = false;
        notifyListeners();
        return Left(failure);
      },
      (authResponse) {
        print('✅ [UserProvider] Login successful: ${authResponse.user.name}');
        _currentUser = authResponse.user;
        _token = authResponse.token;
        _failure = null;
        _isLoading = false;
        _saveUserToStorage(authResponse.user, authResponse.token);
        notifyListeners();
        return Right(authResponse.user);
      },
    );
  }

    /// Google Sign-In
  Future<Either<Failure, User>> googleSignIn() async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    print('🟢 [UserProvider] Starting Google sign-in...');
    final result = await AuthController.googleSignIn();

    return result.fold(
      (failure) {
        print('❌ [UserProvider] Google sign-in failed: ${failure.message}');
        _failure = failure;
        _isLoading = false;
        notifyListeners();
        return Left(failure);
      },
      (authResponse) {
        print('✅ [UserProvider] Google sign-in successful: ${authResponse.user.name}');
        _currentUser = authResponse.user;
        _token = authResponse.token;
        _failure = null;
        _isLoading = false;
        _saveUserToStorage(authResponse.user, authResponse.token);
        notifyListeners();
        return Right(authResponse.user);
      },
    );
  }

  /// Logout user
  Future<void> logout() async {
    print('🟢 [UserProvider] Logging out...');
    _currentUser = null;
    _token = null;
    _failure = null;
    await _clearUserFromStorage();
    notifyListeners();
  }

  /// Set the current user (call this after login)
  void setUser(User user, String token) {
    print('🟢 [UserProvider] Setting user: ${user.name} (${user.id})');
    _currentUser = user;
    _token = token;
    _saveUserToStorage(user, token);
    notifyListeners();
  }

  /// Clear the current user (call this on logout)
  void clearUser() {
    logout();
  }

  /// Update user information
  void updateUser(User user) {
    print('🟢 [UserProvider] Updating user: ${user.name}');
    _currentUser = user;
    if (_token != null) {
      _saveUserToStorage(user, _token!);
    }
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    _failure = null;
    notifyListeners();
  }
}
