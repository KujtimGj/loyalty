import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
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
}
