# Mobile Companion MVP - Systems Engineering Plan

## Project Overview
Build a mobile app featuring a cute AI companion with voice interaction, mini-apps, device integration, Solana blockchain state management, and decentralized storage. Total available time: 48-56 hours across 4 days (12-14 hours/day).

## Core MVP Principles
- **Minimum Viable**: Cut anything that doesn't directly demonstrate core value props
- **Demo-Ready**: Focus on visual polish and clear feature demonstration
- **Technical Proof**: Show blockchain integration works, not production-ready infrastructure
- **Time-Boxed**: Hard stops on each phase to prevent scope creep

---

## System Architecture

### High-Level Components
```
┌─────────────────────────────────────────────┐
│           Flutter Mobile App                │
│  ┌────────────┐  ┌──────────────────────┐  │
│  │ Companion  │  │    Mini-Apps         │  │
│  │ UI/Voice   │  │  - Voice Journal     │  │
│  └────────────┘  │  - Mood Tracker      │  │
│                  │  - Device Explorer   │  │
│                  └──────────────────────┘  │
└─────────────────────────────────────────────┘
           │                    │
           ▼                    ▼
┌──────────────────┐   ┌──────────────────┐
│  Solana Program  │   │ Decentralized    │
│  - NFT Mint      │   │ Storage          │
│  - State Updates │   │ - Shelby/Walrus   │
└──────────────────┘   └──────────────────┘
```

### Tech Stack
- **Frontend**: Flutter 3.x
- **Blockchain**: Solana (Devnet for MVP)
- **Storage**: Shelby/Walrus
- **Voice**: flutter_speech, flutter_tts
- **Animation**: Lottie (simpler than Rive for MVP)
- **Wallet**: Phantom deep-linking

---

## MVP Scope Decisions

### ✅ IN SCOPE (Must Have)
1. Single animated companion character
2. Voice input triggers visual/audio responses
3. One companion state stored on Solana
4. Two mini-apps (Voice Journal + Mood Tracker)
5. Basic device sensor integration (shake/tilt)
6. Decentralized storage for one data type (voice recordings)
7. Simple wallet connection via Phantom
8. **ESP32-S3 to Phone communication** (BLE) - physical hardware device triggers companion behaviors and receives state updates

### ❌ OUT OF SCOPE (Nice to Have - Post-MVP)
- Complex multi-device mesh networks
- Multiple companion NFTs/characters
- Complex on-chain games
- Real-time blockchain updates (use batching)
- Production-ready error handling
- Comprehensive test coverage
- Advanced animations/transitions

---

## Development Phases

## PHASE 0: Setup & Architecture (2-3 hours)
**Goal**: Project scaffold and dependency setup
**Day 1, Hours 1-3**

### Tasks
- [ ] Initialize Flutter project with proper structure
- [ ] Set up Solana program workspace (Anchor)
- [ ] Configure development environment (Devnet)
- [ ] Install and verify all dependencies
- [ ] Create basic folder structure

### Dependencies to Install
```yaml
# Flutter pubspec.yaml
dependencies:
  solana: ^0.30.0
  url_launcher: ^6.2.0  # For Phantom deep-linking
  speech_to_text: ^6.6.0
  flutter_tts: ^3.8.0
  lottie: ^3.0.0
  sensors_plus: ^4.0.0
  http: ^1.2.0
  shared_preferences: ^2.2.0
  flutter_blue_plus: ^1.32.0  # For BLE communication with ESP32-S3
  permission_handler: ^11.0.0  # For bluetooth permissions
```

### Time Box: 3 hours MAX
**Check Point**: Can run empty Flutter app + Solana CLI commands work

---

## PHASE 1: Solana Program (4-5 hours)
**Goal**: Minimal on-chain companion state
**Day 1, Hours 4-8**

### Architecture
```rust
// Companion Account Structure
pub struct Companion {
    pub owner: Pubkey,           // Wallet owner
    pub mood: u8,                // 0-100 mood score
    pub interaction_count: u64,  // Total interactions
    pub last_interaction: i64,   // Unix timestamp
    pub bump: u8,                // PDA bump
}
```

### Tasks
- [ ] Create Anchor project structure
- [ ] Implement `initialize_companion` instruction
- [ ] Implement `update_mood` instruction
- [ ] Implement `record_interaction` instruction
- [ ] Deploy to Devnet
- [ ] Test with Anchor tests

### Deliverables
- Working Solana program on Devnet
- Program ID for Flutter integration
- Basic test coverage proving instructions work

### Time Box: 5 hours MAX
**Check Point**: Can call program from Solana CLI

---

## PHASE 2: Flutter Core App (8-10 hours)
**Goal**: Basic UI with companion animation and wallet connection
**Day 1 Hours 10-14 + Day 2 Hours 1-3**

### Sub-Phase 2A: UI Shell (3-4 hours)
**Day 1, Hours 10-12**
#### Tasks
- [ ] Main screen with companion placeholder
- [ ] Bottom navigation for mini-apps
- [ ] Basic app theming (cute color palette)
- [ ] Lottie animation integration (find free cute animation)
- [ ] Simple state management setup (Provider/Riverpod)

