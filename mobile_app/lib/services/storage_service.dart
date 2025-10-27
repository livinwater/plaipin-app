import 'package:shared_preferences/shared_preferences.dart';

/// Storage Service
/// Handles decentralized storage (Arweave/IPFS) and local storage
class StorageService {
  // TODO: Implement Arweave upload
  Future<String> uploadToArweave(String data) async {
    throw UnimplementedError('To be implemented in Phase 4');
  }

  // TODO: Implement fetch from Arweave
  Future<String> fetchFromArweave(String txId) async {
    throw UnimplementedError('To be implemented in Phase 4');
  }

  // Local storage helpers
  Future<void> saveLocal(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getLocal(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> removeLocal(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}

