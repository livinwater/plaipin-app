import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/store_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/device_screen.dart';
import 'services/wallet_service.dart';
import 'services/privy_wallet_service.dart';
// Note: mood_screen.dart is available but currently not in main navigation
// Can be added as a 6th tab or integrated into journal screen in Phase 4

Future<void> main() async {
  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');
  
  runApp(const CompanionApp());
}

class CompanionApp extends StatelessWidget {
  const CompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletService()),
        ChangeNotifierProvider(create: (_) => PrivyWalletService()),
      ],
      child: MaterialApp(
        title: 'Mobile Companion',
        theme: AppTheme.lightTheme,
        home: const MainNavigation(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  static const List<Widget> _screens = [
    HomeScreen(),
    StoreScreen(),
    InventoryScreen(),
    JournalScreen(),
    DeviceScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  /// Initialize deep-link listening for wallet connection
  void _initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle initial link if app was opened via deep link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Error getting initial deep link: $e');
    }

    // Listen for deep links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      debugPrint('Error listening to deep links: $err');
    });
  }

  /// Handle incoming deep link from Phantom wallet
  void _handleDeepLink(Uri uri) {
    debugPrint('Received deep link: $uri');

    // Check if this is a wallet connection redirect
    if (uri.scheme == 'companion' && uri.host == 'connected') {
      final walletService = Provider.of<WalletService>(context, listen: false);
      walletService.handleDeepLink(uri);

      // Navigate to Store screen to show connected wallet
      setState(() {
        _selectedIndex = 1; // Store tab
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wallet connected successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store),
            label: 'Store',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.devices_outlined),
            selectedIcon: Icon(Icons.devices),
            label: 'Device',
          ),
        ],
      ),
    );
  }
}
