import 'package:flutter/material.dart';
import 'maps.dart';
import 'shop.dart';
import 'willkommen.dart';
import 'login.dart';
import 'signup.dart';
import 'profile.dart';
import 'package:laendle_guessr/controller/appcontroller.dart';
import 'package:laendle_guessr/data_objects/city.dart';
import 'package:laendle_guessr/data_objects/user.dart';
import 'package:laendle_guessr/services/quest_service.dart';
import 'package:laendle_guessr/services/logger.dart';
import 'package:laendle_guessr/services/api_service.dart';
import 'ui/ip_input_dialog.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLogger().init();
  AppLogger().log('App gestartet');
  runApp(LaendleGuessrAppWithApiCheck());
}

class LaendleGuessrAppWithApiCheck extends StatelessWidget {
  const LaendleGuessrAppWithApiCheck({super.key});

  Future<bool> _checkApi() async {
    try {
      final http.Response res = await ApiService.instance.get('healthcheck');
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkApi(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
            debugShowCheckedModeBanner: false,
          );
        }
        if (snapshot.data == true) {
          return const LaendleGuessrApp();
        } else {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: IpInputScreen(),
          );
        }
      },
    );
  }
}

class IpInputScreen extends StatefulWidget {
  @override
  State<IpInputScreen> createState() => _IpInputScreenState();
}

class _IpInputScreenState extends State<IpInputScreen> {
  String? _lastIp;
  Future<bool>? _apiCheckFuture;
  bool _dialogShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dialogShown) {
      _dialogShown = true;
      Future.microtask(_promptForIp);
    }
  }

  void _promptForIp() async {
    final ip = await showIpInputDialog(context);
    if (ip != null && ip.isNotEmpty) {
      ApiService('http://$ip:8080');
      setState(() {
        _lastIp = ip;
        _apiCheckFuture = ApiService.instance.get('healthcheck')
            .then((res) => res.statusCode == 200)
            .catchError((_) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_lastIp == null) {
      // Wait for user input
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return FutureBuilder<bool>(
      future: _apiCheckFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data == true) {
          Future.microtask(() {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LaendleGuessrApp()),
            );
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          // Prompt again for IP if still not working
          Future.microtask(_promptForIp);
          return const Scaffold(
            body: Center(child: Text('API nicht erreichbar. Bitte IP erneut eingeben.')),
          );
        }
      },
    );
  }
}

class LaendleGuessrApp extends StatelessWidget {
  const LaendleGuessrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
      },
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

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeContent(onNavigateToMaps: _navigateToMaps),
      const MapsPage(),
      ShopPage(),
      ProfilePage(),
    ];
  }

  void _navigateToMaps() {
    final mapsPageIndex = _pages.indexWhere((page) => page is MapsPage);
    if (mapsPageIndex != -1) {
      setState(() {
        _selectedIndex = mapsPageIndex;
      });
    }
  }

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
        unselectedItemColor: Colors.black45,
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

class HomeContent extends StatefulWidget {
  final VoidCallback onNavigateToMaps;

  const HomeContent({super.key, required this.onNavigateToMaps});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  Set<int> _doneQuestIds = {};
  bool _isLoading = true;
  int? _activeQid;

  @override
  void initState() {
    super.initState();
    final activeQuest = AppController.instance.userManager.currentUser?.activeQuest;
    if (activeQuest != null) {
      _activeQid = activeQuest.qid;
    }
    _loadDoneQuests();
  }

  Future<void> _loadDoneQuests() async {
    final user = AppController.instance.userManager.currentUser;
    if (user != null) {
      final doneQuests = await QuestService.instance.getAllDoneQuestsByUser(user);
      if (!mounted) return; // Add this check
      setState(() {
        _doneQuestIds = doneQuests.map((quest) => quest.qid).toSet();
        _isLoading = false;
      });
    } else {
      if (!mounted) return; // Add this check
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onStartQuest(int qid) async {
    await AppController.instance.questManager.startQuest(qid);
    setState(() {
      _activeQid = qid;
    });
    widget.onNavigateToMaps();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final appController = AppController.instance;
    final user = appController.userManager.currentUser;

    if (user == null) {
      return const Center(child: Text("Bitte anmelden oder registrieren."));
    }

    final dailyQuest = appController.questManager.dailyQuestByCity[user.city];
    final weeklyQuest = appController.questManager.weeklyQuest;

    if (dailyQuest == null && weeklyQuest == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDailyDone = dailyQuest != null && _doneQuestIds.contains(dailyQuest.qid);
    final isWeeklyDone = _doneQuestIds.contains(weeklyQuest.qid);

    final showDaily = dailyQuest != null && !isDailyDone;
    final showWeekly = !isWeeklyDone;

    if (!showDaily && !showWeekly) {
      return const Center(child: Text("Alle aktuellen Quests abgeschlossen!"));
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
                    "Tägliche und Wöchentliche Challenge",
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (showDaily)
                    ChallengeCard(
                      title: "Tägliche Challenge: ${dailyQuest.qid}",
                      imageUrl: dailyQuest.image,
                      question: "Wo ist dieser Ort?",
                      description: "Finde diesen Ort, um die Challenge zu meistern.",
                      buttonText: "Starten",
                      color: Colors.lightBlueAccent,
                      qid: dailyQuest.qid,
                      isThisQuestActive: _activeQid == dailyQuest.qid,
                      isAnyQuestActive: _activeQid != null,
                      onPressed: () => _onStartQuest(dailyQuest.qid),
                    ),
                  if (showDaily) const SizedBox(height: 24),
                  if (showWeekly)
                    ChallengeCard(
                      title: "Wöchentliche Challenge: ${weeklyQuest.qid}",
                      imageUrl: weeklyQuest.image,
                      question: "Wo ist dieser Ort?",
                      description: "Finde diesen Ort, um die Challenge zu meistern.",
                      buttonText: "Starten",
                      color: Colors.redAccent,
                      qid: weeklyQuest.qid,
                      isThisQuestActive: _activeQid == weeklyQuest.qid,
                      isAnyQuestActive: _activeQid != null,
                      onPressed: () => _onStartQuest(weeklyQuest.qid),
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
  final bool isThisQuestActive;
  final bool isAnyQuestActive;
  final VoidCallback onPressed;

  const ChallengeCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.question,
    required this.description,
    required this.buttonText,
    required this.color,
    required this.qid,
    required this.isThisQuestActive,
    required this.isAnyQuestActive,
    required this.onPressed,
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
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(imageUrl, fit: BoxFit.cover, height: 150, width: double.infinity),
          ),
          const SizedBox(height: 12),
          Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(description, textAlign: TextAlign.center),
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
            onPressed: isAnyQuestActive ? null : onPressed,
            child: Text(
              isThisQuestActive ? "Gestartet!" : buttonText,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
