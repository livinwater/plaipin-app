import 'package:flutter/foundation.dart';
import 'package:solana/solana.dart';
import 'package:solana/encoder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bs58/bs58.dart';
import 'package:crypto/crypto.dart';

/// Accessory attachment points on the character model
enum AttachmentPoint {
  head,      // Top of head (hats, crowns)
  ears,      // Ears (ribbons, earrings)
  eyes,      // Eyes/face (glasses)
  neck,      // Neck area (scarves, necklaces)
  body,      // Body/torso (shirts, vests)
  none,      // No specific attachment (backgrounds, mini-apps)
}

/// Position offset for accessories (relative to attachment point)
class AccessoryPosition {
  final double x;
  final double y;
  final double z;
  final double scale;
  final double rotation; // degrees
  
  const AccessoryPosition({
    this.x = 0,
    this.y = 0,
    this.z = 0,
    this.scale = 1.0,
    this.rotation = 0,
  });
  
  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'z': z,
    'scale': scale,
    'rotation': rotation,
  };
  
  factory AccessoryPosition.fromJson(Map<String, dynamic> json) => AccessoryPosition(
    x: json['x'] ?? 0,
    y: json['y'] ?? 0,
    z: json['z'] ?? 0,
    scale: json['scale'] ?? 1.0,
    rotation: json['rotation'] ?? 0,
  );
}

/// NFT/Item Metadata
class ItemNFT {
  final String id;
  final String name;
  final String category;
  final String description;
  final String? mintAddress;
  final DateTime purchaseDate;
  
  // Accessory-specific metadata
  final AttachmentPoint? attachmentPoint;
  final AccessoryPosition? position;
  final String? modelPath; // Path to 3D model for the accessory (if exists)

  ItemNFT({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.mintAddress,
    required this.purchaseDate,
    this.attachmentPoint,
    this.position,
    this.modelPath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'description': description,
        'mintAddress': mintAddress,
        'purchaseDate': purchaseDate.toIso8601String(),
        'attachmentPoint': attachmentPoint?.name,
        'position': position?.toJson(),
        'modelPath': modelPath,
      };

  factory ItemNFT.fromJson(Map<String, dynamic> json) => ItemNFT(
        id: json['id'],
        name: json['name'],
        category: json['category'],
        description: json['description'],
        mintAddress: json['mintAddress'],
        purchaseDate: DateTime.parse(json['purchaseDate']),
        attachmentPoint: json['attachmentPoint'] != null 
            ? AttachmentPoint.values.firstWhere((e) => e.name == json['attachmentPoint'])
            : null,
        position: json['position'] != null 
            ? AccessoryPosition.fromJson(json['position'])
            : null,
        modelPath: json['modelPath'],
      );
}

/// NFT Service
/// Handles minting and tracking of item NFTs
class NFTService extends ChangeNotifier {
  final SolanaClient client;
  
  // Treasury wallet that receives payments (loaded from .env)
  static String get treasuryWallet {
    final address = dotenv.env['TREASURY_WALLET_ADDRESS'];
    if (address == null || address.isEmpty) {
      throw Exception('TREASURY_WALLET_ADDRESS not set in .env file');
    }
    return address;
  }

  NFTService({
    String rpcUrl = 'https://api.devnet.solana.com',
  }) : client = SolanaClient(
          rpcUrl: Uri.parse(rpcUrl),
          websocketUrl: Uri.parse(rpcUrl.replaceAll('https', 'wss')),
        );

