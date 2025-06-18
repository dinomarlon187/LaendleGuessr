import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:laendle_guessr/services/api_service.dart';
import 'package:laendle_guessr/services/user_service.dart';
import 'package:laendle_guessr/manager/usermanager.dart';
import 'package:laendle_guessr/data_objects/user.dart';
import 'package:laendle_guessr/data_objects/city.dart';

void main() {
  late HttpServer server;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    ApiService('http://${server.address.address}:${server.port}');
  });

  tearDown(() async {
    await server.close(force: true);
  });

  test('getAllUsers returns list', () async {
    final usersJson = jsonEncode([
      {'uid':1,'username':'u','password':'p','coins':0,'city':0,'admin':false}
    ]);
    server.listen((req) async {
      if (req.method == 'GET' && req.uri.path == '/user') {
        req.response.statusCode = 200;
        req.response.write(usersJson);
      } else {
        req.response.statusCode = 404;
      }
      await req.response.close();
    });
    final list = await UserService.instance.getAllUsers();
    expect(list, isA<List<dynamic>>());
    expect(list.first['username'], 'u');
  });

  test('checkCredentials returns true on 200', () async {
    server.listen((req) async {
      if (req.method == 'POST' && req.uri.path == '/user/login') {
        req.response.statusCode = 200;
      }
      await req.response.close();
    });
    final ok = await UserService.instance.checkCredentials('a','b');
    expect(ok, true);
  });

  test('checkCredentials returns false on error', () async {
    server.listen((req) async {
      req.response.statusCode = 401;
      await req.response.close();
    });
    final ok = await UserService.instance.checkCredentials('a','b');
    expect(ok, false);
  });

  test('getUser returns map', () async {
    final jsonMap = {'uid':2,'username':'u2','password':'p2','coins':5,'city':1,'admin':true};
    server.listen((req) async {
      if (req.method=='GET' && req.uri.path=='/user/2') {
        req.response.statusCode=200;
        req.response.write(jsonEncode(jsonMap));
      }
      await req.response.close();
    });
    final m = await UserService.instance.getUser('2');
    expect(m['coins'], 5);
  });

  test('registerUser returns map on 201', () async {
    final resp = {'nachricht':'ok'};
    server.listen((req) async {
      if (req.method=='POST' && req.uri.path=='/user') {
        req.response.statusCode=201;
        req.response.write(jsonEncode(resp));
      }
      await req.response.close();
    });
    final m = await UserService.instance.registerUser(username:'x', password:'y', city:1);
    expect(m['nachricht'], 'ok');
  });

  test('updateUser returns map on 200', () async {
    final resp = {'coins':10};
    server.listen((req) async {
      if (req.method=='PUT' && req.uri.path=='/user/3') {
        req.response.statusCode=200;
        req.response.write(jsonEncode(resp));
      }
      await req.response.close();
    });
    final m = await UserService.instance.updateUser(uid:3, coins:10);
    expect(m['coins'], 10);
  });

  test('getAllTimeStats returns stats', () async {
    final stats = {'timeInSeconds':100,'steps':50};
    UserManager.instance.currentUser = User(uid:4, username:'u', password:'p', isAdmin:false, city:City.bregenz, coins:0);
    server.listen((req) async {
      if (req.method=='GET' && req.uri.path=='/all_time_stats/4') {
        req.response.statusCode=200;
        req.response.write(jsonEncode(stats));
      }
      await req.response.close();
    });
    final m = await UserService.instance.getAllTimeStats();
    expect(m['timeInSeconds'], 100);
    expect(m['steps'], 50);
  });
}
