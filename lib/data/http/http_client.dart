import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

abstract class IHttpClient {
  Future<http.Response> get({required String url});
   Future<http.Response> post({
    required String url,
    Map<String, dynamic>? body,
  });
}

class HttpClient implements IHttpClient {
  final client = http.Client();

  @override
  Future<http.Response> get({required String url}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return await client.get(Uri.parse(url), headers: headers);
  }

  @override
  Future<http.Response> post({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final jsonBody = body != null ? jsonEncode(body) : null;

    return await client.post(
      Uri.parse(url),
      headers: headers,
      body: jsonBody,
    );
  }
}