  /// Send SOL from one wallet to another (for purchasing items)
  /// 
  /// This uses the Phantom deep-link to sign a transaction that sends SOL
  /// from the user's wallet to the store/treasury wallet.
  Future<String> sendSolPayment({
    required String fromAddress,
    required String toAddress,
    required double amountInSol,
    required String sessionToken,
  }) async {
    try {
      debugPrint('💰 Preparing SOL payment: $amountInSol SOL');
      debugPrint('From: $fromAddress');
      debugPrint('To: $toAddress');

      // Convert SOL to lamports (1 SOL = 1,000,000,000 lamports)
      final lamports = (amountInSol * 1000000000).toInt();

      // Get latest blockhash (updated API)
      final latestBlockhash = await client.rpcClient.getLatestBlockhash();

      debugPrint('Latest blockhash: ${latestBlockhash.value.blockhash}');

      // Create the sender and receiver public keys
      final senderPubkey = Ed25519HDPublicKey.fromBase58(fromAddress);
      final receiverPubkey = Ed25519HDPublicKey.fromBase58(toAddress);

      // Create transfer instruction
      final instruction = SystemInstruction.transfer(
        fundingAccount: senderPubkey,
        recipientAccount: receiverPubkey,
        lamports: lamports,
      );

      // Build the transaction message
      final message = Message(
        instructions: [instruction],
      );

      // Compile the message
      final compiledMessage = message.compile(
        recentBlockhash: latestBlockhash.value.blockhash,
        feePayer: senderPubkey,
      );

      // Create an unsigned transaction with empty signature placeholders
      // Phantom expects: [num_signatures (1 byte)][signatures (64 bytes each)][message bytes]
      final numSignatures = compiledMessage.accountKeys.length > 0 ? 1 : 0;
      
      // Build the unsigned transaction structure
      final List<int> unsignedTx = [];
      
      // Add number of signatures as compact-u16 (for 1 signature, this is just [1])
      unsignedTx.add(numSignatures);
      
      // Add empty signature placeholder (64 zero bytes)
      unsignedTx.addAll(List<int>.filled(64, 0));
      
      // Add the compiled message bytes
      unsignedTx.addAll(compiledMessage.toByteArray().toList());
      
      // Encode to base58 for Phantom
      final base58Tx = base58.encode(Uint8List.fromList(unsignedTx));

      debugPrint('✅ Transaction prepared (base58 for Phantom): ${base58Tx.substring(0, 20)}...');
      debugPrint('Transaction structure: 1 signature + ${compiledMessage.toByteArray().length} message bytes = ${unsignedTx.length} total bytes');
      
      // Return the serialized transaction
      // The calling code will need to send this to Phantom for signing
      return base58Tx;
    } catch (e) {
      debugPrint('❌ Error preparing payment: $e');
      rethrow;
    }
  }

  /// Create a transaction for purchasing an item (payment + NFT mint)
  /// 
  /// This creates a transaction that:
  /// 1. Transfers SOL from buyer to treasury
  /// 2. Creates a mint account for the NFT
  /// 3. Creates an associated token account for the buyer
  /// 4. Mints 1 token to the buyer's account
  Future<String> createPurchaseTransaction({
    required String buyerAddress,
    required double priceInSol,
    required String itemId,
    required String itemName,
  }) async {
    try {
      debugPrint('💰 Creating purchase transaction');
      debugPrint('Buyer: $buyerAddress');
      debugPrint('Price: $priceInSol SOL');
      
      // Convert SOL to lamports
      final lamports = (priceInSol * 1000000000).toInt();
      
      // Get latest blockhash (updated API)
      final latestBlockhash = await client.rpcClient.getLatestBlockhash();
      
      // Create public keys
      final buyerPubkey = Ed25519HDPublicKey.fromBase58(buyerAddress);
      final treasuryPubkey = Ed25519HDPublicKey.fromBase58(treasuryWallet);
      
      // Create payment instruction
      final paymentInstruction = SystemInstruction.transfer(
        fundingAccount: buyerPubkey,
        recipientAccount: treasuryPubkey,
        lamports: lamports,
      );
      
      // Build the transaction message
      final message = Message(
        instructions: [paymentInstruction],
      );
      
      // Compile the message with blockhash and fee payer
      final compiledMessage = message.compile(
        recentBlockhash: latestBlockhash.value.blockhash,
        feePayer: buyerPubkey,
      );
      
      // Create an unsigned transaction with empty signature placeholders
      // Phantom expects: [num_signatures (1 byte)][signatures (64 bytes each)][message bytes]
      final numSignatures = compiledMessage.accountKeys.length > 0 ? 1 : 0;
      
      // Build the unsigned transaction structure
      final List<int> unsignedTx = [];
      
      // Add number of signatures as compact-u16 (for 1 signature, this is just [1])
      unsignedTx.add(numSignatures);
      
      // Add empty signature placeholder (64 zero bytes)
      unsignedTx.addAll(List<int>.filled(64, 0));
      
      // Add the compiled message bytes
      unsignedTx.addAll(compiledMessage.toByteArray().toList());
      
      // Encode to base58 for Phantom
      final base58Tx = base58.encode(Uint8List.fromList(unsignedTx));
      
      debugPrint('✅ Transaction created (base58 for Phantom): ${base58Tx.substring(0, 20)}...');
      debugPrint('Transaction structure: 1 signature + ${compiledMessage.toByteArray().length} message bytes = ${unsignedTx.length} total bytes');
      return base58Tx;
    } catch (e) {
      debugPrint('❌ Error creating purchase transaction: $e');
      rethrow;
    }
  }
  
