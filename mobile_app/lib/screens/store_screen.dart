import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/wallet_service.dart';

/// Store Screen
/// Browse and view items (hardcoded for Phase 2)
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Outfits', 'Accessories', 'Backgrounds'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Wallet button (replaces coins display)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _WalletButton(),
                ],
              ),
            ),
            
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
                      selectedColor: AppTheme.primaryPink,
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
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: _getFilteredItems().length,
                itemBuilder: (context, index) {
                  final item = _getFilteredItems()[index];
                  return _StoreItemCard(item: item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  List<_StoreItem> _getFilteredItems() {
    if (_selectedCategory == 'All') {
      return _hardcodedItems;
    }
    return _hardcodedItems.where((item) => item.category == _selectedCategory).toList();
  }
}

class _StoreItemCard extends StatelessWidget {
  final _StoreItem item;
  
  const _StoreItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          _showItemDetails(context);
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: item.gradientColors,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Center(
                  child: Icon(
                    item.icon,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            // Item Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.monetization_on, size: 16, color: AppTheme.primaryPink),
                          const SizedBox(width: 4),
                          Text(
                            '${item.price}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.primaryPink,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (item.isOwned)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.pastelGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Owned',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showItemDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: item.gradientColors,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(item.name, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: item.isOwned ? null : () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Purchase feature coming in Phase 4!')),
                  );
                },
                child: Text(item.isOwned ? 'Already Owned' : 'Buy for ${item.price} coins'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Hardcoded store items for Phase 2
class _StoreItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final String category;
  final IconData icon;
  final List<Color> gradientColors;
  final bool isOwned;

  _StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.icon,
    required this.gradientColors,
    this.isOwned = false,
  });
}

final List<_StoreItem> _hardcodedItems = [
  // Outfits
  _StoreItem(
    id: '1',
    name: 'Casual Tee',
    description: 'Comfortable everyday outfit for your companion',
    price: 100,
    category: 'Outfits',
    icon: Icons.checkroom,
    gradientColors: [AppTheme.pastelBlue, AppTheme.pastelPurple],
    isOwned: true,
  ),
  _StoreItem(
    id: '2',
    name: 'Party Dress',
    description: 'Sparkly dress for special occasions',
    price: 250,
    category: 'Outfits',
    icon: Icons.celebration,
    gradientColors: [AppTheme.primaryPink, AppTheme.primaryPurple],
  ),
  _StoreItem(
    id: '3',
    name: 'Cozy Hoodie',
    description: 'Warm and comfy for cold days',
    price: 150,
    category: 'Outfits',
    icon: Icons.hot_tub,
    gradientColors: [AppTheme.pastelGreen, AppTheme.pastelBlue],
  ),
  _StoreItem(
    id: '4',
    name: 'Sport Outfit',
    description: 'Active wear for energetic companions',
    price: 180,
    category: 'Outfits',
    icon: Icons.sports_soccer,
    gradientColors: [AppTheme.moodExcited, AppTheme.moodHappy],
  ),
  
  // Accessories
  _StoreItem(
    id: '5',
    name: 'Cool Glasses',
    description: 'Stylish sunglasses for your companion',
    price: 80,
    category: 'Accessories',
    icon: Icons.visibility,
    gradientColors: [AppTheme.darkGray, AppTheme.black],
    isOwned: true,
  ),
  _StoreItem(
    id: '6',
    name: 'Cute Hat',
    description: 'Adorable hat to keep the sun away',
    price: 120,
    category: 'Accessories',
    icon: Icons.emoji_emotions,
    gradientColors: [AppTheme.pastelYellow, AppTheme.pastelPink],
  ),
  _StoreItem(
    id: '7',
    name: 'Bow Tie',
    description: 'Formal bow tie for special events',
    price: 90,
    category: 'Accessories',
    icon: Icons.dashboard_customize,
    gradientColors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
  ),
  _StoreItem(
    id: '8',
    name: 'Headphones',
    description: 'Music-loving companion accessory',
    price: 200,
    category: 'Accessories',
    icon: Icons.headphones,
    gradientColors: [AppTheme.primaryBlue, AppTheme.pastelBlue],
  ),
  
  // Backgrounds
  _StoreItem(
    id: '9',
    name: 'Beach Scene',
    description: 'Tropical beach background',
    price: 300,
    category: 'Backgrounds',
    icon: Icons.beach_access,
    gradientColors: [AppTheme.pastelBlue, AppTheme.pastelYellow],
  ),
  _StoreItem(
    id: '10',
    name: 'City Skyline',
    description: 'Urban cityscape background',
    price: 280,
    category: 'Backgrounds',
    icon: Icons.location_city,
    gradientColors: [AppTheme.primaryPurple, AppTheme.primaryPink],
    isOwned: true,
  ),
  _StoreItem(
    id: '11',
    name: 'Forest Path',
    description: 'Peaceful nature background',
    price: 250,
    category: 'Backgrounds',
    icon: Icons.park,
    gradientColors: [AppTheme.pastelGreen, AppTheme.moodCalm],
  ),
  _StoreItem(
    id: '12',
    name: 'Space Stars',
    description: 'Cosmic starry background',
    price: 350,
    category: 'Backgrounds',
    icon: Icons.star,
    gradientColors: [AppTheme.black, AppTheme.primaryPurple],
  ),
  
  // More outfits
  _StoreItem(
    id: '13',
    name: 'Pajamas',
    description: 'Comfy sleepwear for bedtime',
    price: 130,
    category: 'Outfits',
    icon: Icons.bedtime,
    gradientColors: [AppTheme.pastelPurple, AppTheme.pastelPink],
  ),
  _StoreItem(
    id: '14',
    name: 'Rain Coat',
    description: 'Stay dry in rainy weather',
    price: 160,
    category: 'Outfits',
    icon: Icons.umbrella,
    gradientColors: [AppTheme.pastelYellow, AppTheme.moodHappy],
  ),
  
  // More accessories
  _StoreItem(
    id: '15',
    name: 'Backpack',
    description: 'Adventure-ready backpack',
    price: 110,
    category: 'Accessories',
    icon: Icons.backpack,
    gradientColors: [AppTheme.moodCalm, AppTheme.pastelBlue],
  ),
  _StoreItem(
    id: '16',
    name: 'Crown',
    description: 'Royal crown for your companion',
    price: 500,
    category: 'Accessories',
    icon: Icons.stars,
    gradientColors: [AppTheme.moodHappy, AppTheme.primaryPink],
  ),
];

/// Wallet Button Widget
/// Shows wallet connection status and allows connect/disconnect
class _WalletButton extends StatelessWidget {
  const _WalletButton();

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletService>(
      builder: (context, walletService, child) {
        // Error state
        if (walletService.connectionState == WalletConnectionState.error) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 20, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Error',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        }
        
        // Connecting state
        if (walletService.isConnecting) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.pastelBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Connecting...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }
        
        // Connected state
        if (walletService.isConnected) {
          return GestureDetector(
            onTap: () => _showWalletMenu(context, walletService),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryPink, AppTheme.primaryPurple],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPink.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    walletService.getShortenedAddress(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 20, color: Colors.white),
                ],
              ),
            ),
          );
        }
        
        // Disconnected state - connect button
        return ElevatedButton.icon(
          onPressed: () => _handleConnect(context, walletService),
          icon: const Icon(Icons.account_balance_wallet, size: 20),
          label: const Text('Connect Wallet'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryPink,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
          ),
        );
      },
    );
  }
  
  void _handleConnect(BuildContext context, WalletService walletService) async {
    // Clear any previous errors
    walletService.clearError();
    
    // Attempt to connect
    await walletService.connectWallet();
    
    // Show info about Phantom app
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opening Phantom wallet... Approve the connection request.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  
  void _showWalletMenu(BuildContext context, WalletService walletService) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Wallet icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryPink, AppTheme.primaryPurple],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            // Wallet title
            Text(
              'Connected Wallet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            
            // Full wallet address
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                walletService.walletAddress ?? '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Disconnect button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  walletService.disconnectWallet();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Wallet disconnected'),
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Disconnect Wallet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

