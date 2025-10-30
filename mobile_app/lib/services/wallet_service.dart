import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:pinenacl/x25519.dart' as nacl_x25519;
import 'package:pinenacl/api.dart';
import 'package:pinenacl/encoding.dart';
import 'package:bs58/bs58.dart';

/// Wallet connection states
enum WalletConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

/// Wallet Service for Phantom Deep-Linking
/// 
/// Handles wallet connection via Phantom deep-linking for iOS/Android compatibility.
/// Uses URL schemes to connect to Phantom wallet app.
class WalletService extends ChangeNotifier {
  WalletConnectionState _connectionState = WalletConnectionState.disconnected;
  String? _walletAddress;
  String? _authToken;
  String? _errorMessage;
  String? _session;
  nacl_x25519.PrivateKey? _encryptionPrivateKey;
  String? _dappPublicKey;
  nacl_x25519.PublicKey? _phantomPublicKey; // Store Phantom's public key for encryption
  
  // Transaction signing state
  Completer<String>? _signTransactionCompleter;
  String? _pendingTransaction;
  
  // Getters
  WalletConnectionState get connectionState => _connectionState;
  String? get walletAddress => _walletAddress;
  String? get authToken => _authToken;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _connectionState == WalletConnectionState.connected;
  bool get isConnecting => _connectionState == WalletConnectionState.connecting;
  
  // App configuration
  static const String appUrl = 'https://companion.app';
  static const String appName = 'Mobile Companion';
  static const String redirectScheme = 'companion'; // Custom URL scheme
  static const String cluster = 'devnet'; // or 'mainnet-beta', 'testnet'
  
  // SharedPreferences keys
  static const String _keyWalletAddress = 'wallet_address';
  static const String _keyAuthToken = 'wallet_auth_token';
  static const String _keySession = 'wallet_session';
  
  WalletService() {
    _loadSavedWallet();
  }
  
  /// Load saved wallet info from local storage
  Future<void> _loadSavedWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _walletAddress = prefs.getString(_keyWalletAddress);
      _authToken = prefs.getString(_keyAuthToken);
      _session = prefs.getString(_keySession);
      
