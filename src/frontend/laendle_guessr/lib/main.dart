import 'package:flutter/material.dart';
import 'maps.dart';
import 'shop.dart';
import 'package:laendle_guessr/controller/appcontroller.dart';
import 'package:laendle_guessr/manager/questmanager.dart';
import 'package:laendle_guessr/services/locationchecker.dart';
import 'package:laendle_guessr/manager/inventory.dart';
import 'package:laendle_guessr/manager/usermanager.dart';
import 'package:laendle_guessr/services/api_service.dart';
import 'package:laendle_guessr/data_objects/quest.dart';
import 'package:laendle_guessr/data_objects/city.dart';
import 'package:laendle_guessr/data_objects/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appController = AppController.instance;
  await appController.questManager.loadQuests();

  final testUser = User(
    uid: 1,
    username: 'Test User',
    city: City.bregenz,
    coins: 100,
  );

  appController.userManager.currentUser = testUser;
  runApp(const LaendleGuessrApp());
}

class LaendleGuessrApp extends StatelessWidget {
  const LaendleGuessrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const MapsPage(),
    ShopPage(),
    const Placeholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Icon(Icons.play_arrow),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Icon(Icons.map),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Icon(Icons.shopping_cart),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Icon(Icons.person),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = AppController.instance;
    final user = appController.userManager.currentUser;
    if (user == null) {
      return const Center(child: Text("Bitte melde dich an, um die Challenges zu sehen."));
    }
    if (appController.questManager.weeklyQuest == null) {
      return const Center(child: Text("Keine wöchentlichen Herausforderungen verfügbar."));
    }
    if (appController.questManager.dailyQuestByCity[user.city] == null) {
      return const Center(child: Text("Keine täglichen Herausforderungen für deine Stadt verfügbar."));
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF91EAE4), Color(0xFF86A8E7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "LändleGuessr",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Tägliche und Wöchentliche challenge",
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ChallengeCard(
                    title: "${appController.questManager.dailyQuestByCity[appController.userManager.currentUser!.city]!.qid}",
                    imageUrl: "assets/images/festspiele.jpeg",
                    question: "Wo ist dieser Ort?",
                    description: "Finde diesen Ort um die Challenge zu meistern",
                    buttonText: "Starten",
                    color: Colors.lightBlueAccent,
                    qid: appController.questManager.dailyQuestByCity[appController.userManager.currentUser!.city]!.qid,
                  ),
                  const SizedBox(height: 24),
                  ChallengeCard(
                    title: "${appController.questManager.weeklyQuest.qid}",
                    imageUrl: "assets/images/festspiele.jpeg",
                    question: "Wo ist dieser Ort?",
                    description: "Finde diesen Ort um die Challenge zu meistern",
                    buttonText: "Starten",
                    color: Colors.redAccent,
                    qid: appController.questManager.weeklyQuest.qid,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChallengeCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String question;
  final String description;
  final String buttonText;
  final Color color;
  final int qid;
  static AppController appController = AppController.instance;

  const ChallengeCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.question,
    required this.description,
    required this.buttonText,
    required this.color,
    required this.qid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(imageUrl),
          ),
          const SizedBox(height: 12),
          Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(description),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
                
            },
            child: Text(
              buttonText,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
