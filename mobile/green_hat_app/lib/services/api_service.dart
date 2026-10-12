import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/account.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client, FlutterSecureStorage? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  static const _defaultBaseUrl = 'http://localhost:3000/api/v1';
  static const _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  final http.Client _client;
  final FlutterSecureStorage _storage;
  static const _tokenKey = 'green-hat_access_token';

  Future<Account> signUp({
    required String name,
    required String email,
    required String password,
    required String businessSector,
  }) async {
    final data = await _request(
      'POST',
      '/auth/signup',
      body: {
        'email': email.trim(),
        'name': name.trim(),
        'password': password,
        'businessSector': businessSector,
      },
    );
    await _saveToken(data['token'] as String);
    return Account.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<Account> logIn({
    required String email,
    required String password,
  }) async {
    final data = await _request(
      'POST',
      '/auth/login',
      body: {'email': email.trim(), 'password': password},
    );
    await _saveToken(data['token'] as String);
    return Account.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<Account?> restoreSession() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) return null;

    try {
      final data = await _request('GET', '/auth/me', token: token);
      return Account.fromJson(data['user'] as Map<String, dynamic>);
    } on ApiException {
      await logOut();
      return null;
    }
  }

  Future<void> logOut() => _storage.delete(key: _tokenKey);

  Future<void> _saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      final savedToken = await _storage.read(key: _tokenKey);
      if (savedToken != null) headers['Authorization'] = 'Bearer $savedToken';
    }

    try {
      late final http.Response response;
      switch (method) {
        case 'POST':
          response = await _client
              .post(uri, headers: headers, body: jsonEncode(body))
              .timeout(const Duration(seconds: 15));
          break;
        case 'GET':
          response = await _client
              .get(uri, headers: headers)
              .timeout(const Duration(seconds: 15));
          break;
        default:
          throw const ApiException('Unsupported request method.');
      }

      final decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          decoded['error'] as String? ??
              'Something went wrong. Please try again.',
          statusCode: response.statusCode,
        );
      }
      return decoded;
    } on ApiException {
      rethrow;
    } on http.ClientException {
      throw const ApiException(
        'Could not reach the server. Check that it is running and the API URL is correct.',
      );
    } on FormatException {
      throw const ApiException('The server returned an unreadable response.');
    } catch (error) {
      if (kDebugMode) debugPrint('API request failed: $error');
      if (error.toString().contains('TimeoutException')) {
        throw const ApiException('The request timed out. Please try again.');
      }
      rethrow;
    }
  }

  void dispose() => _client.close();
}
