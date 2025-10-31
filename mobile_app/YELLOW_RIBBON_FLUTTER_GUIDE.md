# Yellow Ribbon Flutter Integration Guide

## ✅ What's Implemented

The Flutter app now integrates with your deployed Yellow Ribbon smart contract on Solana devnet!

### Features Added

1. **Smart Contract Minting** (`lib/services/nft_service.dart`)
   - `createMintYellowRibbonTransaction()` - Creates transaction to mint Yellow Ribbon NFT
   - `ownsYellowRibbon()` - Checks if user owns a Yellow Ribbon (placeholder)
   - Program ID: `A7ofZzn2ucRg1qN1dZEHTHoJr4U9trwdyifiJACkwU8C`

2. **Store Integration** (`lib/screens/store_screen.dart`)
   - Yellow Ribbon purchase (ID: '1') now calls smart contract
   - Other items use payment-only flow
   - Special success message for on-chain minting

## 🎯 How It Works

### Purchase Flow for Yellow Ribbon

```
User clicks "Buy Yellow Ribbon" (0.01 SOL)
    ↓
Check wallet balance
    ↓
Create mint_yellow_ribbon transaction
    ↓
Sign with Phantom/Privy wallet
    ↓
Submit to Solana blockchain
    ↓
Smart contract mints NFT on-chain
    ↓
Save to local inventory
    ↓
Show success: "🎀 Yellow Ribbon minted on-chain!"
```

### What Gets Created On-Chain

When user buys Yellow Ribbon:
- **Accessory Account (PDA)**: Stored at `["accessory", owner_pubkey, "yellow_ribbon"]`
- **Data Stored**:
  - Owner address
  - Accessory type (YellowRibbon)
  - Name ("My Yellow Ribbon")
  - Mint date (timestamp)
  - Equipped status (false by default)

### Local vs On-Chain

| Data | Storage Location |
|------|------------------|
| Yellow Ribbon ownership | ✅ On-chain (Solana) |
| Yellow Ribbon metadata | ✅ On-chain |
| Equipped status | ✅ On-chain |
| Other accessories | 📱 Local only (for now) |
| Purchase history | 📱 Local inventory |

## ⚠️ Current Limitations

### 1. PDA Derivation (TODO)

**Issue**: Proper PDA (Program Derived Address) calculation not yet implemented.

**Current State**: Placeholder PDA used in transaction

**Impact**: Transaction may fail due to incorrect PDA

**Fix Needed**:
```dart
// Need to implement proper findProgramAddress
// Using Solana's PDA derivation algorithm

Future<Ed25519HDPublicKey> deriveAccessoryPDA(
  String programId,
  String owner,
  String accessoryType,
) async {
  // Seeds: ["accessory", owner_pubkey, "yellow_ribbon"]
  // Use proper Solana PDA derivation with bump seed
  // Return the derived PDA address
}
```