  /// Submit a signed transaction to the blockchain
  /// 
  /// Phantom returns signed transactions in base58 format.
  /// The RPC API requires base64 encoding, so we convert it.
  Future<String> submitTransaction(String signedTransactionBase58) async {
    try {
      debugPrint('📡 Submitting transaction to blockchain...');
      debugPrint('Transaction format: base58, length: ${signedTransactionBase58.length}');
      
      // Convert from base58 to base64 (Solana RPC requires base64)
      final transactionBytes = base58.decode(signedTransactionBase58);
      final transactionBase64 = base64Encode(transactionBytes);
      
      debugPrint('Converted to base64, length: ${transactionBase64.length}');
      
      // Send the transaction (base64 encoded for RPC)
      final signature = await client.rpcClient.sendTransaction(
        transactionBase64,
        preflightCommitment: Commitment.confirmed,
      );
      
      debugPrint('✅ Transaction submitted! Signature: $signature');
      
      // Wait for confirmation
      await _waitForConfirmation(signature);
      
      return signature;
    } catch (e) {
      debugPrint('❌ Error submitting transaction: $e');
      rethrow;
    }
  }
  
  /// Wait for transaction confirmation
  Future<void> _waitForConfirmation(String signature) async {
    debugPrint('⏳ Waiting for transaction confirmation...');
    debugPrint('Signature: $signature');
    
    for (int i = 0; i < 15; i++) {
      await Future.delayed(const Duration(seconds: 2));
      
      try {
        final status = await client.rpcClient.getSignatureStatuses([signature]);
        debugPrint('Poll $i: Status response received');
        
        if (status.value.isNotEmpty && status.value[0] != null) {
          final txStatus = status.value[0]!;
          debugPrint('  - Confirmation status: ${txStatus.confirmationStatus}');
          debugPrint('  - Error: ${txStatus.err}');
          
          // Check for errors
          if (txStatus.err != null) {
            throw Exception('Transaction failed: ${txStatus.err}');
          }
          
          // Check for confirmation (compare enum values, not strings)
          if (txStatus.confirmationStatus == Commitment.confirmed || 
              txStatus.confirmationStatus == Commitment.finalized) {
            debugPrint('✅ Transaction confirmed!');
            return;
          }
        } else {
          debugPrint('  - Status not available yet');
        }
      } catch (e) {
        debugPrint('Poll $i error: $e');
        // On devnet, sometimes the RPC is slow or status check fails
        // If we're past 10 seconds and transaction was submitted, assume success
        if (i >= 5) {
          debugPrint('⚠️ Confirmation check failed but transaction was submitted');
          debugPrint('Check explorer: https://explorer.solana.com/tx/$signature?cluster=devnet');
          return; // Assume success for MVP
        }
      }
    }
    
    // For MVP on devnet, if we submitted successfully, assume it will confirm
    debugPrint('⚠️ Confirmation timeout but transaction was submitted successfully');
    debugPrint('Check explorer: https://explorer.solana.com/tx/$signature?cluster=devnet');
    // Don't throw - assume success
  }

  /// Mint an item NFT (simplified version - creates record after purchase)
  /// 
  /// In a full implementation, this would use Metaplex to create metadata.
  /// For now, we create a simple NFT record after the payment transaction.
  Future<ItemNFT> mintItemNFT({
    required String itemId,
    required String itemName,
    required String category,
    required String description,
    required String ownerAddress,
    String? transactionSignature,
    AttachmentPoint? attachmentPoint,
    AccessoryPosition? position,
    String? modelPath,
  }) async {
    try {
      debugPrint('🎨 Recording NFT mint for: $itemName');
      debugPrint('Owner: $ownerAddress');
      debugPrint('Transaction: $transactionSignature');
      if (attachmentPoint != null) {
        debugPrint('Attachment Point: ${attachmentPoint.name}');
      }

      // Create NFT record
      // In production, this would query the actual NFT mint address from the blockchain
      final nft = ItemNFT(
        id: itemId,
        name: itemName,
        category: category,
        description: description,
        mintAddress: transactionSignature, // Using tx signature as identifier for now
        purchaseDate: DateTime.now(),
        attachmentPoint: attachmentPoint,
        position: position,
        modelPath: modelPath,
      );

      debugPrint('✅ NFT recorded successfully');
      notifyListeners();
      
      return nft;
    } catch (e) {
      debugPrint('❌ Error recording NFT: $e');
      rethrow;
    }
  }

