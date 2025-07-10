import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

abstract class IHttpClient {
  Future<http.Response> get({required String url});
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
}