#### Deliverables
- Navigable app shell
- Animated character displays on main screen
- Cute UI that feels polished

### Sub-Phase 2B: Wallet Integration (2-3 hours)
**Day 1 Hours 12-14 + Day 2 Hour 1**
#### Tasks
- [ ] Phantom deep-link connection flow
- [ ] Wallet address display/storage
- [ ] Connection state management
- [ ] Basic error handling for wallet connection

#### Implementation Notes
```dart
// Phantom deep-link pattern
final url = 'phantom://v1/connect?app_url=yourapp&redirect_link=yourapp://';
```

#### Deliverables
- Can connect/disconnect Phantom wallet
- Wallet address persists locally
- Connection status visible in UI

### Sub-Phase 2C: Blockchain Integration (3 hours)
**Day 2, Hours 1-3**
#### Tasks
- [ ] Initialize companion on first connection
- [ ] Fetch companion state from chain
- [ ] Display mood/stats in UI
- [ ] Handle case where companion doesn't exist yet

#### Deliverables
- App reads real data from Solana
- UI updates based on on-chain state
- Create companion flow works end-to-end

### Time Box: 10 hours MAX
**Check Point**: Can connect wallet and see companion state from blockchain

---

## PHASE 3: Voice & Behavior (5-6 hours)
**Goal**: Voice interaction triggers mood changes
**Day 2, Hours 4-11**

### Sub-Phase 3A: Voice Input (2-3 hours)
**Day 2, Hours 4-6**
#### Tasks
- [ ] Implement speech-to-text with button press
- [ ] Display transcribed text
- [ ] Basic keyword detection (happy, sad, excited words)
- [ ] Permission handling for microphone

#### Simple Sentiment Logic
```dart
Map<String, int> sentimentKeywords = {
  'happy': 10, 'love': 15, 'great': 8,
  'sad': -10, 'angry': -15, 'bad': -8,
  // ... add 20-30 keywords
};
```

### Sub-Phase 3B: Companion Response (2-3 hours)
**Day 2, Hours 8-11**
#### Tasks
- [ ] Map mood score to animation states
- [ ] Text-to-speech responses based on mood
- [ ] Visual feedback (color changes, different animations)
- [ ] Update on-chain mood (batched every 5 interactions)

#### Deliverables
- Voice input changes companion mood
- Companion responds with voice + animation
- Changes eventually reflected on-chain

### Sub-Phase 3C: Behavior System (1 hour)
**Day 2, Hour 11-12**
#### Tasks
- [ ] 3-5 different mood states with thresholds
- [ ] Different voice responses per mood
- [ ] Simple interaction history (local only for MVP)

### Time Box: 6 hours MAX
**Check Point**: Can talk to companion and see mood changes

---

## PHASE 4: Mini-Apps (6-8 hours)
**Goal**: Two functional mini-apps demonstrating different features
**Day 3, Hours 1-10**

### Mini-App 1: Voice Journal (3-4 hours)
**Day 3, Hours 1-5**
#### Tasks
- [ ] Record voice note with speech-to-text
- [ ] Upload to Arweave/IPFS (choose simpler option)
- [ ] Store content hash on-chain (optional) or locally
- [ ] List previous journal entries
- [ ] Play back entries

#### Storage Decision
For MVP: Use Arweave via ar.io gateway (simpler than IPFS setup)
```dart
// Simplified Arweave upload
POST https://arweave.net/tx
// Store returned TX ID
```

#### Deliverables
- Can record and save voice journals
- Journals stored decentrally (even if just demo with small files)
- List view of past journals

### Mini-App 2: Mood Tracker (2-3 hours)
**Day 3, Hours 7-10**
#### Tasks
- [ ] Simple UI to log daily mood manually
- [ ] Visual mood history (chart/graph)
- [ ] Affects companion's overall mood
- [ ] Local storage for MVP (SQLite/SharedPreferences)

#### Deliverables
- Can log mood entries
- Visual representation of mood over time
- Companion reflects overall mood trend

### Optional: Device Explorer (1 hour - if time permits)
**Day 3, Hours 12-14 if ahead of schedule**
#### Tasks
- [ ] Display device stats in cute format
- [ ] Battery level affects companion energy
- [ ] Storage space shown creatively

### Time Box: 8 hours MAX
**Check Point**: Both mini-apps are functional and demonstrate key features

---

## PHASE 5: Device Integration (6-8 hours)
**Goal**: Device sensors affect companion behavior AND device-to-device communication
**Day 3, Hours 10-14 + Day 4, Hours 1-3**

### Sub-Phase 5A: Device Sensors (3-4 hours)
**Day 3, Hours 10-12**

### Tasks
- [ ] Integrate sensors_plus package
- [ ] Shake detection → companion gets excited
- [ ] Tilt detection → companion looks around
- [ ] Haptic feedback on interactions
- [ ] Background/foreground state handling

