import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:privy_flutter/privy_flutter.dart';

/// Privy Wallet Service
/// 
/// Handles embedded wallet creation and management via Privy
/// Based on official Privy Flutter Starter: 
/// https://github.com/privy-io/examples/tree/main/privy-flutter-starter
class PrivyWalletService extends ChangeNotifier {
  Privy? _privy;
  PrivyUser? _currentUser;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<AuthState>? _authSubscription;
  
  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  PrivyUser? get user => _currentUser;
  String? get errorMessage => _errorMessage;
  
  /// Get Solana wallet address if available
  String? get solanaAddress {
    if (_currentUser == null || _currentUser!.embeddedSolanaWallets.isEmpty) {
      return null;
    }
    return _currentUser!.embeddedSolanaWallets.first.address;
  }
  
  // Load credentials from .env file
  // Get your credentials from https://dashboard.privy.io
  static String get _appId => dotenv.env['PRIVY_APP_ID'] ?? '';
  static String get _clientId => dotenv.env['PRIVY_APP_SECRET'] ?? '';
  
  PrivyWalletService() {
    // Note: Privy will be initialized later when needed
    // This avoids early initialization issues
  }
  
  /// Initialize Privy SDK
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      debugPrint('🔧 Initializing Privy SDK...');
      
      final config = PrivyConfig(
        appId: _appId,
        appClientId: _clientId,
        logLevel: PrivyLogLevel.debug,
      );
      
      _privy = Privy.init(config: config);
      
      // Wait for Privy to be ready using getAuthState (awaitReady is deprecated)
      await _privy!.getAuthState();
      
      _isInitialized = true;
      
      // Check if already authenticated
      final currentUser = await _privy!.getUser();
      if (currentUser != null) {
        _currentUser = currentUser;
        debugPrint('✅ Privy already authenticated: ${_currentUser!.id}');
      }
      
      // Set up auth state listener
      _setupAuthListener();
      
      debugPrint('✅ Privy SDK initialized');
      notifyListeners();
    } catch (e, stack) {
      debugPrint('❌ Privy initialization failed: $e\n$stack');
      _errorMessage = 'Failed to initialize Privy: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  /// Set up listener for auth state changes
  void _setupAuthListener() {
    _authSubscription?.cancel();
    
    _authSubscription = _privy!.authStateStream.listen((state) {
      debugPrint('📡 Auth state changed: $state');
      
      if (state is Authenticated) {
        _currentUser = state.user;
        debugPrint('✅ User authenticated: ${_currentUser!.id}');
        notifyListeners();
      } else if (state is Unauthenticated) {
        _currentUser = null;
        debugPrint('🔓 User unauthenticated');
        notifyListeners();
      }
    });
  }
  
  /// Send OTP code to email
  Future<bool> sendCode(String email) async {
    if (!_isInitialized || _privy == null) {
      await initialize();
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      debugPrint('📧 Sending OTP to: $email');
      
      final result = await _privy!.email.sendCode(email);
      
      bool success = false;
      result.fold(
        onSuccess: (_) {
          debugPrint('✅ OTP sent successfully');
          success = true;
        },
        onFailure: (error) {
          debugPrint('❌ Failed to send OTP: ${error.message}');
          _errorMessage = error.message;
          success = false;
        },
      );
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('❌ Error sending code: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Login with email and OTP code
  Future<bool> loginWithCode({
    required String email,
    required String code,
  }) async {
    if (!_isInitialized || _privy == null) {
      await initialize();
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      debugPrint('🔐 Logging in with code...');
      
      final result = await _privy!.email.loginWithCode(
        code: code,
        email: email,
      );
      
      bool success = false;
      result.fold(
        onSuccess: (user) {
          _currentUser = user;
          debugPrint('✅ Login successful: ${user.id}');
          success = true;
        },
        onFailure: (error) {
          debugPrint('❌ Login failed: ${error.message}');
          _errorMessage = error.message;
          success = false;
        },
      );
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('❌ Error logging in: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Create Solana embedded wallet
  Future<bool> createSolanaWallet() async {
    if (_currentUser == null) {
      _errorMessage = 'Must be logged in to create wallet';
      notifyListeners();
      return false;
    }
    
    // Check if wallet already exists
    if (_currentUser!.embeddedSolanaWallets.isNotEmpty) {
      debugPrint('⚠️ Solana wallet already exists');
      return true;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      debugPrint('🪙 Creating Solana wallet...');
      
      final result = await _currentUser!.createSolanaWallet();
      
      bool success = false;
      result.fold(
        onSuccess: (wallet) {
          debugPrint('✅ Solana wallet created: ${wallet.address}');
          // Refresh user to get updated wallet list
          _refreshUser();
          success = true;
        },
        onFailure: (error) {
          debugPrint('❌ Failed to create wallet: ${error.message}');
          _errorMessage = error.message;
          success = false;
        },
      );
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('❌ Error creating wallet: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Refresh user data from Privy
  Future<void> _refreshUser() async {
    if (_privy == null) return;
    
    try {
      final updatedUser = await _privy!.getUser();
      if (updatedUser != null) {
        _currentUser = updatedUser;
        debugPrint('🔄 User data refreshed');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error refreshing user: $e');
    }
  }
  
  /// Sign a Solana transaction using the embedded wallet
  /// Note: Privy Flutter SDK v0.4.0 has limited transaction signing support
  /// This is a placeholder for future SDK versions
  Future<String> signTransaction(String unsignedTransactionBase58) async {
    if (_currentUser == null || _currentUser!.embeddedSolanaWallets.isEmpty) {
      throw Exception('No Solana wallet available. Please create a wallet first.');
    }
    
    if (_privy == null) {
      throw Exception('Privy SDK not initialized');
    }
    
    try {
      debugPrint('📝 Privy transaction signing requested...');
      debugPrint('   Transaction length: ${unsignedTransactionBase58.length} chars');
      debugPrint('   Wallet: ${getShortenedAddress()}');
      
      // TODO: Privy Flutter SDK v0.4.0 does not yet support direct transaction signing
      // The Privy team is working on this feature for future releases
      // For now, we acknowledge this limitation
      
      debugPrint('⚠️ Privy Flutter SDK does not yet support transaction signing');
      debugPrint('   Privy is best suited for wallet creation and management');
      debugPrint('   For transaction signing on mobile, use Phantom wallet instead');
      
      throw Exception(
        'Privy Flutter SDK does not yet support transaction signing. '
        'Please use Phantom wallet for signing transactions on devnet. '
        'Privy is great for wallet creation, but signing requires Phantom or server-side signing.'
      );
    } catch (e) {
      debugPrint('❌ Privy signing not available: $e');
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  /// Get shortened Solana address for display
  String getShortenedAddress() {
    final address = solanaAddress;
    if (address == null || address.length <= 8) return address ?? '';
    
    final start = address.substring(0, 4);
    final end = address.substring(address.length - 4);
    return '$start...$end';
  }
  
  /// Logout
  Future<void> logout() async {
    if (_privy == null) return;
    
    try {
      await _privy!.logout();
      _currentUser = null;
      debugPrint('✅ Logged out from Privy');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error logging out: $e');
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

