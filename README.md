# PlaiPin 🎀

PlaiPin is a digital companion app built with Flutter and Solana blockchain integration. Your PlaiPin companion lives in your pocket, collects memories, wears accessories, and interacts with you throughout the day.

## 🌟 Overview

PlaiPin combines a virtual companion with blockchain-powered NFT accessories, creating a unique digital pet experience. The app features a physical device integration, mood tracking, voice interactions, and a marketplace for customizing your companion.

## 📱 App Structure

### 🏠 Home Screen
**Main companion interaction hub**
- **Live Companion Display**: See your PlaiPin companion with equipped accessories in 3D
- **Status Overview**: View current mood, energy level, and companion state
- **Accessories Display**: See all equipped items (ribbons, glasses, headphones, etc.)
- **Quick Interactions**: Pet, feed, or talk to your companion
- **Real-time Updates**: Companion reacts to your interactions and time of day

### 🛍️ Store Screen
**Shop for accessories, backgrounds, and mini-apps**
- **Accessories**: Cosmetic items for your companion
  - Yellow Ribbon (0.01 SOL) - Ears attachment
  - Flower Crown (0.015 SOL) - Head attachment
  - Bead Bracelet (0.018 SOL) - Ears attachment
  - Small Spinner Hat (0.012 SOL) - Head attachment
  - Rounded Glasses (0.01 SOL) - Eyes attachment
  - Bow Tie (90 SOL) - Neck attachment
  - Headphones (200 SOL) - Head attachment
  - Mint Scarf (0.025 SOL) - Neck attachment

- **Backgrounds**: Change your companion's environment
  - Beach Scene (300 SOL)
  - City Skyline (280 SOL)
  - Forest Path (250 SOL)

- **Mini-apps**: Add functionality to your companion
  - Mood Tracker (0.1 SOL)
  - Daily Fortune (0.1 SOL)
  - Proximity Tag (0.05 SOL)

**Purchase Flow**:
1. Browse items by category (Accessories, Backgrounds, Mini-apps)
2. View item details, price, and 3D preview
3. Connect wallet (Phantom or Privy)
4. Purchase with SOL on Solana devnet
5. Items automatically added to inventory

### 📦 Inventory Screen
**Manage owned items and customize your companion**
- **View All Items**: See everything you've purchased
- **Equip/Unequip**: Customize your companion's appearance
- **Category Filters**: Browse by Accessories, Backgrounds, or Mini-apps
- **Item Details**: View purchase date, transaction signature, and metadata
- **3D Preview**: See how accessories look before equipping
- **Multi-equip**: Wear multiple accessories simultaneously (different attachment points)

### 📔 Diary Screen
**Memory timeline in calendar format**
- **Calendar View**: See all days with saved memories
- **Daily Entries**: Tap any date to view that day's memories
- **Memory Cards**: Each entry shows:
  - Timestamp
  - Mood state
  - Interaction type
  - Voice transcripts (if applicable)
  - Photos/moments captured
- **Scroll Timeline**: Navigate through your companion's history
- **Search & Filter**: Find specific memories or mood patterns

### 🔋 Device Screen
**Physical device management and mini-app dashboard**
- **Battery Status**: 
  - Current charge level
  - Time until empty/full
  - Charging state indicator
  - Battery health metrics

- **Device Info**:
  - Firmware version
  - Bluetooth connection status
  - Last sync time
  - Device serial number

- **Equipped Mini-apps**:
  - Active mini-app widgets
  - Quick access to mini-app features
  - Configure mini-app settings
  - View mini-app data and statistics

## 🔗 Blockchain Integration

### Solana NFT System
- **Network**: Solana Devnet (testnet)
- **Program ID**: `A7ofZzn2ucRg1qN1dZEHTHoJr4U9trwdyifiJACkwU8C`
- **NFT Standard**: Custom Anchor program for accessory minting
- **Wallet Support**: 
  - Phantom Wallet (deep-link integration)
  - Privy Embedded Wallets

### Smart Contract Features
- **Yellow Ribbon NFT**: On-chain minting with PDA (Program Derived Address)
- **Accessory Ownership**: Verifiable on-chain ownership
- **Multiple Instances**: Support for collecting multiple of same accessory
- **Payment Transactions**: SOL transfers to treasury wallet
- **Transaction History**: All purchases recorded on blockchain

## 🎨 3D Assets

### Available 3D Models (GLB format)
Located in `mobile_app/assets/models/`:
- `yellow_ribbon.glb` - Cute ear ribbon
- `flower_crown.glb` - Floral head accessory
- `bead_bracelet.glb` - Colorful bead accessory
- `glasses.glb` - Rounded eyewear
- `bow_tie.glb` - Formal neck accessory
- `headphones.glb` - Music headgear
- `small_spinner_hat.glb` - Fun spinning hat

