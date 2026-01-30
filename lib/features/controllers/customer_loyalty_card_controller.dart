import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import '../../core/api.dart';
import '../../core/failures.dart';
import '../models/customer_loyalty_card_model.dart';

class CustomerLoyaltyCardController {
  /// Get all loyalty cards for a customer (by customer id)
  /// Returns Either<Failure, List<CustomerLoyaltyCard>>
  static Future<Either<Failure, List<CustomerLoyaltyCard>>> getLoyaltyCardsByCustomer({
    required String customerId,
  }) async {
    final url = CustomerLoyaltyCardEndpoints.byCustomer(customerId);
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final cards = jsonList
            .map((e) => CustomerLoyaltyCard.fromJson(e as Map<String, dynamic>))
            .toList();
        return Right(cards);
      } else {
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['error'] ?? 'Failed to get loyalty cards';
          return Left(ServerFailure(errorMessage, statusCode: response.statusCode));
        } catch (_) {
          return Left(ServerFailure(response.body, statusCode: response.statusCode));
        }
      }
    } on http.ClientException catch (e) {
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(NetworkFailure('Unexpected error: ${e.toString()}'));
    }
  }

  /// Get or create a customer loyalty card for a business customer and loyalty program
  /// Returns Either<Failure, CustomerLoyaltyCard>
  static Future<Either<Failure, CustomerLoyaltyCard>> getOrCreateLoyaltyCard({
    required String businessCustomerId,
    required String loyaltyProgramId,
  }) async {
    // First, try to get existing cards for this business customer
    final url = CustomerLoyaltyCardEndpoints.byBusinessCustomer(businessCustomerId);
    print('🔵 [CustomerLoyaltyCardController] Getting loyalty cards for business customer');
    print('🔵 [CustomerLoyaltyCardController] URL: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        // Check if card already exists for this program
        for (var cardData in jsonData) {
          final card = CustomerLoyaltyCard.fromJson(cardData);
          if (card.loyaltyProgramId == loyaltyProgramId) {
            print('✅ [CustomerLoyaltyCardController] Found existing loyalty card');
            return Right(card);
          }
        }
      }

      // Card doesn't exist, create a new one
      print('🔵 [CustomerLoyaltyCardController] Creating new loyalty card');
      return await createLoyaltyCard(
        businessCustomerId: businessCustomerId,
        loyaltyProgramId: loyaltyProgramId,
      );
    } catch (e) {
      // If get fails, try to create
      return await createLoyaltyCard(
        businessCustomerId: businessCustomerId,
        loyaltyProgramId: loyaltyProgramId,
      );
    }
  }

  /// Create a new customer loyalty card
  /// Returns Either<Failure, CustomerLoyaltyCard>
  static Future<Either<Failure, CustomerLoyaltyCard>> createLoyaltyCard({
    required String businessCustomerId,
    required String loyaltyProgramId,
  }) async {
    final url = CustomerLoyaltyCardEndpoints.create();
    print('🔵 [CustomerLoyaltyCardController] Creating loyalty card');
    print('🔵 [CustomerLoyaltyCardController] URL: $url');

    try {
      print('🔵 [CustomerLoyaltyCardController] Making HTTP POST request...');
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'business_customer_id': businessCustomerId,
          'loyalty_program_id': loyaltyProgramId,
        }),
      );

      print('🔵 [CustomerLoyaltyCardController] Response received');
      print('🔵 [CustomerLoyaltyCardController] Status Code: ${response.statusCode}');
      print('🔵 [CustomerLoyaltyCardController] Response Body: ${response.body}');

      if (response.statusCode == 201) {
        try {
          print('🔵 [CustomerLoyaltyCardController] Parsing JSON response...');
          final jsonData = json.decode(response.body);
          final card = CustomerLoyaltyCard.fromJson(jsonData);
          print('✅ [CustomerLoyaltyCardController] Successfully created loyalty card');
          return Right(card);
        } catch (e, stackTrace) {
          print('❌ [CustomerLoyaltyCardController] Parse Error: $e');
          print('❌ [CustomerLoyaltyCardController] Stack Trace: $stackTrace');
          return Left(ParseFailure(
            'Failed to parse loyalty card: ${e.toString()}',
          ));
        }
      } else {
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['error'] ?? 'Failed to create loyalty card';
          print('❌ [CustomerLoyaltyCardController] Error: $errorMessage');
          return Left(ServerFailure(
            errorMessage,
            statusCode: response.statusCode,
          ));
        } catch (e) {
          return Left(ServerFailure(
            'Failed to create loyalty card: ${response.body}',
            statusCode: response.statusCode,
          ));
        }
      }
    } on http.ClientException catch (e, stackTrace) {
      print('❌ [CustomerLoyaltyCardController] Network Exception: ${e.message}');
      print('❌ [CustomerLoyaltyCardController] Stack Trace: $stackTrace');
      return Left(NetworkFailure(
        'Network error: ${e.message}',
      ));
    } catch (e, stackTrace) {
      print('❌ [CustomerLoyaltyCardController] Unexpected Error: $e');
      print('❌ [CustomerLoyaltyCardController] Error Type: ${e.runtimeType}');
      print('❌ [CustomerLoyaltyCardController] Stack Trace: $stackTrace');
      return Left(NetworkFailure(
        'Unexpected error: ${e.toString()}',
      ));
    }
  }
}