### Implementation
```dart
// Simple shake detection
accelerometerEvents.listen((AccelerometerEvent event) {
  double magnitude = sqrt(x*x + y*y + z*z);
  if (magnitude > threshold) {
    // Trigger excited animation
  }
});
```

### Deliverables
- 2-3 sensor-based interactions
- Haptic feedback feels responsive
- Companion feels "alive" and reactive

### Time Box: 4 hours MAX
**Check Point**: Device sensors create noticeable companion reactions

---

### Sub-Phase 5B: ESP32-S3 Hardware Integration (3-4 hours)
**Day 3, Hours 12-14 + Day 4, Hours 1-3**

### Overview
Build a physical ESP32-S3 device that communicates with the mobile app via BLE (Bluetooth Low Energy). The hardware device can trigger companion reactions and display companion state.

### Hardware Requirements
- ESP32-S3 DevKit (with BLE support)
- LED (optional - for visual feedback)
- Button or touch sensor (for triggering interactions)
- USB cable for programming

### Tasks - Mobile App Side
- [ ] Integrate flutter_blue_plus package
- [ ] Implement BLE scanning for ESP32-S3 device
- [ ] Connect to ESP32 via BLE
- [ ] Define BLE service and characteristic UUIDs
- [ ] Send companion state to ESP32 (mood, interaction count)
- [ ] Receive commands from ESP32 (button press = poke companion)
- [ ] Handle BLE disconnection/reconnection
- [ ] Permission handling (Bluetooth)
- [ ] UI showing connection status

### Tasks - ESP32-S3 Side
- [ ] Set up Arduino IDE or PlatformIO for ESP32-S3
- [ ] Implement BLE Server (GATT)
- [ ] Define service UUID and characteristics
- [ ] Characteristic 1: Write (receive companion state from phone)
- [ ] Characteristic 2: Notify (send button events to phone)
- [ ] Button interrupt handler
- [ ] LED indication for connection status
- [ ] Simple serial debug output

### BLE Protocol Design
```
Service UUID: 4fafc201-1fb5-459e-8fcc-c5c9c331914b

Characteristics:
1. Companion State (Read/Notify)
   UUID: beb5483e-36e1-4688-b7f5-ea07361b26a8
   Format: JSON {"mood": 75, "interactions": 42, "level": 5}
   
2. Hardware Command (Write)
   UUID: 1c95d5e3-d8f7-413a-bf3d-7a2e5d0be87e
   Format: JSON {"action": "poke", "intensity": 3}
```

### Implementation - Flutter Side
```dart
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ESP32Service {
  static const String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String STATE_CHAR_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  static const String COMMAND_CHAR_UUID = "1c95d5e3-d8f7-413a-bf3d-7a2e5d0be87e";
  
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? stateCharacteristic;
  BluetoothCharacteristic? commandCharacteristic;
  
  // Scan for ESP32-S3
  Future<void> startScan() async {
    FlutterBluePlus.startScan(timeout: Duration(seconds: 15));
    
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.name == "CompanionHardware") {
          connectToDevice(r.device);
        }
      }
    });
  }
  
  // Connect to ESP32
  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
    connectedDevice = device;
    
    // Discover services
    List<BluetoothService> services = await device.discoverServices();
    
    for (var service in services) {
      if (service.uuid.toString() == SERVICE_UUID) {
        for (var char in service.characteristics) {
          if (char.uuid.toString() == STATE_CHAR_UUID) {
            stateCharacteristic = char;
          } else if (char.uuid.toString() == COMMAND_CHAR_UUID) {
            commandCharacteristic = char;
            // Subscribe to notifications
            await char.setNotifyValue(true);
            char.value.listen((value) {
              handleHardwareCommand(value);
            });
          }
        }
      }
    }
  }
  
  // Send companion state to ESP32
  Future<void> sendCompanionState(int mood, int interactions) async {
    if (stateCharacteristic != null) {
      String json = '{"mood":$mood,"interactions":$interactions}';
      await stateCharacteristic!.write(utf8.encode(json));
    }
  }
  
  // Handle commands from ESP32
  void handleHardwareCommand(List<int> value) {
    String json = utf8.decode(value);
    Map<String, dynamic> data = jsonDecode(json);
    
    if (data['action'] == 'poke') {
      // Trigger companion poke reaction
      triggerCompanionReaction('excited');
    }
  }
}
```

