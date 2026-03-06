import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class NoInternetException implements Exception {
  const NoInternetException();

  @override
  String toString() => 'NO INTERNET CONNECTION';
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String _baseUrl = 'http://5.78.43.182:5050';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String>? params,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: params);
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException('Server error: ${response.statusCode}');
      }
    } on SocketException {
      throw NoInternetException();
    } on HttpException {
      throw NoInternetException();
    } on HandshakeException {
      throw NoInternetException();
    } catch (e) {
      if (e is NoInternetException || e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }
}