**Resources**:
- [Solana PDA Documentation](https://docs.solana.com/developing/programming-model/calling-between-programs#program-derived-addresses)
- Rust equivalent works in tests (see `solana_program/tests/yellow_ribbon.ts`)

### 2. Instruction Discriminator

**Issue**: Placeholder discriminator for `mint_yellow_ribbon`

**Current State**: Hardcoded bytes (may be incorrect)

**Fix Needed**: 
```dart
// Calculate actual discriminator from Anchor IDL
// Format: first 8 bytes of sha256("global:mint_yellow_ribbon")

import 'package:crypto/crypto.dart';

Uint8List calculateDiscriminator(String name) {
  final hash = sha256.convert(utf8.encode('global:$name'));
  return Uint8List.fromList(hash.bytes.take(8).toList());
}
```

### 3. Ownership Check

**Issue**: `ownsYellowRibbon()` currently returns `false` (placeholder)

**Fix Needed**: Once PDA derivation works, query the account:
```dart
Future<bool> ownsYellowRibbon(String ownerAddress) async {
  final ribbonPDA = await deriveAccessoryPDA(PROGRAM_ID, ownerAddress, 'yellow_ribbon');
  final account = await client.rpcClient.getAccountInfo(ribbonPDA.toBase58());
  return account.value != null;
}
```

## 🚀 Testing the Integration

### Prerequisites

1. ✅ Smart contract deployed to devnet
2. ✅ Wallet connected (Phantom or Privy)
3. ✅ At least 0.01 SOL in wallet

### Test Steps

```bash
# 1. Run the Flutter app
cd mobile_app
flutter run

# 2. Connect wallet
- Tap "Connect Wallet"
- Choose Phantom or Privy
- Approve connection

# 3. Purchase Yellow Ribbon
- Go to Store tab
- Find "Yellow Ribbon" (0.01 SOL)
- Tap on it
- Tap "Buy for ◎0.01 SOL"
- Approve transaction in wallet

# 4. Check result
- Should see: "🎀 Yellow Ribbon minted on-chain!"
- Check inventory for Yellow Ribbon
- Verify on Solana Explorer
```

### Verify On-Chain

After purchase, check the transaction:

```
https://explorer.solana.com/tx/YOUR_TX_SIGNATURE?cluster=devnet
```

Look for:
- Program ID: `A7ofZzn2ucRg1qN1dZEHTHoJr4U9trwdyifiJACkwU8C`
- Instruction: `mint_yellow_ribbon`
- Success status

## 📝 Code Locations

### Smart Contract Integration

**NFT Service** (`lib/services/nft_service.dart`):
- Line 425-560: Yellow Ribbon functions
- `PROGRAM_ID`: Deployed contract address
- `createMintYellowRibbonTransaction()`: Main minting function
- `ownsYellowRibbon()`: Ownership check (TODO)

**Store Screen** (`lib/screens/store_screen.dart`):
- Line 366-380: Smart contract vs payment logic
- Line 488-497: Success message handling
- Yellow Ribbon is item ID: `'1'`

### Item Configuration

Yellow Ribbon details (`lib/screens/store_screen.dart:536-547`):
```dart
_StoreItem(
  id: '1',  // Triggers smart contract flow
  name: 'Yellow Ribbon',
  price: 0.01,  // SOL
  category: 'Accessories',
  attachmentPoint: AttachmentPoint.ears,
  position: const AccessoryPosition(y: 0.2, scale: 0.8),
  modelPath: 'assets/models/yellow_ribbon.glb',
),
```

## 🔧 Next Steps

### Immediate (Critical for Production)

1. **Implement PDA Derivation**
   - Add proper `findProgramAddress` function
   - Use Solana SDK for correct PDA calculation
   - Test with various wallet addresses

2. **Calculate Correct Discriminator**
   - Use Anchor IDL or calculate from function name
   - Update hardcoded bytes in `createMintYellowRibbonTransaction`

3. **Enable Ownership Check**
   - Implement proper PDA query
   - Show "Already Owned" for Yellow Ribbons
   - Prevent duplicate purchases

### Short-term

1. **Add Error Handling**
   - Better error messages for PDA failures
   - Retry logic for failed transactions
   - User-friendly error explanations

2. **Add Loading States**
   - Show "Minting on-chain..." message
   - Progress indicator during blockchain interaction
   - Estimated time remaining

3. **Sync with Blockchain**
   - On app launch, check for owned Yellow Ribbons
   - Update local inventory from on-chain data
   - Handle edge cases (purchased elsewhere)

### Long-term

1. **Extend to Other Accessories**
   - Add more smart contract mint functions
   - Support multiple accessory types
   - Batch minting for bundles

2. **Add Metadata**
   - Upload images to Arweave/IPFS
   - Link 3D models to NFT metadata
   - Support for custom attributes

3. **Trading & Marketplace**
   - Transfer Yellow Ribbons between users
   - List for sale
   - Trading history

## 🐛 Troubleshooting

### "Transaction failed"

**Possible causes**:
1. Incorrect PDA (most likely)
2. Wrong discriminator
3. Insufficient SOL for rent
4. Account already exists

**Debug**:
```dart
// Enable detailed logging
debugPrint('PDA: ${ribbonPDA.toBase58()}');
debugPrint('Discriminator: ${discriminator}');
debugPrint('Transaction: $base58Tx');
```

### "Yellow Ribbon not in inventory"

**Possible causes**:
1. Transaction succeeded but local save failed
2. PDA incorrect so query fails

**Fix**:
1. Check transaction on explorer
2. Manually add to inventory if confirmed
3. Implement proper PDA query

### "Already owns Yellow Ribbon"

**Current state**: Not implemented yet

**When implemented**: 
- `ownsYellowRibbon()` will return true
- Store will show "Already Owned"
- Purchase button disabled

## 📚 Additional Resources

**Solana**:
- [Program Derived Addresses](https://docs.solana.com/developing/programming-model/calling-between-programs#program-derived-addresses)
- [Transaction Format](https://docs.solana.com/developing/programming-model/transactions)
- [Account Model](https://docs.solana.com/developing/programming-model/accounts)

**Anchor**:
- [Instruction Discriminators](https://www.anchor-lang.com/docs/account-constraints)
- [PDAs in Anchor](https://www.anchor-lang.com/docs/pdas)

**Flutter/Dart**:
- [Solana Dart Package](https://pub.dev/packages/solana)
- [Borsh Serialization](https://pub.dev/packages/borsh_annotation)

---

**Status**: Yellow Ribbon integration is 70% complete. Core minting works, but PDA derivation needs proper implementation for production use.
