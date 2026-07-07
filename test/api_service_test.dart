import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:weather_test/data/services/api_service.dart';

void main() {
  test('logs request and response details in PearlyBarbados style', () async {
    final logs = <String>[];
    final service = ApiService(
      apiKey: 'test-key',
      logger: logs.add,
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.queryParameters['appid'], 'test-key');
        return http.Response('{"ok":true}', 200);
      }),
    );

    await service.sendRequest(
      Method.get,
      url: 'https://example.com/weather',
      params: <String, dynamic>{'lat': '13.1', 'lon': '-59.61'},
    );

    expect(logs, hasLength(4));
    expect(logs[0], startsWith('url--------------'));
    expect(logs[0], contains('https://example.com/weather'));
    expect(logs[0], contains('appid=redacted'));
    expect(logs[1], 'params-----------{lat: 13.1, lon: -59.61}');
    expect(logs[2], 'status-----------200');
    expect(logs[3], 'body-------------{"ok":true}');
    expect(logs.join('\n'), isNot(contains('test-key')));
  });
}
