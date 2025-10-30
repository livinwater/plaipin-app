import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'nft_service.dart';

/// Inventory Service
/// Manages owned items and equipped state
class InventoryService extends ChangeNotifier {
  List<ItemNFT> _ownedItems = [];
  Map<String, String> _equippedItems = {}; // category -> itemId
  bool _isLoading = false;

  static const String _keyOwnedItems = 'owned_items';
  static const String _keyEquippedItems = 'equipped_items';

  // Getters
  List<ItemNFT> get ownedItems => _ownedItems;
  Map<String, String> get equippedItems => _equippedItems;
  bool get isLoading => _isLoading;

  InventoryService() {
    _loadInventory();
  }

  /// Load inventory from local storage
  Future<void> _loadInventory() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();

      // Load owned items
      final ownedItemsJson = prefs.getString(_keyOwnedItems);
      if (ownedItemsJson != null) {
        final List<dynamic> itemsList = jsonDecode(ownedItemsJson);
        _ownedItems = itemsList.map((json) => ItemNFT.fromJson(json)).toList();
      }

      // Load equipped items
      final equippedItemsJson = prefs.getString(_keyEquippedItems);
      if (equippedItemsJson != null) {
        final Map<String, dynamic> equippedMap = jsonDecode(equippedItemsJson);
        _equippedItems = equippedMap.map((key, value) => MapEntry(key, value.toString()));
      }

      debugPrint('📦 Loaded inventory: ${_ownedItems.length} items');
      debugPrint('✨ Equipped items: ${_equippedItems.length}');
    } catch (e) {
      debugPrint('Error loading inventory: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save inventory to local storage
  Future<void> _saveInventory() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save owned items
      final ownedItemsJson = jsonEncode(_ownedItems.map((item) => item.toJson()).toList());
      await prefs.setString(_keyOwnedItems, ownedItemsJson);

      // Save equipped items
      final equippedItemsJson = jsonEncode(_equippedItems);
      await prefs.setString(_keyEquippedItems, equippedItemsJson);

      debugPrint('💾 Saved inventory');
    } catch (e) {
      debugPrint('Error saving inventory: $e');
    }
  }

  /// Add an item to inventory
  Future<void> addItem(ItemNFT item) async {
    // Check if item already exists
    final existingIndex = _ownedItems.indexWhere((i) => i.id == item.id);
    
    if (existingIndex == -1) {
      _ownedItems.add(item);
      await _saveInventory();
      notifyListeners();
      debugPrint('✅ Added item to inventory: ${item.name}');
    } else {
      debugPrint('⚠️ Item already in inventory: ${item.name}');
    }
  }

  /// Remove an item from inventory
  Future<void> removeItem(String itemId) async {
    _ownedItems.removeWhere((item) => item.id == itemId);
    
    // Also unequip if equipped
    _equippedItems.removeWhere((category, id) => id == itemId);
    
    await _saveInventory();
    notifyListeners();
    debugPrint('🗑️ Removed item from inventory: $itemId');
  }

  /// Equip an item
  Future<void> equipItem(String itemId, String category) async {
    final item = _ownedItems.firstWhere(
      (item) => item.id == itemId,
      orElse: () => throw Exception('Item not found in inventory'),
    );

    _equippedItems[category] = itemId;
    await _saveInventory();
    notifyListeners();
    debugPrint('✨ Equipped: ${item.name}');
  }

  /// Unequip an item
  Future<void> unequipItem(String category) async {
    _equippedItems.remove(category);
    await _saveInventory();
    notifyListeners();
    debugPrint('👕 Unequipped item in category: $category');
  }

  /// Check if an item is owned
  bool isItemOwned(String itemId) {
    return _ownedItems.any((item) => item.id == itemId);
  }

  /// Check if an item is equipped
  bool isItemEquipped(String itemId) {
    return _equippedItems.values.contains(itemId);
  }

  /// Get equipped item for a category
  ItemNFT? getEquippedItem(String category) {
    final itemId = _equippedItems[category];
    if (itemId == null) return null;

    try {
      return _ownedItems.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  /// Get items filtered by category
  List<ItemNFT> getItemsByCategory(String category) {
    if (category == 'All') return _ownedItems;
    return _ownedItems.where((item) => item.category == category).toList();
  }

  /// Clear all inventory (for testing/debugging)
  Future<void> clearInventory() async {
    _ownedItems.clear();
    _equippedItems.clear();
    await _saveInventory();
    notifyListeners();
    debugPrint('🗑️ Cleared all inventory');
  }

  /// Refresh inventory from blockchain (placeholder for Phase 3+)
  Future<void> refreshFromBlockchain(String walletAddress) async {
    // TODO: In Phase 3+, fetch actual NFTs from the wallet's on-chain data
    debugPrint('📡 Refreshing inventory from blockchain...');
    debugPrint('(Not implemented in Phase 2)');
  }
}

