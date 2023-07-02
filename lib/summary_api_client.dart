import 'dart:async';

import 'package:http/http.dart' as http;

class SummaryApiClient {
  static const String baseUrl = "";
  static const String urlExt = "";

  final http.Client _httpClient;

  SummaryApiClient({
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Future<String> getSummary(url, message) async {
    final request = Uri.https(
      baseUrl,
      urlExt,
      {'url': url, 'message': message},
    );

    final response = await _httpClient.get(request, headers: {
      'Content-Type': 'application/json',
      'Accept': '*/*',
    });

    return response.body;
  }
}
