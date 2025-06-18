import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:laendle_guessr/services/api_service.dart';

void main() {
  late HttpServer server;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    ApiService('http://${server.address.address}:${server.port}');
  });

  tearDown(() async {
    await server.close(force: true);
  });

  test('GET returns body and status', () async {
    server.listen((HttpRequest req) async {
      if (req.method == 'GET' && req.uri.path == '/test') {
        req.response.statusCode = 200;
        req.response.write('hello');
      } else {
        req.response.statusCode = 404;
      }
      await req.response.close();
    });

    final res = await ApiService.instance.get('test');
    expect(res.statusCode, 200);
    expect(res.body, 'hello');
  });

  test('POST sends JSON and returns status', () async {
    server.listen((HttpRequest req) async {
      if (req.method == 'POST' && req.uri.path == '/submit') {
        expect(req.headers.contentType?.mimeType, 'application/json');
        final body = await utf8.decoder.bind(req).join();
        expect(jsonDecode(body), {'key': 'value'});
        req.response.statusCode = 201;
      } else {
        req.response.statusCode = 404;
      }
      await req.response.close();
    });

    final res = await ApiService.instance.post('submit', {'key': 'value'});
    expect(res.statusCode, 201);
  });

  test('PUT and DELETE methods', () async {
    server.listen((HttpRequest req) async {
      if (req.method == 'PUT' && req.uri.path == '/update') {
        req.response.statusCode = 202;
      } else if (req.method == 'DELETE' && req.uri.path == '/remove') {
        req.response.statusCode = 204;
      } else {
        req.response.statusCode = 404;
      }
      await req.response.close();
    });

    final putRes = await ApiService.instance.put('update', {'a': 1});
    expect(putRes.statusCode, 202);
    final delRes = await ApiService.instance.delete('remove');
    expect(delRes.statusCode, 204);
  });
}
