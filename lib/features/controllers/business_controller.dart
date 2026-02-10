import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import '../../core/api.dart';
import '../../core/failures.dart';
import '../models/business_model.dart';


class BusinessController {
  /// Fetch all businesses from the API
  /// Returns Either<Failure, List<Business>>
  /// Left contains Failure on error, Right contains List<Business> on success
  static Future<Either<Failure, List<Business>>> fetchAllBusinesses() async {
    final url = BusinessEndpoints.all();
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
          
          final businesses = jsonData
              .map((json) {
                return Business.fromJson(json);
              })
              .toList();
          
          return Right(businesses);
        } catch (e) {
          return Left(ParseFailure(
            'Failed to parse businesses: ${e.toString()}',
          ));
        }
      } else if (response.statusCode == 404) {
        return Left(NotFoundFailure(
          'Businesses not found',
          statusCode: response.statusCode,
        ));
      } else if (response.statusCode == 401) {
        return Left(UnauthorizedFailure(
          'Unauthorized access',
          statusCode: response.statusCode,
        ));
      } else {
        return Left(ServerFailure(
          'Failed to load businesses: ${response.body}',
          statusCode: response.statusCode,
        ));
      }
    } on http.ClientException catch (e) {
      return Left(NetworkFailure(
        'Network error: ${e.message}',
      ));
    } catch (e, stackTrace) {
      return Left(NetworkFailure(
        'Unexpected error: ${e.toString()}',
      ));
    }
  }

  /// Fetch a single business by ID
  /// Returns Either<Failure, Business>
  /// Left contains Failure on error, Right contains Business on success
  static Future<Either<Failure, Business>> fetchBusinessById(String id) async {
    final url = BusinessEndpoints.byId(id);

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
          return Right(business);
        } catch (e ) {
          return Left(ParseFailure(
            'Failed to parse business: ${e.toString()}',
          ));
        }
      } else if (response.statusCode == 404) {
        return Left(NotFoundFailure(
          'Business not found',
          statusCode: response.statusCode,
        ));
      } else if (response.statusCode == 401) {
        return Left(UnauthorizedFailure(
          'Unauthorized access',
          statusCode: response.statusCode,
        ));
      } else {
        return Left(ServerFailure(
          'Failed to load business: ${response.body}',
          statusCode: response.statusCode,
        ));
      }
    } on http.ClientException catch (e ) {
      return Left(NetworkFailure(
        'Network error: ${e.message}',
      ));
    } catch (e ) {
      return Left(NetworkFailure(
        'Unexpected error: ${e.toString()}',
      ));
    }
  }
}
