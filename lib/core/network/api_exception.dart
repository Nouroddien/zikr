class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.cause});

  final String message;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class NetworkException extends ApiException {
  const NetworkException(super.message, {super.cause});
}

class TimeoutException extends ApiException {
  const TimeoutException([super.message = 'Request timed out']);
}

class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode});
}
