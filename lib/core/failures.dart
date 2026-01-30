/// Base class for all failures in the application
abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Failure for server errors (4xx, 5xx responses)
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});

  @override
  String toString() => statusCode != null
      ? 'Server Error ($statusCode): $message'
      : 'Server Error: $message';
}

/// Failure for network/connection errors
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);

  @override
  String toString() => 'Network Error: $message';
}

/// Failure for parsing/format errors
class ParseFailure extends Failure {
  const ParseFailure(super.message);

  @override
  String toString() => 'Parse Error: $message';
}

/// Failure for not found errors (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.statusCode});

  @override
  String toString() => 'Not Found: $message';
}

/// Failure for unauthorized errors (401)
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message, {super.statusCode});

  @override
  String toString() => 'Unauthorized: $message';
}

/// Failure for validation errors
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);

  @override
  String toString() => 'Validation Error: $message';
}