### Implementation - ESP32-S3 Side (Arduino/PlatformIO)
```cpp
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define STATE_CHAR_UUID     "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define COMMAND_CHAR_UUID   "1c95d5e3-d8f7-413a-bf3d-7a2e5d0be87e"

#define BUTTON_PIN 0  // Built-in boot button
#define LED_PIN 2     // Built-in LED

BLEServer* pServer = NULL;
BLECharacteristic* pStateCharacteristic = NULL;
BLECharacteristic* pCommandCharacteristic = NULL;
bool deviceConnected = false;
int companionMood = 50;

class ServerCallbacks: public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    deviceConnected = true;
    digitalWrite(LED_PIN, HIGH);
    Serial.println("Device connected");
  }
  
  void onDisconnect(BLEServer* pServer) {
    deviceConnected = false;
    digitalWrite(LED_PIN, LOW);
    Serial.println("Device disconnected");
    BLEDevice::startAdvertising();
  }
};

class StateCharacteristicCallbacks: public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* pCharacteristic) {
    String value = pCharacteristic->getValue().c_str();
    Serial.println("Received state: " + value);
    
    // Parse JSON and update local state
    // Simple parsing for mood value
    int moodIndex = value.indexOf("\"mood\":");
    if (moodIndex > 0) {
      companionMood = value.substring(moodIndex + 7, moodIndex + 9).toInt();
      Serial.println("Companion mood: " + String(companionMood));
      
      // Visual feedback based on mood
      if (companionMood > 70) {
        // Blink fast (happy)
        for(int i=0; i<5; i++) {
          digitalWrite(LED_PIN, !digitalRead(LED_PIN));
          delay(100);
        }
      }
    }
  }
};

void setup() {
  Serial.begin(115200);
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(LED_PIN, OUTPUT);
  
  // Create BLE Device
  BLEDevice::init("CompanionHardware");
  
  // Create BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks());
  
  // Create BLE Service
  BLEService *pService = pServer->createService(SERVICE_UUID);
  
  // Create State Characteristic (phone writes to this)
  pStateCharacteristic = pService->createCharacteristic(
    STATE_CHAR_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE
  );
  pStateCharacteristic->setCallbacks(new StateCharacteristicCallbacks());
  
  // Create Command Characteristic (ESP32 writes to this, phone subscribes)
  pCommandCharacteristic = pService->createCharacteristic(
    COMMAND_CHAR_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY
  );
  pCommandCharacteristic->addDescriptor(new BLE2902());
  
  // Start service
  pService->start();
  
  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  BLEDevice::startAdvertising();
  
  Serial.println("BLE device ready, waiting for connections...");
}

void loop() {
  // Check button press
  static bool lastButtonState = HIGH;
  bool buttonState = digitalRead(BUTTON_PIN);
  
  if (buttonState == LOW && lastButtonState == HIGH) {
    delay(50); // Debounce
    if (digitalRead(BUTTON_PIN) == LOW) {
      Serial.println("Button pressed!");
      
      if (deviceConnected) {
        // Send poke command to phone
        String json = "{\"action\":\"poke\",\"intensity\":3}";
        pCommandCharacteristic->setValue(json.c_str());
        pCommandCharacteristic->notify();
        Serial.println("Sent poke to phone");
        
        // Visual feedback
        digitalWrite(LED_PIN, HIGH);
        delay(100);
        digitalWrite(LED_PIN, LOW);
      }
    }
  }
  lastButtonState = buttonState;
  
  delay(10);
}
```

### Hardware Demo Flow
1. **Power on ESP32-S3** → LED blinks (advertising)
2. **Open mobile app** → Scan for hardware
3. **Connect to "CompanionHardware"** → LED stays solid (connected)
4. **Phone sends companion state** → ESP32 receives mood value
5. **Press button on ESP32** → Companion on phone reacts with "poke" animation
6. **Companion mood changes on phone** → ESP32 LED blinks pattern changes
7. **Disconnect** → LED turns off, ESP32 starts advertising again

### Mini-App Integration: "Hardware Companion"
- [ ] New mini-app for hardware connection
- [ ] BLE scan button with device list
- [ ] Connection status indicator
- [ ] Manual "sync state" button
- [ ] Show last command from hardware
- [ ] Hardware battery level (if implemented)
- [ ] Connection quality indicator

### Deliverables
- ESP32-S3 programmed and working
- Mobile app can discover and connect to ESP32
- Button press on ESP32 triggers companion reaction
- Companion state syncs to ESP32
- LED feedback shows connection and mood
- Clean UI for hardware connection status
- Demo ready with both devices

### Time Box: 4 hours MAX
**Check Point**: ESP32 and phone communicate bidirectionally via BLE

---

## PHASE 5 COMBINED: Device Integration (Total: 6-8 hours)

---

### ⚠️ CRITICAL NOTES for ESP32-S3 BLE Implementation

**Hardware Setup:**
- ESP32-S3 DevKit (recommended: ESP32-S3-DevKitC-1)
- USB-C cable for programming
- Arduino IDE 2.x or PlatformIO
- ESP32 board support installed

**Permission Requirements:**
```yaml
# Android (android/app/src/main/AndroidManifest.xml)
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>

# iOS (ios/Runner/Info.plist)
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app uses Bluetooth to connect to your companion hardware</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app uses Bluetooth to connect to your companion hardware</string>
```

**ESP32-S3 Setup Steps:**
1. Install Arduino IDE or PlatformIO
2. Add ESP32 board support: `https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json`
3. Select board: ESP32S3 Dev Module
4. Install libraries: None needed for BLE (built-in)
5. Upload code via USB

