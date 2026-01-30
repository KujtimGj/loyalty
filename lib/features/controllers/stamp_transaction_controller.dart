import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import '../../core/api.dart';
import '../../core/failures.dart';
import '../models/stamp_transaction_model.dart';

class StampTransactionController {
  /// Create a new stamp transaction
  /// Returns Either<Failure, StampTransaction>
  static Future<Either<Failure, StampTransaction>> createStampTransaction({
    required String customerLoyaltyCardId,
    required String businessUserId,
    required String locationId,
    required int stampsAdded,
    String source = 'manual',
  }) async {
    final url = StampTransactionEndpoints.create();
    print('🔵 [StampTransactionController] Creating stamp transaction');
    print('🔵 [StampTransactionController] URL: $url');

    try {
      print('🔵 [StampTransactionController] Making HTTP POST request...');
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'customer_loyalty_card_id': customerLoyaltyCardId,
          'business_user_id': businessUserId,
          'location_id': locationId,
          'stamps_added': stampsAdded,
          'source': source,
        }),
      );

      print('🔵 [StampTransactionController] Response received');
      print('🔵 [StampTransactionController] Status Code: ${response.statusCode}');
      print('🔵 [StampTransactionController] Response Body: ${response.body}');

      if (response.statusCode == 201) {
        try {
          print('🔵 [StampTransactionController] Parsing JSON response...');
          final jsonData = json.decode(response.body);
          final transaction = StampTransaction.fromJson(jsonData);
          print('✅ [StampTransactionController] Successfully created stamp transaction');
          return Right(transaction);
        } catch (e, stackTrace) {
          print('❌ [StampTransactionController] Parse Error: $e');
          print('❌ [StampTransactionController] Stack Trace: $stackTrace');
          return Left(ParseFailure(
            'Failed to parse stamp transaction: ${e.toString()}',
          ));
        }
      } else {
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['error'] ?? 'Failed to create stamp transaction';
          print('❌ [StampTransactionController] Error: $errorMessage');
          return Left(ServerFailure(
            errorMessage,
            statusCode: response.statusCode,
          ));
        } catch (e) {
          return Left(ServerFailure(
            'Failed to create stamp transaction: ${response.body}',
            statusCode: response.statusCode,
          ));
        }
      }
    } on http.ClientException catch (e, stackTrace) {
      print('❌ [StampTransactionController] Network Exception: ${e.message}');
      print('❌ [StampTransactionController] Stack Trace: $stackTrace');
      return Left(NetworkFailure(
        'Network error: ${e.message}',
      ));
    } catch (e, stackTrace) {
      print('❌ [StampTransactionController] Unexpected Error: $e');
      print('❌ [StampTransactionController] Error Type: ${e.runtimeType}');
      print('❌ [StampTransactionController] Stack Trace: $stackTrace');
      return Left(NetworkFailure(
        'Unexpected error: ${e.toString()}',
      ));
    }
  }
}
