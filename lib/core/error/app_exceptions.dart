class AppException implements Exception {
  AppException(this.message, {this.code, this.originalError});

  final String message;
  final String? code;
  final dynamic originalError;

  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.originalError});
}

class ApiException extends AppException {
  ApiException(super.message, {super.code, this.statusCode, super.originalError});

  final int? statusCode;
}

class StorageException extends AppException {
  StorageException(super.message, {super.code, super.originalError});
}

class SecurityException extends AppException {
  SecurityException(super.message, {super.code, super.originalError});
}
