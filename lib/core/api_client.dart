import 'package:dio/dio.dart';

class ApiClient {
  static const String baseURL = 'https://dummyjson.com';

  final Dio _dio;

  ApiClient()
      : _dio = Dio(
    BaseOptions(
      baseUrl: baseURL,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }
}

class ApiEndpoints {
  static const String search = '/products/search';
}
