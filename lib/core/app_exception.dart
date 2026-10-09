import 'package:dio/dio.dart';

enum AppExceptionType { timeout, noConnection, server, offlineNoCache, unknown }

class AppException implements Exception {
  final AppExceptionType type;
  final String? message;

  const AppException(this.type, [this.message]);

  factory AppException.from(Object error) {
    if (error is AppException) return error;
    if (error is! DioException) {
      return const AppException(AppExceptionType.unknown);
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AppException(AppExceptionType.timeout);
      case DioExceptionType.connectionError:
        return const AppException(AppExceptionType.noConnection);
      case DioExceptionType.badResponse:
        return const AppException(AppExceptionType.server);
      default:
        return const AppException(AppExceptionType.unknown);
    }
  }

  @override
  String toString() => message ?? type.name;
}
