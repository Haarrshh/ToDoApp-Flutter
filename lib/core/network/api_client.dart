import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/env_config.dart';
import '../error/app_exceptions.dart';

class ApiClient {
  ApiClient({String? baseUrl})
      : _baseUrl = baseUrl ?? EnvConfig.instance.apiBaseUrl;

  final String _baseUrl;
  final _client = http.Client();

  Future<dynamic> get(String path) async {
    return _request(() => _client.get(Uri.parse('$_baseUrl$path')));
  }

  Future<Map<String, dynamic>> post(String path,
      {Map<String, dynamic>? body}) async {
    final result = await _request(() => _client.post(
          Uri.parse('$_baseUrl$path'),
          headers: {'Content-Type': 'application/json'},
          body: body != null ? jsonEncode(body) : null,
        ));
    return result as Map<String, dynamic>? ?? {};
  }

  Future<Map<String, dynamic>> put(String path,
      {Map<String, dynamic>? body}) async {
    final result = await _request(() => _client.put(
          Uri.parse('$_baseUrl$path'),
          headers: {'Content-Type': 'application/json'},
          body: body != null ? jsonEncode(body) : null,
        ));
    return result as Map<String, dynamic>? ?? {};
  }

  Future<void> delete(String path) async {
    await _request(
      () => _client.delete(Uri.parse('$_baseUrl$path')),
      expectEmpty: true,
    );
  }

  Future<dynamic> _request(
    Future<http.Response> Function() call, {
    bool expectEmpty = false,
  }) async {
    try {
      final response = await call();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (expectEmpty || response.body.isEmpty) return null;
        return jsonDecode(response.body);
      }
      throw ApiException(
        'Request failed: ${response.statusCode}',
        statusCode: response.statusCode,
        originalError: response.body,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException(e.toString(), originalError: e);
    }
  }

  void close() => _client.close();
}
