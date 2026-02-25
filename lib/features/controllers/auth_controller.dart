import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import '../../core/api.dart';
import '../../core/failures.dart';
import '../models/user_model.dart';

class AuthResponse {
  final User user;
  final String token;

  AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['customer'] ?? json['user'] ?? {}),
      token: json['token'] ?? '',
    );
  }
}

class AuthController {
  static Future<Either<Failure, AuthResponse>> signup({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final url = CustomerEndpoints.signup();

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'phone': phone,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        try {
          final jsonData = json.decode(response.body);
          // Signup returns just the customer, no token
          final user = User.fromJson(jsonData);
          // For signup, we'll return a response without token (user needs to login)
          return Right(AuthResponse(user: user, token: ''));
        } catch (e, stackTrace) {
          print('❌ [AuthController] Parse Error: $e');
          print('❌ [AuthController] Stack Trace: $stackTrace');
          return Left(ParseFailure(
            'Failed to parse signup response: ${e.toString()}',
          ));
        }
      } else {
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['error'] ?? 'Signup failed';
          print('❌ [AuthController] Signup Error: $errorMessage');
          return Left(ServerFailure(
            errorMessage,
            statusCode: response.statusCode,
          ));
        } catch (e) {
          return Left(ServerFailure(
            'Signup failed: ${response.body}',
            statusCode: response.statusCode,
          ));
        }
      }
    } on http.ClientException catch (e, stackTrace) {
      print('❌ [AuthController] Network Exception: ${e.message}');
      print('❌ [AuthController] Stack Trace: $stackTrace');
      return Left(NetworkFailure(
        'Network error: ${e.message}',
      ));
    } catch (e, stackTrace) {
      print('❌ [AuthController] Unexpected Error: $e');
      print('❌ [AuthController] Error Type: ${e.runtimeType}');
      print('❌ [AuthController] Stack Trace: $stackTrace');
      return Left(NetworkFailure(
        'Unexpected error: ${e.toString()}',
      ));
    }
  }

  static Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    final url = CustomerEndpoints.login();
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        try {
          print('🔵 [AuthController] Parsing JSON response...');
          final jsonData = json.decode(response.body);
          final authResponse = AuthResponse.fromJson(jsonData);
          print('✅ [AuthController] Successfully logged in user: ${authResponse.user.name}');
          return Right(authResponse);
        } catch (e, stackTrace) {
          print('❌ [AuthController] Parse Error: $e');
          print('❌ [AuthController] Stack Trace: $stackTrace');
          return Left(ParseFailure(
            'Failed to parse login response: ${e.toString()}',
          ));
        }
      } else if (response.statusCode == 401) {
        print('❌ [AuthController] 401 Unauthorized');
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['error'] ?? 'Invalid email or password';
          return Left(UnauthorizedFailure(
            errorMessage,
            statusCode: response.statusCode,
          ));
        } catch (e) {
          return Left(UnauthorizedFailure(
            'Invalid email or password',
            statusCode: response.statusCode,
          ));
        }
      } else {
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['error'] ?? 'Login failed';
          print('❌ [AuthController] Login Error: $errorMessage');
          return Left(ServerFailure(
            errorMessage,
            statusCode: response.statusCode,
          ));
        } catch (e) {
          return Left(ServerFailure(
            'Login failed: ${response.body}',
            statusCode: response.statusCode,
          ));
        }
      }
    } on http.ClientException catch (e, stackTrace) {
      print('❌ [AuthController] Network Exception: ${e.message}');
      print('❌ [AuthController] Stack Trace: $stackTrace');
      return Left(NetworkFailure(
        'Network error: ${e.message}',
      ));
    } catch (e, stackTrace) {
      print('❌ [AuthController] Unexpected Error: $e');
      print('❌ [AuthController] Error Type: ${e.runtimeType}');
      print('❌ [AuthController] Stack Trace: $stackTrace');
      return Left(NetworkFailure(
        'Unexpected error: ${e.toString()}',
      ));
    }
  }

  static Future<Either<Failure, AuthResponse>> googleSignIn() async {
    try {
      // Initialize Google Sign-In with serverClientId for Android
      // This is the OAuth 2.0 client ID from Google Cloud Console (Web client)
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: '1010785938316-3o4aci3t6333uchkjl228rqsl1slh0fo.apps.googleusercontent.com',
      );

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return Left(NetworkFailure('Google sign-in was canceled'));
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print('🔵 [AuthController] Google Auth - ID Token: ${googleAuth.idToken != null ? "Present" : "Null"}');
      print('🔵 [AuthController] Google Auth - Access Token: ${googleAuth.accessToken != null ? "Present" : "Null"}');

      if (googleAuth.idToken == null) {
        // If ID token is null, try to sign in silently first or request it explicitly
        print('⚠️ [AuthController] ID Token is null, attempting to re-authenticate...');
        
        // Try signing in again with forceCodeForRefreshToken to ensure we get an ID token
        final GoogleSignInAccount? retryUser = await googleSignIn.signInSilently();
        if (retryUser != null) {
          final GoogleSignInAuthentication retryAuth = await retryUser.authentication;
          if (retryAuth.idToken != null) {
            print('✅ [AuthController] Successfully obtained ID token on retry');
            return await _sendIdTokenToBackend(retryAuth.idToken!);
          }
        }
        
        return Left(NetworkFailure('Failed to obtain Google ID token. Please ensure Google Sign-In is properly configured.'));
      }
      
      return await _sendIdTokenToBackend(googleAuth.idToken!);
    } on PlatformException catch (e, stackTrace) {
      print('❌ [AuthController] Platform Exception: ${e.code} - ${e.message}');
      print('❌ [AuthController] Details: ${e.details}');
      print('❌ [AuthController] Stack Trace: $stackTrace');
      
      // Handle specific Google Sign-In error codes
      String errorMessage = 'Google Sign-In failed';
      
      if (e.code == 'sign_in_failed') {
        // ApiException: 10 = DEVELOPER_ERROR
        // This usually means SHA-1 fingerprint is not configured
        if (e.message?.contains('10') == true || e.message?.contains('ApiException: 10') == true) {
          errorMessage = 'Google Sign-In configuration error. Please ensure:\n'
              '1. SHA-1 fingerprint is added to Google Cloud Console\n'
              '2. OAuth client ID matches your app configuration\n'
              '3. Package name matches: com.nounn.loyalty\n\n'
              'To get SHA-1: cd android && ./gradlew signingReport';
        } else if (e.message?.contains('12500') == true) {
          errorMessage = 'Google Sign-In is disabled. Please enable it in Google Cloud Console.';
        } else if (e.message?.contains('12501') == true) {
          errorMessage = 'Sign-in was canceled by the user.';
        } else {
          errorMessage = 'Google Sign-In failed: ${e.message ?? e.code}';
        }
      } else {
        errorMessage = 'Google Sign-In error: ${e.message ?? e.code}';
      }
      
      return Left(NetworkFailure(errorMessage));
    } on http.ClientException catch (e, stackTrace) {
      print('❌ [AuthController] Network Exception: ${e.message}');
      print('❌ [AuthController] Stack Trace: $stackTrace');
      return Left(NetworkFailure(
        'Network error: ${e.message}',
      ));
    } catch (e, stackTrace) {
      print('❌ [AuthController] Unexpected Error: $e');
      print('❌ [AuthController] Error Type: ${e.runtimeType}');
      print('❌ [AuthController] Stack Trace: $stackTrace');
      
      // Check if it's a PlatformException wrapped in another exception
      if (e.toString().contains('ApiException: 10')) {
        return Left(NetworkFailure(
          'Google Sign-In configuration error. Please ensure SHA-1 fingerprint is added to Google Cloud Console.\n'
          'To get SHA-1: cd android && ./gradlew signingReport'
        ));
      }
      
      return Left(NetworkFailure(
        'Unexpected error: ${e.toString()}',
      ));
    }
  }

  static Future<Either<Failure, AuthResponse>> _sendIdTokenToBackend(String idToken) async {
    // Send ID token to backend
    final url = CustomerEndpoints.googleSignIn();

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'idToken': idToken,
      }),
    );

    if (response.statusCode == 200) {
      try {
        final jsonData = json.decode(response.body);
        final authResponse = AuthResponse.fromJson(jsonData);
        print('✅ [AuthController] Successfully signed in with Google: ${authResponse.user.name}');
        return Right(authResponse);
      } catch (e, stackTrace) {
        print('❌ [AuthController] Parse Error: $e');
        print('❌ [AuthController] Stack Trace: $stackTrace');
        return Left(ParseFailure(
          'Failed to parse Google sign-in response: ${e.toString()}',
        ));
      }
    } else if (response.statusCode == 401) {
      print('❌ [AuthController] 401 Unauthorized');
      try {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error'] ?? 'Invalid Google token';
        return Left(UnauthorizedFailure(
          errorMessage,
          statusCode: response.statusCode,
        ));
      } catch (e) {
        return Left(UnauthorizedFailure(
          'Invalid Google token',
          statusCode: response.statusCode,
        ));
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error'] ?? 'Google sign-in failed';
        print('❌ [AuthController] Google Sign-In Error: $errorMessage');
        return Left(ServerFailure(
          errorMessage,
          statusCode: response.statusCode,
        ));
      } catch (e) {
        return Left(ServerFailure(
          'Google sign-in failed: ${response.body}',
          statusCode: response.statusCode,
        ));
      }
    }
  }
}
