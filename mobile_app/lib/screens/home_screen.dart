import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/inventory_service.dart';
import '../services/nft_service.dart';

/// Home Screen
/// Main screen with companion animation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _companionMood = 75;
  int _interactionCount = 42;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradient background like Zepeto
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.pastelBlue.withOpacity(0.3),
              AppTheme.pastelPurple.withOpacity(0.2),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // 3D Rabbit Model with Accessories
                Consumer<InventoryService>(
                  builder: (context, inventoryService, _) {
                    final equippedAccessories = inventoryService.equippedItems;
                    
                    return Container(
                      height: 400,
                      width: 400,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.primaryPink.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // 3D Model
                          ModelViewer(
                            src: 'assets/models/plaipin_pink.glb',
                            alt: 'Buddy the Companion',
                            autoRotate: true,
                            autoRotateDelay: 0,
                            cameraControls: true,
                            touchAction: TouchAction.panY,
                            interactionPrompt: InteractionPrompt.none,
                            loading: Loading.eager,
                            ar: false,
                          ),
                          
                          // Equipped Accessories Overlay
                          ..._buildAccessoryOverlays(inventoryService),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Companion Name
                Text(
                  'Buddy',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Mood badge - subtle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.getMoodGradient(_companionMood),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getMoodText(_companionMood),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                
                const Spacer(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _getMoodText(int mood) {
    if (mood >= 80) return 'Very Happy';
    if (mood >= 60) return 'Happy';
    if (mood >= 40) return 'Neutral';
    if (mood >= 20) return 'Sad';
    return 'Very Sad';
  }
  
  /// Build accessory overlays based on equipped items
  /// 
  /// This creates 2D icon overlays OR 3D models positioned relative to the main model
  /// based on the accessory's attachment point and position data.
  List<Widget> _buildAccessoryOverlays(InventoryService inventoryService) {
    final overlays = <Widget>[];
    
    // Get all equipped accessories
    final equippedAccessories = inventoryService.equippedItems;
    
    for (final entry in equippedAccessories.entries) {
      final category = entry.key;
      final itemId = entry.value;
      
      // Skip non-accessory items
      if (category != 'Accessories') continue;
      
      final item = inventoryService.getEquippedItem(category);
      if (item == null) continue;
      
      // Get attachment point and position
      final attachmentPoint = item.attachmentPoint ?? AttachmentPoint.none;
      final position = item.position ?? const AccessoryPosition();
      
      // If item has a 3D model path, render it as a 3D model overlay
      if (item.modelPath != null && item.modelPath!.isNotEmpty) {
        overlays.add(_build3DAccessory(item, attachmentPoint, position));
      } else {
        // Otherwise, use 2D icon overlay (legacy)
        final basePosition = _getAttachmentPointPosition(attachmentPoint);
        final left = basePosition.dx + (position.x * 100);
        final top = basePosition.dy + (position.y * 100);
        
        overlays.add(
          Positioned(
            left: left,
            top: top,
            child: Transform.scale(
              scale: position.scale,
              child: Transform.rotate(
                angle: position.rotation * 3.14159 / 180,
                child: _buildAccessoryIcon(item, attachmentPoint),
              ),
            ),
          ),
        );
      }
    }
    
    return overlays;
  }
  
  /// Build a 3D model accessory overlay
  Widget _build3DAccessory(ItemNFT item, AttachmentPoint point, AccessoryPosition position) {
    // Calculate position for the 3D accessory
    final basePosition = _getAttachmentPointPosition(point);
    final left = basePosition.dx + (position.x * 100) - 50; // Center the model
    final top = basePosition.dy + (position.y * 100) - 50;
    
    return Positioned(
      left: left,
      top: top,
      child: SizedBox(
        width: 100,
        height: 100,
        child: Transform.scale(
          scale: position.scale,
          child: Transform.rotate(
            angle: position.rotation * 3.14159 / 180,
            child: ModelViewer(
              src: item.modelPath!,
              alt: item.name,
              autoRotate: true,
              autoRotateDelay: 0,
              cameraControls: false,
              touchAction: TouchAction.none,
              interactionPrompt: InteractionPrompt.none,
              loading: Loading.eager,
              ar: false,
            ),
          ),
        ),
      ),
    );
  }
  
  /// Get the base position for an attachment point
  /// 
  /// These positions are relative to a 400x400 container with the character centered.
  /// Adjust these values based on your actual 3D model's proportions.
  Offset _getAttachmentPointPosition(AttachmentPoint point) {
    switch (point) {
      case AttachmentPoint.head:
        return const Offset(180, 60);  // Top of head
      case AttachmentPoint.ears:
        return const Offset(240, 90);  // Ear area (right side)
      case AttachmentPoint.eyes:
        return const Offset(185, 100); // Eye/face area
      case AttachmentPoint.neck:
        return const Offset(185, 140); // Neck area
      case AttachmentPoint.body:
        return const Offset(185, 200); // Body/torso
      case AttachmentPoint.none:
        return const Offset(200, 200); // Center
    }
  }
  
  /// Build the visual representation of an accessory
  Widget _buildAccessoryIcon(ItemNFT item, AttachmentPoint point) {
    // Get appropriate icon for the accessory
    IconData icon;
    Color color;
    
    switch (item.name) {
      case 'Yellow Ribbon':
        icon = Icons.favorite;
        color = Colors.yellow.shade700;
        break;
      case 'Mint Scarf':
        icon = Icons.waves;
        color = Colors.teal.shade300;
        break;
      case 'Flower Crown':
        icon = Icons.local_florist;
        color = Colors.pink.shade300;
        break;
      case 'Bead Bracelet':
        icon = Icons.circle;
        color = Colors.blue.shade300;
        break;
      case 'Little Spinner Hat':
        icon = Icons.change_history;
        color = Colors.grey.shade700;
        break;
      case 'Small Rounded Glasses':
        icon = Icons.remove_red_eye;
        color = Colors.brown.shade400;
        break;
      case 'Bow Tie':
        icon = Icons.favorite_border;
        color = Colors.red.shade700;
        break;
      case 'Headphones':
        icon = Icons.headset;
        color = Colors.blue.shade700;
        break;
      default:
        icon = Icons.star;
        color = AppTheme.primaryPink;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }
}

