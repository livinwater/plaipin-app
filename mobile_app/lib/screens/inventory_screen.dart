import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/inventory_service.dart';
import '../services/nft_service.dart';

/// Inventory Screen
/// View and equip owned items
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Mini-apps', 'Accessories', 'Backgrounds'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<InventoryService>(
          builder: (context, inventoryService, _) {
            final ownedItems = inventoryService.ownedItems;
            final equippedItems = inventoryService.equippedItems;

            return Column(
              children: [
                // Item count and Clear button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Clear button (left side)
                      if (ownedItems.isNotEmpty)
                        TextButton.icon(
                          onPressed: () => _showClearInventoryDialog(context, inventoryService),
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('Clear All'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      
                      // Item count (right side)
                      Text(
                        '${ownedItems.length} items',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
            
            // Currently Equipped Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Currently Equipped',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: Row(
                      children: [
                        _buildEquippedSlot(inventoryService, 'Mini-apps', Icons.apps),
                        const SizedBox(width: 12),
                        _buildEquippedSlot(inventoryService, 'Accessories', Icons.visibility),
                        const SizedBox(width: 12),
                        _buildEquippedSlot(inventoryService, 'Backgrounds', Icons.landscape),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Category Filter
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: AppTheme.lightGray,
                      selectedColor: AppTheme.primaryPurple,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.darkGray,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Items Grid
                Expanded(
                  child: _getFilteredItems(ownedItems).isEmpty
                      ? _buildEmptyState()
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _getFilteredItems(ownedItems).length,
                          itemBuilder: (context, index) {
                            final item = _getFilteredItems(ownedItems)[index];
                            final isEquipped = equippedItems[item.category] == item.id;
                            return _InventoryItemCard(
                              item: item,
                              isEquipped: isEquipped,
                              onTap: () => _onItemTap(inventoryService, item, isEquipped),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildEquippedSlot(InventoryService inventoryService, String category, IconData defaultIcon) {
    final equippedItem = inventoryService.getEquippedItem(category);
    
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: equippedItem != null
              ? LinearGradient(colors: [AppTheme.primaryPink, AppTheme.primaryPurple])
              : LinearGradient(colors: [AppTheme.lightGray, AppTheme.mediumGray]),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: equippedItem != null ? AppTheme.primaryPink : AppTheme.mediumGray,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              defaultIcon,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              equippedItem?.name ?? category,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: AppTheme.mediumGray,
          ),
          const SizedBox(height: 16),
          Text(
            'No items in this category',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Visit the Store to get items!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  List<ItemNFT> _getFilteredItems(List<ItemNFT> ownedItems) {
    if (_selectedCategory == 'All') {
      return ownedItems;
    }
    return ownedItems.where((item) => item.category == _selectedCategory).toList();
  }
  
  void _onItemTap(InventoryService inventoryService, ItemNFT item, bool isEquipped) {
    if (isEquipped) {
      // Unequip
      inventoryService.unequipItem(item.category);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unequipped ${item.name}'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      // Equip
      inventoryService.equipItem(item.id, item.category);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Equipped ${item.name}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
  
  /// Show confirmation dialog before clearing inventory
  Future<void> _showClearInventoryDialog(BuildContext context, InventoryService inventoryService) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Inventory?'),
        content: const Text(
          'This will remove all items from your inventory and unequip everything.\n\n'
          'This cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    
    if (confirm == true && context.mounted) {
      await inventoryService.clearInventory();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Inventory cleared successfully'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

class _InventoryItemCard extends StatelessWidget {
  final ItemNFT item;
  final bool isEquipped;
  final VoidCallback onTap;
  
  const _InventoryItemCard({
    required this.item,
    required this.isEquipped,
    required this.onTap,
  });

  IconData _getCategoryIcon() {
    switch (item.category) {
      case 'Mini-apps':
        return Icons.apps;
      case 'Accessories':
        return Icons.checkroom;
      case 'Backgrounds':
        return Icons.landscape;
      default:
        return Icons.star;
    }
  }

  List<Color> _getCategoryGradient() {
    switch (item.category) {
      case 'Mini-apps':
        return [AppTheme.primaryPurple, AppTheme.primaryBlue];
      case 'Accessories':
        return [AppTheme.pastelBlue, AppTheme.pastelPurple];
      case 'Backgrounds':
        return [AppTheme.primaryPink, AppTheme.pastelPink];
      default:
        return [AppTheme.pastelGreen, AppTheme.pastelBlue];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isEquipped ? 6 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isEquipped
            ? const BorderSide(color: AppTheme.primaryPink, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _getCategoryGradient(),
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(),
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            
            // Equipped badge
            if (isEquipped)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryPink,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

