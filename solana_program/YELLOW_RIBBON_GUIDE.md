# Yellow Ribbon NFT - Quick Guide

Your companion contract now supports Yellow Ribbon NFT minting!

## ✅ What Was Added

Added 3 new functions to your existing `solana_program`:

### 1. `mint_yellow_ribbon(name: String)`
Mints a Yellow Ribbon NFT for the user
- Creates unique accessory account (PDA)
- Stores owner, type, name, mint date
- Starts as not equipped

### 2. `toggle_accessory()`  
Equips/unequips the Yellow Ribbon on the companion
- Toggles the `equipped` boolean
- Can be called multiple times

### 3. New Data Structures
- **`Accessory`** account - stores NFT data
- **`AccessoryType`** enum - Yellow Ribbon (extensible for more accessories)

## 🚀 Deployment Status

**Program ID**: `A7ofZzn2ucRg1qN1dZEHTHoJr4U9trwdyifiJACkwU8C`

**Status**: Ready to deploy (waiting for devnet faucet)

### To Deploy:
```bash
# Wait 5-10 minutes for faucet rate limit, then:
solana airdrop 2

# Deploy
anchor deploy --provider.cluster devnet

# Test
anchor test --provider.cluster devnet -- --grep "Yellow Ribbon"
```

## 📱 Mobile App Integration

### Purchase Flow (Flutter)

```dart
// In your NFT service:
Future<void> purchaseYellowRibbon(String name) async {
  final wallet = await getWalletAddress();
  
  // 1. Create transaction
  final instruction = await createMintYellowRibbonInstruction(
    programId: 'A7ofZzn2ucRg1qN1dZEHTHoJr4U9trwdyifiJACkwU8C',
    owner: wallet,
    name: name,
  );
  
  // 2. Sign with Phantom
  final signed = await signWithPhantom(instruction);
  
  // 3. Submit
  final signature = await submitTransaction(signed);
  
  print('🎀 Yellow Ribbon minted! Signature: $signature');
}
```

### Check Ownership

```dart
Future<bool> ownsYellowRibbon() async {
  final wallet = await getWalletAddress();
  
  // Derive PDA
  final accessoryPDA = await deriveAccessoryPDA(
    programId: 'A7ofZzn2ucRg1qN1dZEHTHoJr4U9trwdyifiJACkwU8C',
    owner: wallet,
    accessoryType: 'yellow_ribbon',
  );
  
  // Check if account exists
  final account = await connection.getAccountInfo(accessoryPDA);
  return account != null;
}
```

### Equip/Unequip

```dart
Future<void> toggleYellowRibbon() async {
  final instruction = await createToggleAccessoryInstruction(
    programId: 'A7ofZzn2ucRg1qN1dZEHTHoJr4U9trwdyifiJACkwU8C',
    owner: await getWalletAddress(),
  );
  
  final signed = await signWithPhantom(instruction);
  await submitTransaction(signed);
  
  print('✅ Yellow Ribbon toggled!');
}
```

## 🔧 How It Works

### Account Structure

Each user can have:
1. **One Companion** (existing)
   - PDA: `["companion", owner_pubkey]`
   - Stores: mood, interactions, etc.

2. **One Yellow Ribbon** (new!)
   - PDA: `["accessory", owner_pubkey, "yellow_ribbon"]`
   - Stores: owner, type, name, mint date, equipped status

### Data Stored On-Chain

```rust
pub struct Accessory {
    pub owner: Pubkey,              // Who owns this
    pub accessory_type: AccessoryType, // YellowRibbon
    pub name: String,               // User-chosen name (max 50 chars)
    pub mint_date: i64,             // When it was minted
    pub equipped: bool,             // Is it on the companion?
    pub bump: u8,                   // PDA bump
}
```

### Cost Per Mint

- Account rent: ~0.002 SOL
- Transaction fee: ~0.000005 SOL
- **Total: ~0.002 SOL per Yellow Ribbon**

Very affordable! ✨

## 🎮 Testing Locally

```bash
# Build
anchor build

# Test (localnet)
anchor test

# Test specific file
anchor test tests/yellow_ribbon.ts

# Test on devnet
anchor test --provider.cluster devnet
```

## 🌟 Features

✅ **Unique per user** - PDA ensures one Yellow Ribbon per wallet
✅ **On-chain storage** - All data stored on Solana
✅ **Equippable** - Can be equipped/unequipped  
✅ **Named** - Users can give it a custom name
✅ **Timestamped** - Mint date recorded
✅ **Extensible** - Easy to add more accessories

## 🔮 Future Accessories

To add more accessories (Blue Hat, Pink Bow, etc.):

1. Add to enum:
```rust
pub enum AccessoryType {
    YellowRibbon,
    BlueHat,      // Add this
    PinkBow,      // Add this
}
```

2. Add mint function:
```rust
pub fn mint_blue_hat(ctx: Context<MintAccessory>, name: String) -> Result<()> {
    // ... similar to mint_yellow_ribbon
    accessory.accessory_type = AccessoryType::BlueHat;
    // ...
}
```

3. Update PDA seeds to be unique per accessory type

## 📊 Deployment Checklist

- [x] Code written and tested
- [x] Program ID updated
- [x] Build successful
- [ ] Deploy to devnet (waiting for faucet)
- [ ] Run tests on devnet
- [ ] Update mobile app with program ID
- [ ] Test purchase flow end-to-end
- [ ] Deploy to mainnet (when ready)

## 🎯 Next Steps

**Immediate** (Today):
1. Wait for devnet faucet (~10 min)
2. Deploy to devnet
3. Run tests
4. Verify on Solana Explorer

**Short-term** (This week):
1. Integrate with Flutter app
2. Add purchase UI in store screen
3. Show Yellow Ribbon in inventory
4. Render on 3D companion

**Medium-term** (Next week):
1. Add payment verification
2. Add more accessories
3. Create collection/marketplace
4. Deploy to mainnet

## 🐛 Troubleshooting

**"Account already exists"**
- Each user can only mint one Yellow Ribbon
- Use `toggle_accessory` to equip/unequip instead

**"Insufficient funds"**
- Need ~0.002 SOL for minting
- User pays the rent

**"Program not deployed"**
- Run `anchor deploy --provider.cluster devnet`

## 📚 Resources

- Program address: `A7ofZzn2ucRg1qN1dZEHTHoJr4U9trwdyifiJACkwU8C`
- Devnet explorer: https://explorer.solana.com/address/A7ofZzn2ucRg1qN1dZEHTHoJr4U9trwdyifiJACkwU8C?cluster=devnet
- Test file: `tests/yellow_ribbon.ts`
- Source code: `programs/solana_program/src/lib.rs`

---

**You did it! 🎉 Yellow Ribbon NFTs are ready to go!**