**BLE Testing Tips:**
1. **Always test on physical phone** - emulators don't support BLE well
2. **Keep ESP32 powered** - via USB or battery
3. **Check serial monitor** - use 115200 baud rate
4. **Device name matters** - use "CompanionHardware" exactly as in code
5. **Range: 10-30 meters** typically for BLE
6. **Connection time: 2-5 seconds** for initial pairing
7. **Permissions critical** - request Bluetooth permissions first
8. **LED feedback helps** - confirms ESP32 is running

**Common Issues & Solutions:**
- **Can't find device**: Check ESP32 serial output, verify advertising
- **Connection drops**: Reduce data frequency, check power supply
- **Permissions denied**: Guide user to settings, explain why needed
- **iOS stricter**: May need specific service UUIDs in Info.plist

**Fallback Strategy:**
If BLE proves too unstable:
- **Plan B**: Mock hardware with phone button
  - "Virtual Hardware Mode" in app
  - Simulates button press
  - Still shows the integration concept
  - Faster to implement if BLE fails

**Demo Strategy:**
- Have ESP32 pre-programmed and tested
- Keep device powered (USB battery pack)
- Place ESP32 visible to audience
- Show serial monitor if presenting on screen
- Have backup video of BLE interaction
- Explain: "This is a physical device triggering the companion"

**Development Priority:**
- Day 3 Hours 12-14: Get basic BLE connection working
- Day 4 Hours 1-2: Bidirectional communication
- Day 4 Hour 3: Polish and error handling

---

### Time Box: 4 hours MAX
**Check Point**: Device sensors create noticeable companion reactions

---

## PHASE 6: Polish & Demo Prep (8-12 hours)
**Goal**: Make it demo-ready
**Day 4, All hours**

### Sub-Phase 6A: Visual Polish (3-4 hours)
**Day 4, Hours 1-4**
#### Tasks
- [ ] Smooth transitions between screens
- [ ] Loading states for blockchain calls
- [ ] Error messages are user-friendly
- [ ] Onboarding flow for first-time users
- [ ] App icon and splash screen

### Sub-Phase 6B: Feature Integration (3-4 hours)
**Day 4, Hours 6-9**
#### Tasks
- [ ] End-to-end testing of full flow
- [ ] Fix critical bugs
- [ ] Optimize blockchain call patterns
- [ ] Add fallback states for offline mode
- [ ] Performance testing on real device

### Sub-Phase 6C: Demo Script (2-3 hours)
**Day 4, Hours 9-11**
#### Create Demo Flow Document
1. Show wallet connection
2. Initialize companion
3. Voice interaction → mood change
4. Record voice journal → show decentralized storage
5. Log mood → show persistence
6. Shake device → show device integration
7. Show on-chain state in explorer

### Deliverables
- Polished, bug-free demo
- Clear demo narrative
- Screenshots/screen recordings ready

### Time Box: 12 hours MAX (with 2-3 hour buffer for advanced features)
**Check Point**: Can run through demo without crashes, looks polished

---

## Risk Mitigation

### High-Risk Areas
1. **Blockchain Integration Complexity**
   - Mitigation: Use Devnet, simplify state structure, batch updates
   - Fallback: Mock blockchain calls if integration fails
   
2. **Decentralized Storage Setup**
   - Mitigation: Use ar.io gateway (no node setup needed)
   - Fallback: Use regular cloud storage with disclaimer
   
3. **Voice Recognition Accuracy**
   - Mitigation: Use well-tested packages, simple keyword matching
   - Fallback: Text input as backup method

4. **ESP32-S3 BLE Communication Reliability**
   - Mitigation: Use flutter_blue_plus (mature library), test extensively, simple protocol
   - Fallback 1: If BLE unstable, implement "Virtual Hardware Mode" (button in app simulates hardware)
   - Fallback 2: Pre-recorded video of hardware interaction
   - Last Resort: Use phone's volume buttons as "hardware" input
   
5. **Time Overruns**
   - Mitigation: Strict time boxes, cut features not core to demo
   - Fallback: Pre-recorded demo video for complex features

### If Behind Schedule
**Priority Cut Order:**
1. Device Explorer mini-app
2. Voice response (keep visual only)
3. ESP32 → Phone state sync (keep Phone → ESP32 button only)
4. On-chain updates (simulate with local state)
5. Decentralized storage (use centralized for demo)
6. **Hardware becomes "virtual" with app button simulating ESP32**

---

## Success Metrics

### Technical Success
- [ ] App builds and runs on physical device
- [ ] Wallet connection works reliably
- [ ] At least one successful on-chain transaction
- [ ] At least one file stored decentrally
- [ ] Voice input triggers correct responses
- [ ] **ESP32-S3 communicates with phone via BLE**
- [ ] **Physical button press triggers app response**
- [ ] **App state syncs to ESP32 hardware**
- [ ] No crashes during demo flow

### Demo Success
- [ ] Complete story: wallet → interaction → storage → on-chain → hardware
- [ ] Visually appealing and "cute"
- [ ] Clear differentiation from web2 apps
- [ ] **Physical hardware integration clearly demonstrated**
- [ ] **Hardware device is visible and responsive in demo**
- [ ] Demonstrates all key value props
- [ ] Runs smoothly in 3-5 minute demo

