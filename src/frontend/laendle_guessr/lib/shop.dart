import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:laendle_guessr/data_objects/item.dart';
import 'package:laendle_guessr/services/item_service.dart';
import 'package:laendle_guessr/ui/ItemCard.dart';
import 'package:laendle_guessr/manager/usermanager.dart';
import 'package:laendle_guessr/services/logger.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  
  late Future<List<Item>> futureItems;
  final UserManager _userManager = UserManager.instance; 

  @override
  void initState() {
    super.initState();
    AppLogger().log('ShopPage geladen');
    AppLogger().log('ShopPage: Initialisiere futureItems');
    futureItems = ItemService.instance.getAllItems();
    AppLogger().log('ShopPage: Registriere UserManager Listener');
    _userManager.addListener(_onUserDataChanged); 
  }

  @override
  void dispose() {
    AppLogger().log('ShopPage: dispose() aufgerufen');
    _userManager.removeListener(_onUserDataChanged); 
    AppLogger().log('ShopPage: UserManager Listener entfernt');
    super.dispose();
  }

  void _onUserDataChanged() {
    AppLogger().log('ShopPage: User data changed');
    if (mounted) { 
      AppLogger().log('ShopPage: setState() wird aufgerufen');
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLogger().log('ShopPage: build() aufgerufen');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text("Shop"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${UserManager.instance.currentUser!.coins}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Item>>(
        future: futureItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No items available in the shop.'));
          } else {
            final items = snapshot.data!;
            return AnimationLimiter(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8, 
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 400),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: ItemCard(
                          item: item,
                          onPurchaseSuccess: () {
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}