import 'package:flutter/material.dart';
import 'package:laendle_guessr/controller/appcontroller.dart';
import 'package:laendle_guessr/manager/questmanager.dart';
import 'package:laendle_guessr/services/step_counter.dart';
import 'package:laendle_guessr/manager/usermanager.dart';
import 'package:laendle_guessr/ui/ItemCard.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:laendle_guessr/services/user_service.dart';
import 'package:laendle_guessr/services/logger.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late final user = AppController.instance.userManager.currentUser!;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  Map<String, dynamic>? stats;

  @override
  void initState() {
    super.initState();
    AppLogger().log('ProfilePage geladen');
    AppLogger().log('ProfilePage: Initialisiere Animationen');
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    AppLogger().log('ProfilePage: Starte Animationen');
    _animationController.forward();
    AppLogger().log('ProfilePage: Lade Benutzer-Statistiken');
    _loadStats();
  }

  Future<void> _loadStats() async {
    AppLogger().log('ProfilePage: Statistiken werden geladen');
    final loadedStats = await UserService.instance.getAllTimeStats();
    AppLogger().log('ProfilePage: Statistiken erhalten, aktualisiere UI');
    setState(() {
      stats = loadedStats;
    });
    AppLogger().log('ProfilePage: Statistiken erfolgreich geladen');
  }

  @override
  void dispose() {
    AppLogger().log('ProfilePage: dispose() aufgerufen');
    _animationController.dispose();
    AppLogger().log('ProfilePage: AnimationController disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLogger().log('ProfilePage: build() aufgerufen');
    if (stats == null) {
      AppLogger().log('ProfilePage: Statistiken noch nicht geladen, zeige Ladeindikator');
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    AppLogger().log('ProfilePage: Rendere vollständige Profil-UI');
    final items = user.inventory.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text("Profil"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  user.username,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildStatCard("👣 Schritte", "${stats!["steps"]}"),
                const SizedBox(height: 16),
                _buildStatCard("⏱ Spielzeit", "${formatElapsedSeconds(stats!["timeInSeconds"])}"),
                const SizedBox(height: 16),
                _buildStatCard("💰 Münzen", "${UserManager.instance.currentUser!.coins}"),
                const SizedBox(height: 32),
                if (items.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "🎒 Deine Figuren",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimationLimiter(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 400),
                          columnCount: 2,
                          child: ScaleAnimation(
                            child: FadeInAnimation(
                              child: ItemCard(item: item),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ] else
                  const Text("Du besitzt noch keine Items."),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    AppController.instance.userManager.logoutUser();
                    Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text("Abmelden", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

String formatElapsedSeconds(int elapsedSeconds) {
  final hours = (elapsedSeconds ~/ 3600).toString().padLeft(2, '0');
  final minutes = ((elapsedSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
  final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}
