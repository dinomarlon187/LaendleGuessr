import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:laendle_guessr/services/api_service.dart';
import 'package:laendle_guessr/services/quest_service.dart';
import 'package:laendle_guessr/data_objects/quest.dart';
import 'package:laendle_guessr/data_objects/city.dart';
import 'package:laendle_guessr/data_objects/user.dart';

void main() {
  late HttpServer server;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    ApiService('http://${server.address.address}:${server.port}');
  });

  tearDown(() async {
    await server.close(force: true);
  });

  test('getAllQuests returns list of Quests', () async {
    final q1 = {'qid':1,'image':'i1','city':0,'coordinates':'1.0,2.0'};
    final q2 = {'qid':2,'image':'i2','city':1,'coordinates':'3.0,4.0'};
    server.listen((req) async {
      if (req.method=='GET' && req.uri.path=='/all_quests') {
        req.response.statusCode = 200;
        req.response.write(jsonEncode([q1, q2]));
      } else {
        req.response.statusCode = 404;
      }
      await req.response.close();
    });
    final list = await QuestService.instance.getAllQuests();
    expect(list, isA<List<Quest>>());
    expect(list.length, 2);
    expect(list[0].qid, 1);
    expect(list[1].city, City.dornbirn);
  });

  test('getAllDoneQuestsByUser returns list of Quests', () async {
    final qJson = {'quest':{'qid':3,'image':'i3','city':2,'coordinates':'5.0,6.0'}};
    server.listen((req) async {
      if (req.method=='GET' && req.uri.path=='/all_quests_user/5') {
        req.response.statusCode = 200;
        req.response.write(jsonEncode([qJson]));
      } else {
        req.response.statusCode = 404;
      }
      await req.response.close();
    });
    final user = User(uid:5, username:'u', password:'p', isAdmin:false, city:City.bludenz, coins:0);
    final done = await QuestService.instance.getAllDoneQuestsByUser(user);
    expect(done.first.qid, 3);
  });

  test('getdailyQuest returns first Quest', () async {
    final qJson = {'qid':4,'image':'i4','city':3,'coordinates':'7.0,8.0'};
    server.listen((req) async {
      if (req.method=='GET' && req.uri.path=='/dailyquest/0') {
        req.response.statusCode = 200;
        req.response.write(jsonEncode([qJson]));
      } else {
        req.response.statusCode = 404;
      }
      await req.response.close();
    });
    final quest = await QuestService.instance.getdailyQuest(City.bregenz);
    expect(quest.qid, 4);
  });

  test('getweeklyQuest returns first Quest', () async {
    final qJson = {'qid':5,'image':'i5','city':4,'coordinates':'9.0,10.0'};
    server.listen((req) async {
      if (req.method=='GET' && req.uri.path=='/weeklyquest') {
        req.response.statusCode = 200;
        req.response.write(jsonEncode([qJson]));
      } else {
        req.response.statusCode = 404;
      }
      await req.response.close();
    });
    final quest = await QuestService.instance.getweeklyQuest();
    expect(quest.city, City.bludenz);
  });

  test('getQuestById returns Quest', () async {
    final qJson = {'qid':6,'image':'i6','city':1,'coordinates':'11.0,12.0'};
    server.listen((req) async {
      if (req.method=='GET' && req.uri.path=='/quest/6') {
        req.response.statusCode = 200;
        req.response.write(jsonEncode(qJson));
      } else {
        req.response.statusCode = 404;
      }
      await req.response.close();
    });
    final quest = await QuestService.instance.getQuestById(6);
    expect(quest.latitude, 11.0);
  });

  test('postQuestDoneByUser throws on error', () async {
    server.listen((req) async {
      if (req.method=='POST' && req.uri.path=='/quest_user') {
        req.response.statusCode = 500;
      }
      await req.response.close();
    });
    expect(
      () => QuestService.instance.postQuestDoneByUser(1,1,0,0),
      throwsException
    );
  });

  test('addQuestToActive and removeQuestFromActive error', () async {
    server.listen((req) async {
      if ((req.method=='POST' && req.uri.path=='/activequest') ||
          (req.method=='DELETE' && req.uri.path=='/activequest/1')) {
        req.response.statusCode = 500;
      }
      await req.response.close();
    });
    expect(
      () => QuestService.instance.addQuestToActive(User(uid:1, username:'u', password:'p', isAdmin:false, city:City.bregenz, coins:0), 1),
      throwsException
    );
    expect(
      () => QuestService.instance.removeQuestFromActive(User(uid:1, username:'u', password:'p', isAdmin:false, city:City.bregenz, coins:0)),
      throwsException
    );
  });
}
