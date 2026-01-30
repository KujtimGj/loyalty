import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import '../../core/api.dart';
import '../../core/failures.dart';
import '../models/loyalty_program_model.dart';

class LoyaltyProgramController {
  /// Fetch all loyalty programs
  /// Returns Either<Failure, List<LoyaltyProgram>>
  static Future<Either<Failure, List<LoyaltyProgram>>> fetchAllLoyaltyPrograms() async {
    final url = LoyaltyProgramEndpoints.all();

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);

          final programs = jsonData
              .map((json) {
                return LoyaltyProgram.fromJson(json);
              })
              .toList();

          return Right(programs);
        } catch (e, stackTrace) {
          print('❌ [LoyaltyProgramController] Parse Error: $e');
          print('❌ [LoyaltyProgramController] Stack Trace: $stackTrace');
          return Left(ParseFailure(
            'Failed to parse loyalty programs: ${e.toString()}',
          ));
        }
      } else if (response.statusCode == 404) {
        print('❌ [LoyaltyProgramController] 404 Not Found');
        return Left(NotFoundFailure(
          'Loyalty programs not found',
          statusCode: response.statusCode,
        ));
      } else if (response.statusCode == 401) {
        print('❌ [LoyaltyProgramController] 401 Unauthorized');
        return Left(UnauthorizedFailure(
          'Unauthorized access',
          statusCode: response.statusCode,
        ));
      } else {
        print('❌ [LoyaltyProgramController] Server Error: ${response.statusCode}');
        print('❌ [LoyaltyProgramController] Error Body: ${response.body}');
        return Left(ServerFailure(
          'Failed to load loyalty programs: ${response.body}',
          statusCode: response.statusCode,
        ));
      }
    } on http.ClientException catch (e, stackTrace) {
      print('❌ [LoyaltyProgramController] Network Exception: ${e.message}');
      print('❌ [LoyaltyProgramController] Stack Trace: $stackTrace');
      return Left(NetworkFailure(
        'Network error: ${e.message}',
      ));
    } catch (e, stackTrace) {
      print('❌ [LoyaltyProgramController] Unexpected Error: $e');
      print('❌ [LoyaltyProgramController] Error Type: ${e.runtimeType}');
      print('❌ [LoyaltyProgramController] Stack Trace: $stackTrace');
      return Left(NetworkFailure(
        'Unexpected error: ${e.toString()}',
      ));
    }
  }

  /// Fetch all loyalty programs for a business
  /// Returns Either<Failure, List<LoyaltyProgram>>
  static Future<Either<Failure, List<LoyaltyProgram>>> fetchLoyaltyProgramsByBusiness(
    String businessId,
  ) async {
    final url = LoyaltyProgramEndpoints.byBusiness(businessId);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);

          final programs = jsonData
              .map((json) {
                return LoyaltyProgram.fromJson(json);
              })
              .toList();

          print('✅ [LoyaltyProgramController] Successfully fetched ${programs.length} loyalty programs');
          return Right(programs);
        } catch (e, stackTrace) {
          print('❌ [LoyaltyProgramController] Parse Error: $e');
          print('❌ [LoyaltyProgramController] Stack Trace: $stackTrace');
          return Left(ParseFailure(
            'Failed to parse loyalty programs: ${e.toString()}',
          ));
        }
      } else if (response.statusCode == 404) {
        print('❌ [LoyaltyProgramController] 404 Not Found');
        return Left(NotFoundFailure(
          'Loyalty programs not found',
          statusCode: response.statusCode,
        ));
      } else if (response.statusCode == 401) {
        print('❌ [LoyaltyProgramController] 401 Unauthorized');
        return Left(UnauthorizedFailure(
          'Unauthorized access',
          statusCode: response.statusCode,
        ));
      } else {
        print('❌ [LoyaltyProgramController] Server Error: ${response.statusCode}');
        print('❌ [LoyaltyProgramController] Error Body: ${response.body}');
        return Left(ServerFailure(
          'Failed to load loyalty programs: ${response.body}',
          statusCode: response.statusCode,
        ));
      }
    } on http.ClientException catch (e, stackTrace) {
      print('❌ [LoyaltyProgramController] Network Exception: ${e.message}');
      print('❌ [LoyaltyProgramController] Stack Trace: $stackTrace');
      return Left(NetworkFailure(
        'Network error: ${e.message}',
      ));
    } catch (e, stackTrace) {
      print('❌ [LoyaltyProgramController] Unexpected Error: $e');
      print('❌ [LoyaltyProgramController] Error Type: ${e.runtimeType}');
      print('❌ [LoyaltyProgramController] Stack Trace: $stackTrace');
      return Left(NetworkFailure(
        'Unexpected error: ${e.toString()}',
      ));
    }
  }

  /// Fetch active loyalty programs for a business
  /// Returns Either<Failure, List<LoyaltyProgram>>
  static Future<Either<Failure, List<LoyaltyProgram>>> fetchActiveLoyaltyProgramsByBusiness(
    String businessId,
  ) async {
    final url = LoyaltyProgramEndpoints.activeByBusiness(businessId);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          final programs = jsonData
              .map((json) => LoyaltyProgram.fromJson(json))
              .toList();

          print('✅ [LoyaltyProgramController] Successfully fetched ${programs.length} active loyalty programs');
          return Right(programs);
        } catch (e, stackTrace) {
          print('❌ [LoyaltyProgramController] Parse Error: $e');
          print('❌ [LoyaltyProgramController] Stack Trace: $stackTrace');
          return Left(ParseFailure(
            'Failed to parse loyalty programs: ${e.toString()}',
          ));
        }
      } else if (response.statusCode == 404) {
        print('❌ [LoyaltyProgramController] 404 Not Found');
        return Left(NotFoundFailure(
          'Loyalty programs not found',
          statusCode: response.statusCode,
        ));
      } else if (response.statusCode == 401) {
        print('❌ [LoyaltyProgramController] 401 Unauthorized');
        return Left(UnauthorizedFailure(
          'Unauthorized access',
          statusCode: response.statusCode,
        ));
      } else {
        print('❌ [LoyaltyProgramController] Server Error: ${response.statusCode}');
        print('❌ [LoyaltyProgramController] Error Body: ${response.body}');
        return Left(ServerFailure(
          'Failed to load loyalty programs: ${response.body}',
          statusCode: response.statusCode,
        ));
      }
    } on http.ClientException catch (e, stackTrace) {
      print('❌ [LoyaltyProgramController] Network Exception: ${e.message}');
      print('❌ [LoyaltyProgramController] Stack Trace: $stackTrace');
      return Left(NetworkFailure(
        'Network error: ${e.message}',
      ));
    } catch (e, stackTrace) {
      print('❌ [LoyaltyProgramController] Unexpected Error: $e');
      print('❌ [LoyaltyProgramController] Error Type: ${e.runtimeType}');
      print('❌ [LoyaltyProgramController] Stack Trace: $stackTrace');
      return Left(NetworkFailure(
        'Unexpected error: ${e.toString()}',
      ));
    }
  }
}