---

## Daily Breakdown (4 days × 12-14 hours)

### Day 1 (12-14 hours) - Foundation Day
**Focus**: Complete blockchain infrastructure and basic Flutter setup

- **Hour 1-3**: Phase 0 (Setup & Architecture)
  - Project initialization
  - Dependency installation
  - Environment configuration
- **Hour 4-8**: Phase 1 (Solana Program)
  - Write companion state structure
  - Implement all instructions
  - Deploy to Devnet
  - Test with Anchor
- **Hour 9-10**: Break + Meals
- **Hour 10-12**: Phase 2A (UI Shell)
  - Flutter project structure
  - Main screen layout
  - Navigation setup
  - Lottie animation integration
- **Hour 12-14**: Phase 2B Start (Wallet Integration)
  - Phantom deep-link setup
  - Connection flow UI

**End of Day Check**: 
- ✅ Solana program deployed and tested
- ✅ Flutter app runs with basic UI
- ✅ Wallet connection flow started

**Critical Path**: If Solana program isn't done by Hour 8, continue and cut Flutter UI polish

---

### Day 2 (12-14 hours) - Core Features Day
**Focus**: Complete wallet integration, blockchain connection, and voice system

- **Hour 1-3**: Phase 2B Complete + Phase 2C (Blockchain Integration)
  - Finish wallet connection
  - Initialize companion on-chain
  - Fetch and display companion state
  - Error handling
- **Hour 4-6**: Phase 3A (Voice Input)
  - Speech-to-text implementation
  - Microphone permissions
  - Simple sentiment analysis
  - UI for voice input
- **Hour 7-8**: Break + Meals
- **Hour 8-11**: Phase 3B (Companion Response)
  - Map mood to animations
  - Text-to-speech responses
  - Visual feedback system
  - Batch blockchain updates
- **Hour 11-12**: Phase 3C (Behavior System)
  - Mood states and thresholds
  - Varied responses
  - Interaction history (local)
- **Hour 12-14**: Integration Testing + Bug Fixes
  - End-to-end voice → blockchain flow
  - Fix critical bugs
  - Performance optimization

**End of Day Check**:
- ✅ Wallet connects and stays connected
- ✅ Voice input triggers mood changes
- ✅ Companion responds with animation + voice
- ✅ Blockchain state updates successfully

**Critical Path**: If voice isn't working well by Hour 11, pivot to text input with TTS output only

---

### Day 3 (12-14 hours) - Mini-Apps & Hardware Integration Day
**Focus**: Build both mini-apps, integrate decentralized storage, and START ESP32-S3 hardware integration

- **Hour 1-5**: Phase 4 - Mini-App 1 (Voice Journal)
  - Voice recording UI
  - Speech-to-text for journals
  - Arweave/IPFS integration
  - Upload flow
  - List view of past journals
  - Playback functionality
- **Hour 6-7**: Break + Meals
- **Hour 7-10**: Phase 4 - Mini-App 2 (Mood Tracker)
  - Manual mood logging UI
  - Visual mood history (chart)
  - Connect to companion mood
  - Local storage implementation
- **Hour 10-12**: Phase 5A (Device Sensors)
  - Sensors_plus setup
  - Shake detection
  - Tilt/accelerometer
  - Haptic feedback
  - Background handling
- **Hour 12-14**: Phase 5B START (ESP32-S3 Hardware)
  - ESP32-S3 board setup and programming
  - Basic BLE server code
  - Flutter BLE scanning setup
  - Permission handling
  - Test basic connection

**End of Day Check**:
- ✅ Voice Journal saves to decentralized storage
- ✅ Mood Tracker functional and visual
- ✅ Device sensors trigger companion reactions
- ✅ ESP32-S3 programmed and advertising
- ✅ Phone can scan and see ESP32 device
- ✅ All mini-apps navigable

**Critical Path**: If decentralized storage is problematic by Hour 4, use centralized storage. If ESP32 setup takes too long, continue Day 4.

---

### Day 4 (12-14 hours) - Hardware Completion, Polish & Demo Day
**Focus**: Complete ESP32-S3 integration, polish everything, and prepare demo

- **Hour 1-3**: Phase 5B COMPLETE (ESP32-S3 Hardware Integration)
  - Bidirectional BLE communication
  - Button press → companion reaction
  - Send companion state to ESP32
  - LED feedback on ESP32 based on mood
  - "Hardware Companion" mini-app UI
  - Error handling and reconnection logic
  - Test extensively with physical hardware
- **Hour 4-6**: Phase 6A (Visual Polish)
  - Smooth all transitions
  - Loading states everywhere
  - User-friendly error messages
  - Onboarding flow explaining features
  - Hardware connection tutorial
  - App icon + splash screen
  - Color/theme consistency
