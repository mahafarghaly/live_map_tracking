import 'package:dio/dio.dart';
import '../network/api_constants.dart';

class DioFactory {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': ApiConstants.apiKey,
        'X-Goog-FieldMask': '*',
      },
    ),
  );

  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    return await _dio.get(path, queryParameters: query);
  }

  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    return await _dio.post(path, data: data);
  }
}
