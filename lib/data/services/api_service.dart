import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

enum Method { get, post, put, delete }

class ApiService {
  ApiService({http.Client? client, String? apiKey, RequestLogger? logger})
      : client = client ?? http.Client(),
        apiKey = apiKey ?? dotenv.env['API_KEY'],
        logger = logger ?? debugPrint;

  final http.Client client;
  final String? apiKey;
  final RequestLogger logger;

  Future<dynamic> sendRequest(
    Method method, {
    url,
    params,
    headers,
    Object? body,
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
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
        response = await client.delete(
          uri,
          headers: requestHeaders,
          body: requestBody,
        );
        break;
      case Method.get:
        response = await client.get(uri, headers: requestHeaders);
        break;
    }

    _logResponse(uri, params, response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    }

    return null;
  }

  Uri _redactedUri(Uri uri) {
    return uri.replace(
      queryParameters: <String, String>{
        ...uri.queryParameters,
        'appid': 'redacted',
      },
    );
  }

  void _logResponse(Uri uri, dynamic params, http.Response response) {
    logger('url--------------${_redactedUri(uri)}');
    logger('params-----------${params.toString()}');
    logger('status-----------${response.statusCode}');
    logger('body-------------${response.body}');
  }
}

typedef RequestLogger = void Function(String message);