- **Hour 7-8**: Break + Meals
- **Hour 8-11**: Phase 6B (Feature Integration & Testing)
  - End-to-end testing of full flow
  - Fix all critical bugs
  - Optimize blockchain patterns
  - Offline mode fallbacks
  - Test on real device extensively
  - **Test ESP32 hardware multiple times**
  - Memory/performance optimization
  - Verify hardware connection is stable
- **Hour 11-13**: Demo Preparation
  - Create demo script with hardware showcase
  - Record backup video (including hardware interaction)
  - Prepare demo account/wallet
  - Charge ESP32 (battery pack if needed)
  - Screenshot key features
  - Practice demo run 3+ times with hardware
  - Prepare fallback if BLE fails during demo
  - Test serial monitor display for presentation
- **Hour 13-14**: Buffer & Final Polish
  - Last minute bug fixes
  - Extra animation polish
  - Hardware LED patterns refinement
  - Practice demo one more time
  - Prepare for questions about architecture

**End of Day Check**:
- ✅ ESP32-S3 communicates reliably with phone via BLE
- ✅ Button on hardware triggers companion reaction
- ✅ Hardware shows visual feedback (LED)
- ✅ Complete demo flow works flawlessly
- ✅ No crashes in 5 consecutive demo runs
- ✅ Visually polished and cute
- ✅ Demo script memorized (including hardware demo)
- ✅ Backup materials ready
- ✅ ESP32 charged and working

**Critical Path**: If BLE has issues by Hour 2, implement "virtual hardware mode" in app as fallback

---

## Alternative Schedule (More Aggressive)

### For 4 days × 14 hours (56 total hours)

Use the extra 8 hours (2hr/day) for:
- **Day 1**: +2hrs for more robust Solana program testing
- **Day 2**: +2hrs for advanced voice features (multiple voices, better sentiment)
- **Day 3**: +2hrs for third mini-app or device-to-device features
- **Day 4**: +2hrs for advanced polish or additional features

---

## Progress Tracking

### After Each Day, Rate Yourself:
- 🟢 **On Track**: Completed all checkpoints, within time estimates
- 🟡 **Slightly Behind**: Completed core features, cut some polish
- 🔴 **Behind**: Major features incomplete, need to cut scope

### If 🟡 After Day 1:
- Cut wallet UI polish
- Use simpler Solana state
- Reduce animation complexity

### If 🟡 After Day 2:
- Simplify voice sentiment (use fewer keywords)
- Remove companion voice responses
- Focus on visual feedback only

### If 🟡 After Day 3:
- Cut to 1 mini-app only
- Remove device sensors
- Simplify decentralized storage (centralized backup)

### If 🔴 Any Day:
- **STOP** and reassess scope immediately
- Cut features aggressively
- Focus on one killer demo flow
- Consider mock/simulation for complex parts

---

## Development Environment Setup

### Required Tools
- Flutter SDK 3.16+
- Solana CLI 1.18+
- Anchor 0.29+
- Rust 1.75+
- Android Studio / Xcode
- Phantom Wallet (mobile)
- Solana Devnet SOL (faucet)
- **ESP32-S3 Development Board**
- **Arduino IDE 2.x or PlatformIO**
- **USB-C cable for ESP32 programming**
- **Physical phone for BLE testing (not emulator)**
- **Optional: USB battery pack for portable ESP32 demo**

### Recommended IDE Setup
```
VSCode Extensions:
- Flutter
- Rust Analyzer
- Solana Snippets
- Error Lens
```

---

## Code Organization

```
project_root/
├── solana_program/
│   ├── programs/
│   │   └── companion/
│   │       └── src/
│   │           ├── lib.rs
│   │           ├── instructions/
│   │           └── state/
│   └── tests/
├── esp32_hardware/
│   ├── companion_hardware.ino
│   ├── README.md
│   └── platformio.ini (optional)
├── mobile_app/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/
│   │   │   ├── companion_state.dart
│   │   │   └── hardware_device.dart
│   │   ├── services/
│   │   │   ├── solana_service.dart
│   │   │   ├── voice_service.dart
│   │   │   ├── storage_service.dart
│   │   │   └── esp32_ble_service.dart
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── journal_screen.dart
│   │   │   ├── mood_screen.dart
│   │   │   └── hardware_screen.dart
│   │   └── widgets/
│   │       └── companion_widget.dart
│   └── pubspec.yaml
└── planning.md (this file)
```

---

## Testing Strategy (Minimal for MVP)

### Manual Testing Checklist
- [ ] Fresh install flow
- [ ] Wallet connection/disconnection
- [ ] Voice input with various phrases
- [ ] Mini-app navigation
- [ ] Device sensor triggers
- [ ] **BLE scan discovers ESP32-S3**
- [ ] **Connect to ESP32 successfully**
- [ ] **Button press on ESP32 triggers companion reaction**
- [ ] **Companion state change reflects on ESP32 LED**
- [ ] **Reconnection after BLE disconnect**
- [ ] Background/foreground transitions
- [ ] Network failure handling
- [ ] **Bluetooth permission handling**
- [ ] **ESP32 behavior when phone app closes**