### Model Viewer
- **Technology**: model-viewer-plus package
- **Features**: 
  - 360° rotation
  - Touch controls
  - Auto-rotate preview
  - WebGL rendering
  - Transparent backgrounds

## 🗂️ Project Structure

```
plaipin-app/
├── mobile_app/              # Flutter mobile application
│   ├── lib/
│   │   ├── models/          # Data models (NFT, Accessory, Inventory)
│   │   ├── screens/         # UI screens (Home, Store, Inventory, Diary, Device)
│   │   ├── services/        # Business logic (NFT, Wallet, Inventory, Solana)
│   │   └── main.dart        # App entry point
│   ├── assets/
│   │   ├── models/          # 3D GLB files for accessories
│   │   ├── images/          # App images and icons
│   │   └── animations/      # Lottie animations
│   └── pubspec.yaml         # Dependencies
│
├── solana_program/          # Solana smart contracts
│   ├── programs/
│   │   └── solana_program/  # Anchor program for NFT minting
│   │       └── src/
│   │           └── lib.rs   # Smart contract logic
│   ├── tests/               # Contract tests
│   └── Anchor.toml          # Anchor configuration
│
└── README.md                # This file
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.5.4)
- Dart SDK
- iOS/Android development environment
- Solana CLI (for smart contract deployment)
- Anchor Framework (for Solana development)

### Mobile App Setup

```bash
# Navigate to mobile app directory
cd mobile_app

# Install dependencies
flutter pub get

# Run on device/simulator
flutter run
```

### Smart Contract Setup

```bash
# Navigate to Solana program directory
cd solana_program

# Build the program
anchor build

# Deploy to devnet
anchor deploy --provider.cluster devnet

# Run tests
anchor test
```

### Environment Variables

Create `.env` file in `mobile_app/`:
```env
TREASURY_WALLET_ADDRESS=<your_treasury_wallet>
SOLANA_RPC_URL=https://api.devnet.solana.com
PROGRAM_ID=A7ofZzn2ucRg1qN1dZEHTHoJr4U9trwdyifiJACkwU8C
```

## 🔧 Key Features

### Voice Interaction
- Speech-to-text for companion conversations
- Text-to-speech for companion responses
- Natural language processing
- Mood-based responses

### Mood System
- Dynamic mood calculation based on:
  - Interaction frequency
  - Time since last interaction
  - Battery level (physical device)
  - User engagement
- Visual mood indicators
- Mood history tracking

### Bluetooth Device Integration
- Connect to physical PlaiPin device
- Real-time battery monitoring
- Sync companion state
- Device notifications

### Multi-Wallet Support
- **Phantom**: Deep-link transaction signing
- **Privy**: Embedded wallet (email/social login)
- Automatic wallet detection
- Secure transaction handling

## 📚 Tech Stack

### Frontend
- **Framework**: Flutter 3.5.4
- **State Management**: Provider
- **3D Rendering**: model_viewer_plus
- **Voice**: speech_to_text, flutter_tts
- **Bluetooth**: flutter_blue_plus
- **UI**: Material Design with custom themes

### Blockchain
- **Network**: Solana
- **Smart Contracts**: Anchor Framework (Rust)
- **SDK**: solana-dart (0.30.4)
- **Wallets**: Phantom, Privy

### Storage
- **Local**: shared_preferences
- **Inventory**: Local JSON with blockchain verification
- **Cache**: In-memory state management

## 🎯 Roadmap

### Current Features ✅
- Companion 3D display with accessories
- Store with Solana payments
- Inventory management
- Diary with calendar view
- Device battery monitoring
- Voice interactions
- Multiple 3D model support

### Upcoming Features 🚧
- [ ] Trading system for accessories
- [ ] Multi-device companion sync
- [ ] More mini-apps (games, utilities)
- [ ] AR (Augmented Reality) companion mode
- [ ] Social features (visit other PlaiPins)
- [ ] Limited edition accessories
- [ ] Seasonal events and rewards
- [ ] Companion evolution system

## 🤝 Contributing

This is a personal project, but suggestions and feedback are welcome!

## 📄 License

Proprietary - All rights reserved

## 🐛 Known Issues

- Yellow Ribbon smart contract minting needs ByteArray type fix
- Some accessories need position fine-tuning in 3D space
- Phantom wallet deep-link may require app restart on iOS

## 📞 Support

For issues or questions, please check the codebase documentation or contact the development team.

---

**Built with ❤️ using Flutter & Solana**
