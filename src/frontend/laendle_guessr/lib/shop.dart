import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:laendle_guessr/data_objects/item.dart';
import 'package:laendle_guessr/services/item_service.dart';
import 'package:laendle_guessr/ui/ItemCard.dart';
import 'package:laendle_guessr/manager/usermanager.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  // coinBalance will now be read directly from UserManager in the build method
  late Future<List<Item>> futureItems;
  final UserManager _userManager = UserManager.instance; // Store instance

  @override
  void initState() {
    super.initState();
    futureItems = ItemService.instance.getAllItems();
    _userManager.addListener(_onUserDataChanged); // Listen to UserManager
  }

  @override
  void dispose() {
    _userManager.removeListener(_onUserDataChanged); // Clean up listener
    super.dispose();
  }

  void _onUserDataChanged() {
    if (mounted) { // Check if the widget is still in the tree
      setState(() {
        // This will trigger a rebuild, updating the coin balance
        // and causing ItemCards to re-evaluate their 'owned' status.
      });
    }
  }

  @override
  Widget build(BuildContext context) {

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
                  childAspectRatio: 0.8, // Adjust as needed for your ItemCard layout
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