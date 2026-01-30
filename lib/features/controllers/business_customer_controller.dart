import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import '../../core/api.dart';
import '../../core/failures.dart';

class BusinessCustomer {
  final String id;
  final String businessId;
  final String customerId;
  final DateTime joinedAt;

  BusinessCustomer({
    required this.id,
    required this.businessId,
    required this.customerId,
    required this.joinedAt,
  });

  factory BusinessCustomer.fromJson(Map<String, dynamic> json) {
    return BusinessCustomer(
      id: json['_id'] ?? json['id'] ?? '',
      businessId: json['business_id'] is String
          ? json['business_id']
          : json['business_id']?['_id'] ?? json['business_id']?['id'] ?? '',
      customerId: json['customer_id'] is String
          ? json['customer_id']
          : json['customer_id']?['_id'] ?? json['customer_id']?['id'] ?? '',
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'])
          : DateTime.now(),
    );
  }
}

class BusinessCustomerController {
  /// Get or create a business-customer relationship
  /// Returns Either<Failure, BusinessCustomer>
  static Future<Either<Failure, BusinessCustomer>> getOrCreateBusinessCustomer({
    required String businessId,
    required String customerId,
  }) async {
    // First, try to get existing relationship
    final url = BusinessCustomerEndpoints.byCustomer(customerId);
    print('🔵 [BusinessCustomerController] Getting business-customer relationship');
    print('🔵 [BusinessCustomerController] URL: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        // Check if relationship already exists for this business
        for (var bcData in jsonData) {
          final bc = BusinessCustomer.fromJson(bcData);
          if (bc.businessId == businessId) {
            print('✅ [BusinessCustomerController] Found existing business-customer relationship');
            return Right(bc);
          }
        }
      }

      // Relationship doesn't exist, create a new one
      print('🔵 [BusinessCustomerController] Creating new business-customer relationship');
      return await createBusinessCustomer(
        businessId: businessId,
        customerId: customerId,
      );
    } catch (e) {
      // If get fails, try to create
      return await createBusinessCustomer(
        businessId: businessId,
        customerId: customerId,
      );
    }
  }

  /// Create a new business-customer relationship
  /// Returns Either<Failure, BusinessCustomer>
  static Future<Either<Failure, BusinessCustomer>> createBusinessCustomer({
    required String businessId,
    required String customerId,
  }) async {
    final url = BusinessCustomerEndpoints.create();
    print('🔵 [BusinessCustomerController] Creating business-customer relationship');
    print('🔵 [BusinessCustomerController] URL: $url');

    try {
      print('🔵 [BusinessCustomerController] Making HTTP POST request...');
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'business_id': businessId,
          'customer_id': customerId,
        }),
      );

      print('🔵 [BusinessCustomerController] Response received');
      print('🔵 [BusinessCustomerController] Status Code: ${response.statusCode}');
      print('🔵 [BusinessCustomerController] Response Body: ${response.body}');

      if (response.statusCode == 201) {
        try {
          print('🔵 [BusinessCustomerController] Parsing JSON response...');
          final jsonData = json.decode(response.body);
          final bc = BusinessCustomer.fromJson(jsonData);
          print('✅ [BusinessCustomerController] Successfully created business-customer relationship');
          return Right(bc);
        } catch (e, stackTrace) {
          print('❌ [BusinessCustomerController] Parse Error: $e');
          print('❌ [BusinessCustomerController] Stack Trace: $stackTrace');
          return Left(ParseFailure(
            'Failed to parse business-customer: ${e.toString()}',
          ));
        }
      } else {
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['error'] ?? 'Failed to create business-customer relationship';
          print('❌ [BusinessCustomerController] Error: $errorMessage');
          return Left(ServerFailure(
            errorMessage,
            statusCode: response.statusCode,
          ));
        } catch (e) {
          return Left(ServerFailure(
            'Failed to create business-customer relationship: ${response.body}',
            statusCode: response.statusCode,
          ));
        }
      }
    } on http.ClientException catch (e, stackTrace) {
      print('❌ [BusinessCustomerController] Network Exception: ${e.message}');
      print('❌ [BusinessCustomerController] Stack Trace: $stackTrace');
      return Left(NetworkFailure(
        'Network error: ${e.message}',
      ));
    } catch (e, stackTrace) {
      print('❌ [BusinessCustomerController] Unexpected Error: $e');
      print('❌ [BusinessCustomerController] Error Type: ${e.runtimeType}');
      print('❌ [BusinessCustomerController] Stack Trace: $stackTrace');
      return Left(NetworkFailure(
        'Unexpected error: ${e.toString()}',
      ));
    }
  }
}