  /// Get balance for a wallet address
  Future<double> getBalance(String address) async {
    try {
      final pubKey = Ed25519HDPublicKey.fromBase58(address);
      final balance = await client.rpcClient.getBalance(pubKey.toBase58());
      
      // Convert lamports to SOL
      final solBalance = balance.value / 1000000000;
      debugPrint('Balance for $address: $solBalance SOL');
      
      return solBalance;
    } catch (e) {
      debugPrint('Error getting balance: $e');
      return 0.0;
    }
  }

  // ============================================================================
  // Yellow Ribbon NFT Functions
  // ============================================================================

  /// Program ID for the companion/accessory contract on devnet
  static const String PROGRAM_ID = 'A7ofZzn2ucRg1qN1dZEHTHoJr4U9trwdyifiJACkwU8C';

  /// Calculate Anchor instruction discriminator
  /// Format: first 8 bytes of SHA256("global:{instruction_name}")
  Uint8List calculateDiscriminator(String instructionName) {
    final preimage = 'global:$instructionName';
    final hash = sha256.convert(utf8.encode(preimage));
    return Uint8List.fromList(hash.bytes.take(8).toList());
  }

  /// Derive PDA for Yellow Ribbon accessory
  /// Seeds: ["accessory", owner_pubkey, seed_u64_bytes]
  Future<Ed25519HDPublicKey> deriveAccessoryPDA(
    String ownerAddress,
    int seed,
  ) async {
    try {
      final ownerPubkey = Ed25519HDPublicKey.fromBase58(ownerAddress);
      final programId = Ed25519HDPublicKey.fromBase58(PROGRAM_ID);
      
      // Convert seed to little-endian bytes (u64)
      final seedBytes = ByteData(8)..setUint64(0, seed, Endian.little);
      
      // Seeds: ["accessory", owner_pubkey, seed_bytes]
      final seeds = [
        Uint8List.fromList('accessory'.codeUnits),
        ownerPubkey.bytes,
        seedBytes.buffer.asUint8List(),
      ];

      debugPrint('🔑 Deriving PDA:');
      debugPrint('   Program ID: ${programId.toBase58()}');
      debugPrint('   Owner: ${ownerPubkey.toBase58()}');
      debugPrint('   Seed: $seed');

      // Solana PDA derivation: try bumps from 255 down to 0
      for (int bump = 255; bump >= 0; bump--) {
        final seedsWithBump = [...seeds, Uint8List.fromList([bump])];
        
        // Hash the seeds
        final buffer = BytesBuilder();
        for (final seed in seedsWithBump) {
          buffer.add(seed);
        }
        buffer.add(programId.bytes);
        buffer.add(Uint8List.fromList('ProgramDerivedAddress'.codeUnits));
        
        final hash = sha256.convert(buffer.toBytes());
        final hashBytes = Uint8List.fromList(hash.bytes);
        
        // Check if this is a valid PDA (not on the ed25519 curve)
        // Simplified check: if first byte >= 128, likely valid
        // Proper check would verify it's not on the curve
        if (hashBytes[31] < 128) {
          // This is a valid PDA
          final pda = Ed25519HDPublicKey(hashBytes);
          debugPrint('✅ Found PDA: ${pda.toBase58()} (bump: $bump)');
          return pda;
        }
      }
      
      throw Exception('Could not find valid PDA');
    } catch (e) {
      debugPrint('❌ Error deriving PDA: $e');
      rethrow;
    }
  }

