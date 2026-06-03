import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

enum Method { get, post, put, delete }

class ApiService {
  ApiService({http.Client? client})
      : client = client ?? http.Client(),
        apiKey = dotenv.env['API_KEY'];

  final http.Client client;
  final String? apiKey;

  Future<dynamic> sendRequest(
    Method method, {
    url,
    params,
    headers,
    Object? body,
  }) async {
    print('--- API Request ---');
    print('method: $method');
    print('url: $url');
    print('params: $params');
    print('body: $body');

    if (apiKey == null || apiKey!.isEmpty) {
      print('Missing API key');
      return null;
    }

    final mergedParams = <String, dynamic>{
      if (params != null) ...params,
      'appid': apiKey ?? '',
    };

    final uri = Uri.parse(url).replace(queryParameters: mergedParams);

    final requestHeaders = <String, String>{
      'Accept': 'application/json',
      if (headers != null) ...headers,
    };

    Object? requestBody = body;
    if (body is Map<String, dynamic> || body is List) {
      requestHeaders['Content-Type'] = 'application/json';
      requestBody = json.encode(body);
    }

    late http.Response response;
    switch (method) {
      case Method.post:
        response =
            await client.post(uri, headers: requestHeaders, body: requestBody);
        break;
      case Method.put:
        response =
            await client.put(uri, headers: requestHeaders, body: requestBody);
        break;
      case Method.delete:
        response = await client.delete(uri,
            headers: requestHeaders, body: requestBody);
        break;
      case Method.get:
        response = await client.get(uri, headers: requestHeaders);
        break;
    }

    print('--- API Response ---');
    print('status: ${response.statusCode}');
    print('url: $uri');
    print('method: $method');
    print('body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    }

    return null;
  }
}