      if (_walletAddress != null && _session != null) {
        _connectionState = WalletConnectionState.connected;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved wallet: $e');
    }
  }
  
  /// Connect to Phantom wallet via deep-linking
  /// 
  /// Opens Phantom app with connection request.
  /// User must have Phantom app installed on their device.
  Future<void> connectWallet() async {
    if (_connectionState == WalletConnectionState.connecting) {
      debugPrint('Connection already in progress');
      return;
    }
    
    _connectionState = WalletConnectionState.connecting;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Generate X25519 keypair using pinenacl (TweetNaCl-compatible)
      _encryptionPrivateKey = nacl_x25519.PrivateKey.generate();
      final publicKey = _encryptionPrivateKey!.publicKey;
      
      // Convert to base58 for URL
      _dappPublicKey = base58.encode(Uint8List.fromList(publicKey.asTypedList));
      
      debugPrint('Generated dapp public key: $_dappPublicKey');
      
      // Build Phantom deep-link URL with encryption key
      final redirectLink = '$redirectScheme://connected';
      final encodedAppUrl = Uri.encodeComponent(appUrl);
      final encodedRedirectLink = Uri.encodeComponent(redirectLink);
      final encodedDappKey = Uri.encodeComponent(_dappPublicKey!);
      
      final url = Uri.parse(
        'https://phantom.app/ul/v1/connect'
        '?app_url=$encodedAppUrl'
        '&dapp_encryption_public_key=$encodedDappKey'
        '&redirect_link=$encodedRedirectLink'
        '&cluster=$cluster'
      );
      
      debugPrint('Launching Phantom with URL: $url');
      
      // Check if URL can be launched
      if (await canLaunchUrl(url)) {
        final launched = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        
        if (!launched) {
          throw Exception('Failed to launch Phantom wallet');
        }
        
        // Keep connecting state - actual connection happens in handleDeepLink
        debugPrint('Phantom launched successfully. Waiting for user authorization...');
      } else {
        throw Exception('Could not launch Phantom wallet. Is it installed?');
      }
    } catch (e) {
      debugPrint('Error connecting to wallet: $e');
      _connectionState = WalletConnectionState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  /// Handle deep-link redirect from Phantom wallet
  /// 
  /// This should be called when the app receives a deep-link redirect.
  /// Extract wallet address and auth token from the redirect URL.
  Future<void> handleDeepLink(Uri uri) async {
    debugPrint('Handling deep link: $uri');
    
    try {
      // Extract parameters from redirect URL
      final params = uri.queryParameters;
      
      // Check for error first
      if (params.containsKey('errorCode')) {
        final errorCode = params['errorCode'];
        final errorMessage = params['errorMessage'] ?? 'Unknown error';
        throw Exception('Wallet connection failed: $errorMessage (Code: $errorCode)');
      }
      
      // Extract phantom_encryption_public_key, nonce, and data
      final phantomPublicKeyBase58 = params['phantom_encryption_public_key'];
      final dataBase58 = params['data'];
      final nonceBase58 = params['nonce'];
      
      if (phantomPublicKeyBase58 == null || dataBase58 == null || nonceBase58 == null) {
        throw Exception('Missing required parameters in Phantom response');
      }
      
      debugPrint('Phantom public key: $phantomPublicKeyBase58');
      debugPrint('Data (encrypted): ${dataBase58.substring(0, 20)}...');
      debugPrint('Nonce: $nonceBase58');
      
      // Decode from base58
      final phantomPublicKeyBytes = base58.decode(phantomPublicKeyBase58);
      final encryptedData = base58.decode(dataBase58);
      final nonceBytes = base58.decode(nonceBase58);
      
      debugPrint('Encrypted data length: ${encryptedData.length} bytes');
      debugPrint('Nonce length: ${nonceBytes.length} bytes');
      
      // Create Phantom's public key
      final phantomPublicKey = nacl_x25519.PublicKey(Uint8List.fromList(phantomPublicKeyBytes));
      
      // Store Phantom's public key for later encryption (transaction signing)
      _phantomPublicKey = phantomPublicKey;
      
      // Create Box for NaCl box decryption
      final box = nacl_x25519.Box(
        myPrivateKey: _encryptionPrivateKey!,
        theirPublicKey: phantomPublicKey,
      );
      
      // Decrypt using NaCl box (handles shared secret derivation internally)
      try {
        final decryptedBytes = box.decrypt(
          EncryptedMessage(
            cipherText: Uint8List.fromList(encryptedData),
            nonce: Uint8List.fromList(nonceBytes),
          ),
        );
        
        // Parse decrypted JSON
        final decryptedJson = utf8.decode(decryptedBytes);
        debugPrint('✅ Decrypted data: $decryptedJson');
        
        final responseData = jsonDecode(decryptedJson) as Map<String, dynamic>;
        
        // Extract wallet public key and session
        final walletPublicKey = responseData['public_key'] as String?;
        _session = responseData['session'] as String?;
        
        if (walletPublicKey == null || _session == null) {
          throw Exception('Missing public_key or session in decrypted response');
        }
        
        _walletAddress = walletPublicKey;
        _authToken = phantomPublicKeyBase58;
        _connectionState = WalletConnectionState.connected;
        
        // Save to local storage
        await _saveWalletInfo();
        
        debugPrint('Wallet connected successfully: ${_getShortenedAddress()}');
        debugPrint('Session: $_session');
        notifyListeners();
      } catch (e) {
        debugPrint('❌ Decryption failed: $e');
        debugPrint('Error type: ${e.runtimeType}');
        throw e; // Will be caught by outer catch
      }
    } catch (e) {
      debugPrint('Error handling deep link: $e');
      _connectionState = WalletConnectionState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  /// Disconnect wallet and clear local storage
  Future<void> disconnectWallet() async {
    try {
      // Clear state
      _walletAddress = null;
      _authToken = null;
      _session = null;
      _encryptionPrivateKey = null;
      _dappPublicKey = null;
      _phantomPublicKey = null;
      _connectionState = WalletConnectionState.disconnected;
      _errorMessage = null;
      
      // Clear from local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyWalletAddress);
      await prefs.remove(_keyAuthToken);
      await prefs.remove(_keySession);
      
      debugPrint('Wallet disconnected');
      notifyListeners();
    } catch (e) {
      debugPrint('Error disconnecting wallet: $e');
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  /// Save wallet info to local storage
  Future<void> _saveWalletInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_walletAddress != null) {
        await prefs.setString(_keyWalletAddress, _walletAddress!);
      }
      if (_authToken != null) {
        await prefs.setString(_keyAuthToken, _authToken!);
      }
      if (_session != null) {
        await prefs.setString(_keySession, _session!);
      }
    } catch (e) {
      debugPrint('Error saving wallet info: $e');
    }
  }
  
  /// Get shortened wallet address for display (e.g., "7x4B...9zK2")
  String getShortenedAddress() {
    return _getShortenedAddress();
  }
  
  String _getShortenedAddress() {
    if (_walletAddress == null) return '';
    if (_walletAddress!.length <= 8) return _walletAddress!;
    
    final start = _walletAddress!.substring(0, 4);
    final end = _walletAddress!.substring(_walletAddress!.length - 4);
    return '$start...$end';
  }
  
  /// Generate a mock wallet address for demo purposes
  /// In production, this would be properly extracted from Phantom's encrypted response
  String _generateMockWalletAddress() {
    // Generate a realistic-looking Solana address (base58, 32-44 characters)
    const chars = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return '${chars[random.hashCode % chars.length]}' * 44;
  }
  
  /// Sign a transaction using Phantom wallet
  /// 
  /// Opens Phantom app to sign the transaction via deep-link.
  /// According to Phantom docs, the transaction must be encrypted in a payload.
  /// Returns the signed transaction in base58 format.
  Future<String> signTransaction(String transactionBase58) async {
    try {
      if (!isConnected) {
        throw Exception('Wallet not connected');
      }
      
      // Validate required parameters
      if (_dappPublicKey == null || _dappPublicKey!.isEmpty) {
        throw Exception('Dapp public key not initialized');
      }
      
      if (_session == null || _session!.isEmpty) {
        throw Exception('Session not established. Please reconnect wallet.');
      }
      
      if (_encryptionPrivateKey == null) {
        throw Exception('Encryption key not initialized');
      }
      
      if (_phantomPublicKey == null) {
        throw Exception('Phantom public key not available. Please reconnect wallet.');
      }
      
      debugPrint('📝 Requesting transaction signature from Phantom...');
      debugPrint('Transaction length: ${transactionBase58.length} chars (base58)');
      debugPrint('Session: ${_session!.substring(0, 8)}...');
      
      // Create a completer to wait for the signed transaction
      _signTransactionCompleter = Completer<String>();
      _pendingTransaction = transactionBase58;
      
      // Step 1: Create payload with session and transaction
      // According to Phantom docs: payload = { session, transaction }
      final payload = jsonEncode({
        'session': _session,
        'transaction': transactionBase58,
      });
      
      debugPrint('Payload created: ${payload.length} bytes');
      
      // Step 2: Encrypt the payload using NaCl box
      final box = nacl_x25519.Box(
        myPrivateKey: _encryptionPrivateKey!,
        theirPublicKey: _phantomPublicKey!,
      );
      
      final encryptedMessage = box.encrypt(utf8.encode(payload));
      
      debugPrint('Payload encrypted:');
      debugPrint('  - Ciphertext: ${encryptedMessage.cipherText.length} bytes');
      debugPrint('  - Nonce: ${encryptedMessage.nonce.length} bytes');
      
      // Step 3: Base58 encode the encrypted payload and nonce
      final payloadBase58 = base58.encode(Uint8List.fromList(encryptedMessage.cipherText));
      final nonceBase58 = base58.encode(Uint8List.fromList(encryptedMessage.nonce));
      
      // Step 4: Build Phantom sign transaction URL with encrypted payload
      final redirectLink = '$redirectScheme://signed';
      
      final params = {
        'dapp_encryption_public_key': _dappPublicKey!,
        'nonce': nonceBase58,
        'redirect_link': redirectLink,
        'payload': payloadBase58,
      };
      
      final queryString = params.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      
      final url = Uri.parse('https://phantom.app/ul/v1/signTransaction?$queryString');
      
      debugPrint('Launching Phantom for signing...');
      debugPrint('URL length: ${url.toString().length} chars');
      
      if (await canLaunchUrl(url)) {
        final launched = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        
        if (!launched) {
          throw Exception('Failed to launch Phantom wallet');
        }
        
        debugPrint('⏳ Waiting for user to sign transaction in Phantom...');
        
        // Wait for the signed transaction (with timeout)
        final signedTransaction = await _signTransactionCompleter!.future
            .timeout(
              const Duration(minutes: 5),
              onTimeout: () => throw Exception('Transaction signing timeout'),
            );
        
        debugPrint('✅ Transaction signed successfully');
        return signedTransaction;
      } else {
        throw Exception('Could not launch Phantom wallet');
      }
    } catch (e) {
      debugPrint('❌ Error signing transaction: $e');
      _errorMessage = e.toString();
      _signTransactionCompleter = null;
      _pendingTransaction = null;
      notifyListeners();
      rethrow;
    }
  }
  
  /// Handle signed transaction response from Phantom
  Future<void> handleSignedTransaction(Uri uri) async {
    debugPrint('🔗 Handling signed transaction response');
    debugPrint('URI: ${uri.toString()}');
    
    try {
      final params = uri.queryParameters;
      debugPrint('Query params: ${params.keys.join(", ")}');
      
      // Check for error
      if (params.containsKey('errorCode')) {
        final errorCode = params['errorCode'];
        final errorMessage = params['errorMessage'] ?? 'Transaction signing failed';
        debugPrint('❌ Phantom returned error:');
        debugPrint('   Code: $errorCode');
        debugPrint('   Message: $errorMessage');
        
        _signTransactionCompleter?.completeError(Exception(errorMessage));
        _signTransactionCompleter = null;
        _pendingTransaction = null;
        return;
      }
      
      // Extract and decrypt signed transaction
      final dataBase58 = params['data'];
      final nonceBase58 = params['nonce'];
      
      debugPrint('Received parameters:');
      debugPrint('  - data: ${dataBase58 != null ? "present (${dataBase58.length} chars)" : "MISSING"}');
      debugPrint('  - nonce: ${nonceBase58 != null ? "present" : "MISSING"}');
      
      if (dataBase58 == null || nonceBase58 == null) {
        throw Exception('Missing signed transaction data from Phantom response');
      }
      
      if (_encryptionPrivateKey == null || _phantomPublicKey == null) {
        throw Exception('Encryption keys not available. Please reconnect wallet.');
      }
      
      // Decode from base58
      final encryptedData = base58.decode(dataBase58);
      final nonceBytes = base58.decode(nonceBase58);
      
      // Create Box for NaCl box decryption using stored keys
      final box = nacl_x25519.Box(
        myPrivateKey: _encryptionPrivateKey!,
        theirPublicKey: _phantomPublicKey!,
      );
      
      // Decrypt the signed transaction
      final decryptedBytes = box.decrypt(
        EncryptedMessage(
          cipherText: Uint8List.fromList(encryptedData),
          nonce: Uint8List.fromList(nonceBytes),
        ),
      );
      
      final decryptedJson = utf8.decode(decryptedBytes);
      debugPrint('✅ Decrypted signed transaction data');
      
      final responseData = jsonDecode(decryptedJson) as Map<String, dynamic>;
      final signedTransaction = responseData['transaction'] as String?;
      
      if (signedTransaction == null) {
        throw Exception('Missing signed transaction in response');
      }
      
      // Complete the future with the signed transaction
      _signTransactionCompleter?.complete(signedTransaction);
      _signTransactionCompleter = null;
      _pendingTransaction = null;
      
      debugPrint('✅ Signed transaction received and processed');
    } catch (e) {
      debugPrint('❌ Error processing signed transaction: $e');
      _signTransactionCompleter?.completeError(e);
      _signTransactionCompleter = null;
      _pendingTransaction = null;
    }
  }
  
  /// Clear error message
  void clearError() {
    _errorMessage = null;
    if (_connectionState == WalletConnectionState.error) {
      _connectionState = WalletConnectionState.disconnected;
    }
    notifyListeners();
  }
}