### Automated Testing (If Time Permits)
- Unit tests for mood calculation logic
- Widget tests for key screens
- Integration test for wallet flow

---

## Demo Preparation

### Pre-Demo Checklist
- [ ] Charged phone (90%+)
- [ ] ESP32-S3 powered (USB battery pack or cable)
- [ ] ESP32 programmed and tested (run serial monitor check)
- [ ] Devnet SOL in wallet
- [ ] Phantom wallet installed and configured
- [ ] Test companion already initialized
- [ ] Sample journal entries pre-recorded
- [ ] ESP32 BLE connection tested successfully 3+ times
- [ ] Bluetooth permissions granted on phone
- [ ] ESP32 LED working and visible
- [ ] Good lighting for screen AND hardware visibility
- [ ] USB cable for ESP32 if not using battery
- [ ] Backup video recording of demo (including hardware interaction)
- [ ] Optional: Serial monitor ready if doing technical deep dive

### Demo Script (5 minutes total)
1. **Hook (30s)**: Show cute companion reacting to voice on phone
2. **Web3 Value (1m)**: Connect wallet, show on-chain state in Solana Explorer
3. **Core Features (2.5m)**: 
   - Voice interaction changes companion mood
   - Record voice journal → show it's stored on Arweave/IPFS (show link)
   - Shake phone → device sensors trigger companion excitement
   - **HARDWARE DEMO: Show ESP32-S3 device, press physical button → companion on phone reacts**
   - **Show companion state syncing to ESP32 (LED changes based on mood)**
4. **Technical Deep Dive (1m)**: 
   - Show Solana Explorer with companion NFT
   - Show Arweave transaction
   - Explain BLE communication between hardware and phone
   - Show ESP32 serial monitor (optional if screen sharing)
5. **Vision & Close (30s)**: 
   - True ownership via blockchain
   - Physical hardware companion device
   - Decentralized memory storage
   - Cross-device interoperability
   - Future: wearable companion, home automation integration

---

## Post-MVP Roadmap (For Reference)

### Immediate Next Features
- Device-to-device companion communication
- NFT marketplace for companion skins
- On-chain mini-games with rewards
- Advanced AI responses (LLM integration)

### Future Vision
- Cross-platform (iOS + Android)
- Web companion viewer
- Companion breeding/genetics
- DAO governance for companion evolution rules

---

## Notes for Engineering LLM

### Context Assumptions
- Developer has Flutter/Solana experience
- Access to Devnet faucet for testing
- Mobile device for testing (Android/iOS)
- Basic understanding of blockchain concepts

### Key Technical Decisions
1. **Devnet Only**: No mainnet deployment for MVP
2. **Phantom Deep-Link**: Simplest wallet integration
3. **Batched Updates**: Reduce transaction count/cost
4. **Arweave via Gateway**: Simpler than IPFS node
5. **Local-First**: Store most data locally, sync to chain periodically
6. **ESP32-S3 with BLE**: Physical hardware companion device
   - BLE (Bluetooth Low Energy) for phone communication
   - Simple JSON protocol over BLE characteristics
   - Built-in LED for visual feedback
   - Button input for triggering app events
   - Low power consumption (~20mA active, ~5mA idle)
   - Range: 10-30 meters typical
   - No WiFi needed for phone-hardware communication

### When to Ask for Help
- Stuck on any task for >1 hour
- Blockchain integration not working after 2 attempts
- Deployment issues with Solana program
- Voice recognition accuracy <60%

### Definition of Done
Each phase is "done" when:
- Code compiles without errors
- Feature works as described
- Committed to version control
- Basic manual testing passed
- Within time box allocation

---

## Emergency Pivots

### If Blockchain Integration Fails (Day 2-3)
- Mock blockchain with local SQLite
- Show UI/UX with fake data
- Use demo mode disclaimer
- Focus on other novel features

### If Voice Features Don't Work Well (Day 3)
- Pivot to text-based interaction
- Use canned responses
- Focus on visual/behavior system
- Keep TTS for output only

### If Running Out of Time (Day 4-5)
- Cut to 1 mini-app only
- Remove device sensors
- Simplify animations
- Focus on core blockchain demo

---

## Final Checklist Before Demo

### Technical
- [ ] App installed on demo device
- [ ] Wallet connected with sufficient SOL
- [ ] All features tested in sequence
- [ ] No console errors visible
- [ ] Performance acceptable (no lag)

### Presentation
- [ ] Demo script memorized
- [ ] Backup plan prepared
- [ ] Screenshots/videos captured
- [ ] Solana Explorer links ready
- [ ] GitHub repo cleaned up

### Story
- [ ] Clear problem statement
- [ ] Web3 value prop articulated
- [ ] Technical innovation highlighted
- [ ] Future vision outlined
- [ ] Audience questions anticipated

---

**Remember**: 30-40 hours is tight. Be ruthless about scope. A polished demo of 3 features beats a broken demo of 10 features. Cut early, cut often, stay on time boxes.

Good luck! 🚀