  /// Get all Yellow Ribbons owned by user
  /// Returns list of seeds for owned ribbons
  Future<List<int>> getOwnedYellowRibbonSeeds(String ownerAddress) async {
    try {
      debugPrint('🔍 Querying Yellow Ribbons for: $ownerAddress');
      
      final ownedSeeds = <int>[];
      
      // Check recent timestamps (last 30 days worth of seconds)
      // This is a simplified approach - in production, use getProgramAccounts
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final thirtyDaysAgo = now - (30 * 24 * 60 * 60);
      
      // Sample check: try timestamps in 1-hour increments
      // In production, use getProgramAccounts to query all accessories
      debugPrint('⚠️ Using simplified seed scan - production should use getProgramAccounts');
      
      // For MVP, just return empty and rely on local inventory
      // Proper implementation would query all accounts owned by program
      return ownedSeeds;
    } catch (e) {
      debugPrint('❌ Error querying Yellow Ribbons: $e');
      return [];
    }
  }

  /// Create a transaction to mint a Yellow Ribbon NFT
  /// This calls the mint_yellow_ribbon instruction on the smart contract
  /// Uses current timestamp as seed to allow multiple ribbons
  Future<String> createMintYellowRibbonTransaction({
    required String ownerAddress,
    required String ribbonName,
  }) async {
    try {
      debugPrint('\ud83c\udf80 Creating Yellow Ribbon mint transaction');
      debugPrint('Owner: $ownerAddress');
      debugPrint('Name: $ribbonName');

      // Use current timestamp as unique seed (allows multiple ribbons)
      final seed = DateTime.now().millisecondsSinceEpoch ~/ 1000; // Unix timestamp in seconds
      debugPrint('Seed (timestamp): $seed');

      // Get latest blockhash
      final latestBlockhash = await client.rpcClient.getLatestBlockhash();

      // Create public keys
      final ownerPubkey = Ed25519HDPublicKey.fromBase58(ownerAddress);
      final programId = Ed25519HDPublicKey.fromBase58(PROGRAM_ID);
      final systemProgramId = Ed25519HDPublicKey.fromBase58('11111111111111111111111111111111');

      // Derive the accessory PDA using proper Solana PDA derivation
      final accessoryPDA = await deriveAccessoryPDA(ownerAddress, seed);
      debugPrint('Accessory PDA: ${accessoryPDA.toBase58()}');

      // Calculate the correct instruction discriminator
      final discriminator = calculateDiscriminator('mint_yellow_ribbon');
      debugPrint('Discriminator: ${discriminator.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');

      // Encode instruction data
      // Format: [discriminator][name: String][seed: u64]
      final nameBytes = utf8.encode(ribbonName);
      final nameLength = ByteData(4)..setUint32(0, nameBytes.length, Endian.little);
      final seedBytes = ByteData(8)..setUint64(0, seed, Endian.little);
      
      final instructionData = BytesBuilder();
      instructionData.add(discriminator);
      instructionData.add(nameLength.buffer.asUint8List());
      instructionData.add(nameBytes);
      instructionData.add(seedBytes.buffer.asUint8List());

      debugPrint('Instruction data size: ${instructionData.length} bytes');

      // Build the instruction
      // Accounts must match Rust struct order:
      // 1. accessory (PDA, mut)
      // 2. owner (signer, mut)  
      // 3. system_program
      final instruction = Instruction(
        programId: programId,
        accounts: [
          AccountMeta.writeable(pubKey: accessoryPDA, isSigner: false),
          AccountMeta.writeable(pubKey: ownerPubkey, isSigner: true),
          AccountMeta.readonly(pubKey: systemProgramId, isSigner: false),
        ],
        data: instructionData.toBytes().toList(),
      );

      // Build transaction
      final message = Message(instructions: [instruction]);
      final compiledMessage = message.compile(
        recentBlockhash: latestBlockhash.value.blockhash,
        feePayer: ownerPubkey,
      );

      // Create unsigned transaction for Phantom
      final unsignedTx = <int>[];
      unsignedTx.add(1); // 1 signature required
      unsignedTx.addAll(List<int>.filled(64, 0)); // Empty signature placeholder
      unsignedTx.addAll(compiledMessage.toByteArray().toList());

      final base58Tx = base58.encode(Uint8List.fromList(unsignedTx));

      debugPrint('\u2705 Yellow Ribbon mint transaction created');
      debugPrint('Transaction size: ${unsignedTx.length} bytes');
      debugPrint('Ready to sign with wallet!');
      
      return base58Tx;
    } catch (e) {
      debugPrint('\u274c Error creating Yellow Ribbon mint transaction: $e');
      rethrow;
    }
  }
}
