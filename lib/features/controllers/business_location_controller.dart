import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import '../../core/api.dart';
import '../../core/failures.dart';
import '../models/business_location_model.dart';

class BusinessLocationController {
  /// Fetch all business locations for a specific business
  /// Returns Either<Failure, List<BusinessLocation>>
  static Future<Either<Failure, List<BusinessLocation>>> fetchLocationsByBusiness(
    String businessId,
  ) async {
    final url = BusinessLocationEndpoints.byBusiness(businessId);
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
          final locations = jsonData
              .map((json) => BusinessLocation.fromJson(json))
              .toList();
          return Right(locations);
        } catch (e) {
          return Left(ParseFailure(
            'Failed to parse business locations: ${e.toString()}',
          ));
        }
      } else if (response.statusCode == 404) {
        return Left(NotFoundFailure(
          'Business locations not found',
          statusCode: response.statusCode,
        ));
      } else if (response.statusCode == 401) {
        return Left(UnauthorizedFailure(
          'Unauthorized access',
          statusCode: response.statusCode,
        ));
      } else {
        return Left(ServerFailure(
          'Failed to load business locations: ${response.body}',
          statusCode: response.statusCode,
        ));
      }
    } on http.ClientException catch (e) {
      return Left(NetworkFailure(
        'Network error: ${e.message}',
      ));
    } catch (e) {
      return Left(NetworkFailure(
        'Unexpected error: ${e.toString()}',
      ));
    }
  }
}
