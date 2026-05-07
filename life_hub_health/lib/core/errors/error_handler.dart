import 'package:dio/dio.dart';
import 'app_exception.dart';

class ErrorHandler {
  static String getFriendlyMessage(dynamic error) {
    return _mapError(error).message;
  }

  static AppException _mapError(dynamic error) {
    if (error is AppException) return error;

    if (error is DioException) {
      return _mapDioError(error);
    }

    // Handle generic Exception('message') pattern
    if (error is Exception) {
      final str = error.toString();
      // Strip "Exception: " prefix from our repository throws
      final message = str.startsWith('Exception: ')
          ? str.substring('Exception: '.length)
          : str;
      return AppException(
        message: message,
        type: AppErrorType.unknown,
        originalError: str,
      );
    }

    return AppException(
      message: '操作失败，请稍后重试',
      type: AppErrorType.unknown,
      originalError: error.toString(),
    );
  }

  static AppException _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException(
          message: '网络连接超时，请检查网络后重试',
          type: AppErrorType.timeout,
          originalError: error.toString(),
        );

      case DioExceptionType.connectionError:
        return AppException(
          message: '网络连接失败，请检查网络设置',
          type: AppErrorType.network,
          originalError: error.toString(),
        );

      case DioExceptionType.badResponse:
        return _mapResponseError(error);

      case DioExceptionType.cancel:
        return AppException(
          message: '请求已取消',
          type: AppErrorType.unknown,
          originalError: error.toString(),
        );

      case DioExceptionType.badCertificate:
        return AppException(
          message: '安全证书验证失败',
          type: AppErrorType.network,
          originalError: error.toString(),
        );

      default:
        return AppException(
          message: '网络异常，请稍后重试',
          type: AppErrorType.network,
          originalError: error.toString(),
        );
    }
  }

  static AppException _mapResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // Try to extract server error message
    String? serverMessage;
    if (data is Map<String, dynamic>) {
      serverMessage = data['message'] as String?;
    }

    switch (statusCode) {
      case 400:
        return AppException(
          message: serverMessage ?? '请求参数错误',
          type: AppErrorType.server,
          statusCode: statusCode,
          originalError: error.toString(),
        );
      case 401:
        return AppException(
          message: '登录已过期，请重新登录',
          type: AppErrorType.unauthorized,
          statusCode: statusCode,
          originalError: error.toString(),
        );
      case 403:
        return AppException(
          message: '没有操作权限',
          type: AppErrorType.unauthorized,
          statusCode: statusCode,
          originalError: error.toString(),
        );
      case 404:
        return AppException(
          message: '请求的资源不存在',
          type: AppErrorType.notFound,
          statusCode: statusCode,
          originalError: error.toString(),
        );
      case 500:
        return AppException(
          message: '服务器内部错误，请稍后重试',
          type: AppErrorType.server,
          statusCode: statusCode,
          originalError: error.toString(),
        );
      case 502:
      case 503:
        return AppException(
          message: '服务暂时不可用，请稍后重试',
          type: AppErrorType.server,
          statusCode: statusCode,
          originalError: error.toString(),
        );
      default:
        return AppException(
          message: serverMessage ?? '服务器错误 ($statusCode)',
          type: AppErrorType.server,
          statusCode: statusCode,
          originalError: error.toString(),
        );
    }
  }
}
