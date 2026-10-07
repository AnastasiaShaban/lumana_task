import 'package:dio/dio.dart';

import 'constants.dart';

class AppException implements Exception {
  final String message;

  const AppException(this.message);

  factory AppException.from(Object error) {
    if (error is AppException) return error;
    if (error is! DioException) {
      return const AppException(AppStrings.errUnknown);
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AppException(AppStrings.errTimeout);
      case DioExceptionType.connectionError:
        return const AppException(AppStrings.errNoConnection);
      case DioExceptionType.badResponse:
        return const AppException(AppStrings.errServer);
      default:
        return const AppException(AppStrings.errUnknown);
    }
  }

  @override
  String toString() => message;
}
