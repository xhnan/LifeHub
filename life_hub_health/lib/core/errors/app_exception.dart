enum AppErrorType {
  network,
  timeout,
  server,
  unauthorized,
  notFound,
  parse,
  storage,
  unknown,
}

class AppException implements Exception {
  final String message;
  final AppErrorType type;
  final int? statusCode;
  final String? originalError;

  AppException({
    required this.message,
    this.type = AppErrorType.unknown,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => message;
}
