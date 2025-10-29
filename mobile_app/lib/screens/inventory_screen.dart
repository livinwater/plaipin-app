import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Inventory Screen
/// View and equip owned items (hardcoded for Phase 2)
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Outfits', 'Accessories', 'Backgrounds'];
  
  // Mock equipped items state (Phase 2 - local only)
  final Map<String, String> _equippedItems = {
    'Outfits': '1',
    'Accessories': '5',
    'Backgrounds': '10',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Item count
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${_ownedItems.length} items',
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
                        _buildEquippedSlot('Outfits', Icons.checkroom),
                        const SizedBox(width: 12),
                        _buildEquippedSlot('Accessories', Icons.visibility),
                        const SizedBox(width: 12),
                        _buildEquippedSlot('Backgrounds', Icons.landscape),
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
              child: _getFilteredItems().isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _getFilteredItems().length,
                      itemBuilder: (context, index) {
                        final item = _getFilteredItems()[index];
                        final isEquipped = _equippedItems[item.category] == item.id;
                        return _InventoryItemCard(
                          item: item,
                          isEquipped: isEquipped,
                          onTap: () => _onItemTap(item, isEquipped),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEquippedSlot(String category, IconData defaultIcon) {
    final equippedItemId = _equippedItems[category];
    final equippedItem = equippedItemId != null
        ? _ownedItems.firstWhere((item) => item.id == equippedItemId)
        : null;
    
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: equippedItem != null
              ? LinearGradient(colors: equippedItem.gradientColors)
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
              equippedItem?.icon ?? defaultIcon,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              category,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
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
  
  List<_InventoryItem> _getFilteredItems() {
    if (_selectedCategory == 'All') {
      return _ownedItems;
    }
    return _ownedItems.where((item) => item.category == _selectedCategory).toList();
  }
  
  void _onItemTap(_InventoryItem item, bool isEquipped) {
    setState(() {
      if (isEquipped) {
        // Unequip
        _equippedItems.remove(item.category);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unequipped ${item.name}'),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        // Equip
        _equippedItems[item.category] = item.id;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Equipped ${item.name}'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }
}

class _InventoryItemCard extends StatelessWidget {
  final _InventoryItem item;
  final bool isEquipped;
  final VoidCallback onTap;
  
  const _InventoryItemCard({
    required this.item,
    required this.isEquipped,
    required this.onTap,
  });

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
                        colors: item.gradientColors,
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    child: Center(
                      child: Icon(
                        item.icon,
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

// Hardcoded owned items for Phase 2 (subset of store items that are marked as owned)
class _InventoryItem {
  final String id;
  final String name;
  final String category;
  final IconData icon;
  final List<Color> gradientColors;

  _InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.gradientColors,
  });
}

final List<_InventoryItem> _ownedItems = [
  _InventoryItem(
    id: '1',
    name: 'Casual Tee',
    category: 'Outfits',
    icon: Icons.checkroom,
    gradientColors: [AppTheme.pastelBlue, AppTheme.pastelPurple],
  ),
  _InventoryItem(
    id: '5',
    name: 'Cool Glasses',
    category: 'Accessories',
    icon: Icons.visibility,
    gradientColors: [AppTheme.darkGray, AppTheme.black],
  ),
  _InventoryItem(
    id: '10',
    name: 'City Skyline',
    category: 'Backgrounds',
    icon: Icons.location_city,
    gradientColors: [AppTheme.primaryPurple, AppTheme.primaryPink],
  ),
  // Player starts with these 3 default items
];

