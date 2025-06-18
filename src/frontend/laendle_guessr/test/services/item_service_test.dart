import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:laendle_guessr/services/item_service.dart';
import 'package:laendle_guessr/services/api_service.dart';
import 'package:laendle_guessr/data_objects/item.dart';

void main() {
  late HttpServer server;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    ApiService('http://${server.address.address}:${server.port}');
  });

  tearDown(() async {
    await server.close(force: true);
  });

  test('getAllItems returns parsed list', () async {
    final itemsJson = jsonEncode([
      {'iid':1,'image':'i1','name':'n1','price':10},
      {'iid':2,'image':'i2','name':'n2','price':20},
    ]);
    server.listen((req) async {
      if (req.method=='GET' && req.uri.path=='/item') {
        req.response.statusCode=200;
        req.response.write(itemsJson);
      } else {
        req.response.statusCode=404;
      }
      await req.response.close();
    });

    final list = await ItemService.instance.getAllItems();
    expect(list, isA<List<Item>>());
    expect(list.length, 2);
    expect(list[0].id, 1);
  });

  test('addItemToInventory throws on error', () async {
    server.listen((req) async {
      req.response.statusCode=500;
      await req.response.close();
    });
    expect(
      () => ItemService.instance.addItemToInventory(1, Item(id:3,image:'i',name:'n',price:0)),
      throwsException
    );
  });
}
