import 'package:flutter_test/flutter_test.dart';
import 'package:laendle_guessr/manager/questmanager.dart';
import 'package:laendle_guessr/data_objects/city.dart';
import 'package:laendle_guessr/data_objects/quest.dart';
import 'package:laendle_guessr/data_objects/user.dart';

class DummyQuest extends Quest {
  DummyQuest({required int qid, required String image, required City city, required double latitude, required double longitude})
      : super(qid: qid, image: image, city: city, latitude: latitude, longitude: longitude);
}

class DummyUser extends User {
  DummyUser({required int uid, required String username, required String password, required bool isAdmin, required City city, required int coins})
      : super(uid: uid, username: username, password: password, isAdmin: isAdmin, city: city, coins: coins);
}

void main() {
  test('elapsedTime formats correctly', () {
    final qm = QuestManager.instance;
    qm.elapsedSeconds = 0;
    expect(qm.elapsedTime, '00:00:00');
    qm.elapsedSeconds = 3661;
    expect(qm.elapsedTime, '01:01:01');
  });

  test('isRunning reflects questTimer state', () {
    final qm = QuestManager.instance;
    qm.questTimer?.cancel();
    expect(qm.isRunning, false);
  });

  test('getDailyQuestForUser returns correct quest', () {
    final qm = QuestManager.instance;
    final city = City.feldkirch;
    final quest = DummyQuest(qid: 1, image: 'img', city: city, latitude: 0.0, longitude: 0.0);
    qm.dailyQuestByCity.clear();
    qm.dailyQuestByCity[city] = quest;
    final user = DummyUser(uid: 1, username: 'u', password: 'p', isAdmin: false, city: city, coins: 0);
    qm.userManager.currentUser = user;
    expect(qm.getDailyQuestForUser(), quest);
  });
}
