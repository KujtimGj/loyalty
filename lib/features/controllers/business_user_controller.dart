import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import '../../core/api.dart';
import '../../core/failures.dart';
import '../models/business_user_model.dart';
import '../models/business_model.dart';

class BusinessUserController {
  /// Login business user with email and password
  /// Returns Either<Failure, BusinessUser>
  static Future<Either<Failure, BusinessUser>> login(String email, String password) async {
    final url = BusinessUserEndpoints.login();
    
    print('🔵 [BusinessUserController] Logging in business user: $email');
    print('🔵 [BusinessUserController] URL: $url');

    try {
      print('🔵 [BusinessUserController] Making HTTP POST request...');
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

      print('🔵 [BusinessUserController] Response received');
      print('🔵 [BusinessUserController] Status Code: ${response.statusCode}');
      print('🔵 [BusinessUserController] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          print('🔵 [BusinessUserController] Parsing JSON response...');
          final jsonData = json.decode(response.body);
          final user = BusinessUser.fromJson(jsonData);
          print('✅ [BusinessUserController] Login successful: ${user.name}');
          return Right(user);
        } catch (e, stackTrace) {
          print('❌ [BusinessUserController] Parse Error: $e');
          print('❌ [BusinessUserController] Stack Trace: $stackTrace');
          return Left(ParseFailure(
            'Failed to parse business user: ${e.toString()}',
          ));
        }
      } else if (response.statusCode == 401) {
        return Left(ServerFailure(
          'Invalid email or password',
          statusCode: 401,
        ));
      } else if (response.statusCode == 404) {
        return Left(NotFoundFailure(
          'Business user not found',
          statusCode: 404,
        ));
      } else {
        return Left(ServerFailure(
          'Failed to login: ${response.body}',
          statusCode: response.statusCode,
        ));
      }
    } on http.ClientException catch (e, stackTrace) {
      print('❌ [BusinessUserController] Network Exception: ${e.message}');
      print('❌ [BusinessUserController] Stack Trace: $stackTrace');
      return Left(NetworkFailure(
        'Network error: ${e.message}',
      ));
    } catch (e, stackTrace) {
      print('❌ [BusinessUserController] Unexpected Error: $e');
      print('❌ [BusinessUserController] Error Type: ${e.runtimeType}');
      print('❌ [BusinessUserController] Stack Trace: $stackTrace');
      return Left(NetworkFailure(
        'Unexpected error: ${e.toString()}',
      ));
    }
  }

  /// Get business user by email
  /// Returns Either<Failure, BusinessUser>
  static Future<Either<Failure, BusinessUser>> getBusinessUserByEmail(String email) async {
    final url = BusinessUserEndpoints.byEmail(email);
    
    print('🔵 [BusinessUserController] Getting business user by email: $email');
    print('🔵 [BusinessUserController] URL: $url');

    try {
      print('🔵 [BusinessUserController] Making HTTP GET request...');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('🔵 [BusinessUserController] Response received');
      print('🔵 [BusinessUserController] Status Code: ${response.statusCode}');
      print('🔵 [BusinessUserController] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          print('🔵 [BusinessUserController] Parsing JSON response...');
          final jsonData = json.decode(response.body);
          final user = BusinessUser.fromJson(jsonData);
          print('✅ [BusinessUserController] Found business user: ${user.name}');
          return Right(user);
        } catch (e, stackTrace) {
          print('❌ [BusinessUserController] Parse Error: $e');
          print('❌ [BusinessUserController] Stack Trace: $stackTrace');
          return Left(ParseFailure(
            'Failed to parse business user: ${e.toString()}',
          ));
        }
      } else if (response.statusCode == 404) {
        return Left(NotFoundFailure(
          'Business user with email $email not found',
          statusCode: 404,
        ));
      } else {
        return Left(ServerFailure(
          'Failed to load business user: ${response.body}',
          statusCode: response.statusCode,
        ));
      }
    } on http.ClientException catch (e, stackTrace) {
      print('❌ [BusinessUserController] Network Exception: ${e.message}');
      print('❌ [BusinessUserController] Stack Trace: $stackTrace');
      return Left(NetworkFailure(
        'Network error: ${e.message}',
      ));
    } catch (e, stackTrace) {
      print('❌ [BusinessUserController] Unexpected Error: $e');
      print('❌ [BusinessUserController] Error Type: ${e.runtimeType}');
      print('❌ [BusinessUserController] Stack Trace: $stackTrace');
      return Left(NetworkFailure(
        'Unexpected error: ${e.toString()}',
      ));
    }
  }

  /// Get business by ID
  static Future<Either<Failure, Business>> getBusinessById(String businessId) async {
    final url = BusinessEndpoints.byId(businessId);
    print('🔵 [BusinessUserController] Getting business by ID: $businessId');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          final business = Business.fromJson(jsonData);
          print('✅ [BusinessUserController] Found business: ${business.name}');
          return Right(business);
        } catch (e) {
          return Left(ParseFailure('Failed to parse business: ${e.toString()}'));
        }
      } else {
        return Left(ServerFailure(
          'Failed to load business: ${response.body}',
          statusCode: response.statusCode,
        ));
      }
    } catch (e) {
      return Left(NetworkFailure('Network error: ${e.toString()}'));
    }
  }
}
