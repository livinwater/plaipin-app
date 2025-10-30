import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/wallet_service.dart';
import '../services/privy_wallet_service.dart';
import '../services/nft_service.dart';
import '../services/inventory_service.dart';
import 'privy_login_screen.dart';

/// Store Screen
/// Browse and view items (hardcoded for Phase 2)
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Accessories', 'Mini-apps','Backgrounds'];

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
                          Text(
                            '◎',  // SOL symbol
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.primaryPink,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.price.toStringAsFixed(2)}',  // Show 2 decimal places
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (modalContext) => Consumer2<InventoryService, WalletService>(
        builder: (context, inventoryService, walletService, _) {
          final isOwned = inventoryService.isItemOwned(item.id);
          final isConnected = walletService.isConnected;

          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
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
                
                // Show different button based on state
                SizedBox(
                  width: double.infinity,
                  child: isOwned
                      ? ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.pastelGreen,
                          ),
                          child: const Text('Already Owned'),
                        )
                      : !isConnected
                          ? ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(modalContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please connect your wallet first!'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.account_balance_wallet),
                              label: const Text('Connect Wallet to Buy'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () => _handlePurchase(modalContext, item),
                              child: Text('Buy for ◎${item.price.toStringAsFixed(2)} SOL'),
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  /// Handle item purchase
  Future<void> _handlePurchase(BuildContext modalContext, _StoreItem item) async {
    final nftService = Provider.of<NFTService>(modalContext, listen: false);
    final inventoryService = Provider.of<InventoryService>(modalContext, listen: false);
    final walletService = Provider.of<WalletService>(modalContext, listen: false);
    final privyService = Provider.of<PrivyWalletService>(modalContext, listen: false);

    // Get the connected wallet address
    final walletAddress = walletService.isConnected 
        ? walletService.walletAddress 
        : privyService.solanaAddress;

    if (walletAddress == null) {
      ScaffoldMessenger.of(modalContext).showSnackBar(
        const SnackBar(
          content: Text('Wallet not connected!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: modalContext,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Processing purchase...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Check balance first
      final balance = await nftService.getBalance(walletAddress);
      debugPrint('💰 Wallet balance: $balance SOL');
      
      if (balance < item.price) {
        Navigator.pop(modalContext); // Close loading dialog
        Navigator.pop(modalContext); // Close item details modal
        
        ScaffoldMessenger.of(modalContext).showSnackBar(
          SnackBar(
            content: Text('Insufficient balance! Need ◎${item.price.toStringAsFixed(2)} SOL but have ◎${balance.toStringAsFixed(4)} SOL'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      // Phase 3: Create actual blockchain transaction
      debugPrint('🔨 Creating blockchain transaction...');
      final transactionBase58 = await nftService.createPurchaseTransaction(
        buyerAddress: walletAddress,
        priceInSol: item.price,
        itemId: item.id,
        itemName: item.name,
      );

      String? txSignature;
      String? signedTransaction;
      
      // Debug wallet connection status
      debugPrint('🔍 Wallet Status Check:');
      debugPrint('  - Phantom connected: ${walletService.isConnected}');
      debugPrint('  - Privy authenticated: ${privyService.isAuthenticated}');
      debugPrint('  - Wallet address: $walletAddress');
      
      // Sign the transaction based on wallet type
      if (walletService.isConnected) {
        // Phantom wallet - sign via deep-link
        debugPrint('📝 Signing transaction with Phantom...');
        
        try {
          signedTransaction = await walletService.signTransaction(transactionBase58);
          debugPrint('✅ Transaction signed by Phantom');
        } catch (e) {
          Navigator.pop(modalContext); // Close loading dialog
          Navigator.pop(modalContext); // Close item details modal
          
          ScaffoldMessenger.of(modalContext).showSnackBar(
            SnackBar(
              content: Text('Transaction signing failed: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
          return;
        }
      } else if (privyService.isAuthenticated) {
        // Privy wallet - sign via embedded wallet
        debugPrint('📝 Signing transaction with Privy...');
        
        try {
          signedTransaction = await privyService.signTransaction(transactionBase58);
          debugPrint('✅ Transaction signed by Privy');
        } catch (e) {
          Navigator.pop(modalContext); // Close loading dialog
          Navigator.pop(modalContext); // Close item details modal
          
          ScaffoldMessenger.of(modalContext).showSnackBar(
            SnackBar(
              content: Text('Privy signing failed: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
          return;
        }
      } else {
        // No wallet connected - this shouldn't happen
        Navigator.pop(modalContext); // Close loading dialog
        Navigator.pop(modalContext); // Close item details modal
        
        ScaffoldMessenger.of(modalContext).showSnackBar(
          const SnackBar(
            content: Text('❌ No wallet connected! Please connect a wallet first.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }
      
      // Submit signed transaction to blockchain
      debugPrint('📡 Submitting signed transaction to blockchain...');
      debugPrint('  - Transaction length: ${signedTransaction!.length} chars');
      
      try {
        txSignature = await nftService.submitTransaction(signedTransaction!);
        debugPrint('✅ Transaction confirmed: $txSignature');
      } catch (e) {
        Navigator.pop(modalContext); // Close loading dialog
        Navigator.pop(modalContext); // Close item details modal
        
        ScaffoldMessenger.of(modalContext).showSnackBar(
          SnackBar(
            content: Text('Transaction failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      // Mint the NFT (record the purchase)
      final nft = await nftService.mintItemNFT(
        itemId: item.id,
        itemName: item.name,
        category: item.category,
        description: item.description,
        ownerAddress: walletAddress,
        transactionSignature: txSignature,
      );

      // Add to inventory
      await inventoryService.addItem(nft);

      Navigator.pop(modalContext); // Close loading dialog
      Navigator.pop(modalContext); // Close item details modal

      // Show success message
      ScaffoldMessenger.of(modalContext).showSnackBar(
        SnackBar(
          content: Text('✅ Successfully purchased ${item.name}!\nTx: ${txSignature?.substring(0, 8)}...'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      Navigator.pop(modalContext); // Close loading dialog
      Navigator.pop(modalContext); // Close item details modal
      
      ScaffoldMessenger.of(modalContext).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

// Hardcoded store items for Phase 2
class _StoreItem {
  final String id;
  final String name;
  final String description;
  final double price;  // Changed to double for SOL prices
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
  // Accessories - Part 1
  _StoreItem(
    id: '1',
    name: 'Yellow Ribbon',
    description: 'Cutest ribbon for Plaipin',
    price: 0.01,
    category: 'Accessories',
    icon: Icons.checkroom,
    gradientColors: [AppTheme.pastelBlue, AppTheme.pastelPurple],
  ),
  _StoreItem(
    id: '2',
    name: 'Mint Scarf',
    description: 'Comfy warm scarf for cold days',
    price: 0.025,
    category: 'Accessories',
    icon: Icons.celebration,
    gradientColors: [AppTheme.primaryPink, AppTheme.primaryPurple],
  ),
  _StoreItem(
    id: '3',
    name: 'Flower Crown',
    description: 'A ring of flowers for the cutest PlaiPin',
    price: 0.015,
    category: 'Accessories',
    icon: Icons.hot_tub,
    gradientColors: [AppTheme.pastelGreen, AppTheme.pastelBlue],
  ),
  _StoreItem(
    id: '4',
    name: 'Bead Bracelet',
    description: 'Wearing it on the ears because why not?',
    price: 0.018,
    category: 'Accessories',
    icon: Icons.sports_soccer,
    gradientColors: [AppTheme.moodExcited, AppTheme.moodHappy],
  ),
  
  // Accessories - Part 2
  _StoreItem(
    id: '5',
    name: 'Little Spinner Hat',
    description: 'Because spinning is fun!',
    price: 0.012,
    category: 'Accessories',
    icon: Icons.visibility,
    gradientColors: [AppTheme.darkGray, AppTheme.black],
  ),
  _StoreItem(
    id: '6',
    name: 'Small Rounded Glasses',
    description: 'Too much screen time is bad for your eyes',
    price: 0.01,
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
    name: 'Mood Tracker',
    description: 'Mood tracker mini-app',
    price: 0.1,
    category: 'Mini-apps',
    icon: Icons.star,
    gradientColors: [AppTheme.black, AppTheme.primaryPurple],
  ),
  
  // More outfits
  _StoreItem(
    id: '13',
    name: 'Daily Fortune',
    description: 'Tells you your daily fortune',
    price: 0.1,
    category: 'Mini-apps',
    icon: Icons.stars,
    gradientColors: [AppTheme.pastelPurple, AppTheme.pastelPink],
  ),
  
  // More accessories
  _StoreItem(
    id: '14',
    name: 'Proximity Tag',
    description: 'Pass between your PlaiPin and other PlaiPins to see who is nearby',
    price: 0.05,
    category: 'Mini-apps',
    icon: Icons.backpack,
    gradientColors: [AppTheme.moodCalm, AppTheme.pastelBlue],
  ),
  _StoreItem(
    id: '15',
    name: 'Daily Glazing',
    description: 'Tells you 3 amazing things about yourself every day',
    price: 0.1,
    category: 'Mini-apps',
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
    return Consumer2<WalletService, PrivyWalletService>(
      builder: (context, walletService, privyService, child) {
        // Check if any wallet is connected
        final isPhantomConnected = walletService.isConnected;
        final isPrivyConnected = privyService.isAuthenticated && privyService.solanaAddress != null;
        final isAnyConnected = isPhantomConnected || isPrivyConnected;
        
        // Error state (Phantom only, Privy handles errors internally)
        if (walletService.connectionState == WalletConnectionState.error && !isAnyConnected) {
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
        if (walletService.isConnecting || privyService.isLoading) {
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
        
        // Connected state - show connected wallet
        if (isAnyConnected) {
          final address = isPhantomConnected 
              ? walletService.getShortenedAddress()
              : privyService.getShortenedAddress();
          final walletType = isPhantomConnected ? 'Phantom' : 'Privy';
          
          return GestureDetector(
            onTap: () => _showConnectedWalletMenu(
              context, 
              walletService, 
              privyService,
              isPhantomConnected,
            ),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        address,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        walletType,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 20, color: Colors.white),
                ],
              ),
            ),
          );
        }
        
        // Disconnected state - connect button (shows wallet options)
        return ElevatedButton.icon(
          onPressed: () => _showWalletOptions(context),
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
  
  /// Show wallet selection dialog (Phantom or Privy)
  void _showWalletOptions(BuildContext context) {
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
            Text(
              'Connect Wallet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how you want to connect',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            
            // Phantom Option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryPurple, AppTheme.primaryPurple.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white),
              ),
              title: const Text(
                'Phantom Wallet',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Use your existing Phantom wallet'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _connectPhantom(context);
              },
            ),
            
            const Divider(height: 32),
            
            // Privy Option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryPink, AppTheme.primaryPink.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_circle, color: Colors.white),
              ),
              title: const Text(
                'Create with Privy',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Create a new embedded wallet'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _connectPrivy(context);
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  /// Connect with Phantom wallet (deep-link)
  void _connectPhantom(BuildContext context) async {
    final walletService = Provider.of<WalletService>(context, listen: false);
    
    // Clear any previous errors
    walletService.clearError();
    
    // Connect to Phantom wallet via deep-link
    await walletService.connectWallet();
    
    // Show instructions to user
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '✨ Opening Phantom wallet...\n'
            'Please approve the connection request.',
          ),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.deepPurple,
        ),
      );
    }
  }
  
  /// Connect with Privy (embedded wallet)
  void _connectPrivy(BuildContext context) async {
    // Navigate to Privy login flow
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivyLoginScreen()),
    );
    
    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Wallet connected: $result'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  /// Show connected wallet menu (for disconnect)
  void _showConnectedWalletMenu(
    BuildContext context,
    WalletService phantomService,
    PrivyWalletService privyService,
    bool isPhantom,
  ) {
    final walletAddress = isPhantom ? phantomService.walletAddress : privyService.solanaAddress;
    final walletType = isPhantom ? 'Phantom' : 'Privy Embedded';
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Wallet type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPhantom 
                      ? [AppTheme.primaryPurple, AppTheme.primaryPurple.withOpacity(0.7)]
                      : [AppTheme.primaryPink, AppTheme.primaryPink.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                walletType,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Wallet address
            Text(
              'Connected Wallet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                walletAddress ?? 'Unknown',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Disconnect button
            ElevatedButton.icon(
              onPressed: () {
                if (isPhantom) {
                  phantomService.disconnectWallet();
                } else {
                  privyService.logout();
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wallet disconnected'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Disconnect'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

