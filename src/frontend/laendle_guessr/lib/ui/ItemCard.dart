import 'package:flutter/material.dart';
import 'package:laendle_guessr/data_objects/item.dart';
import 'package:laendle_guessr/manager/usermanager.dart';
import 'package:laendle_guessr/data_objects/user.dart';
import 'package:laendle_guessr/services/logger.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback? onPurchaseSuccess;

  const ItemCard({
    super.key,
    required this.item,
    this.onPurchaseSuccess,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger().log('ItemCard: build() für Item ${item.name} (ID: ${item.id})');
    final UserManager userManager = UserManager.instance;
    final User? currentUser = userManager.currentUser;
    bool itemOwned = false;

    if (currentUser != null && currentUser.inventory != null) {
      itemOwned = currentUser.inventory!.items.any((inventoryItem) => inventoryItem.id == item.id);
      AppLogger().log('ItemCard: Item ${item.name} besessen: $itemOwned');
    }

    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        // onTap: itemOwned ? null : () {}, // Outer InkWell can be for item details if needed
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 120,
                child: Image.asset(
                  item.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image, color: Colors.grey[400], size: 48),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: itemOwned
                    ? null // If item is owned, button is not tappable
                    : () async {
                        bool buyState = await userManager.buyItem(item); // Assuming buyItem is async
                        if (buyState) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('You bought ${item.name} for ${item.price} coins!'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          onPurchaseSuccess?.call(); // Notify parent about successful purchase
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Not enough coins or item already owned!'), // Updated message
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: itemOwned ? Colors.grey.shade400 : Colors.green.shade600,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(itemOwned ? Icons.check_circle_outline : Icons.monetization_on, color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        itemOwned ? 'Owned' : '${item.price}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}