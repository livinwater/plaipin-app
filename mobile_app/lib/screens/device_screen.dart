import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/inventory_service.dart';

enum DeviceTab { battery, apps, audio }

/// Device Screen
/// ESP32-S3 hardware connection (Phase 2 - UI Shell only)
class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> with SingleTickerProviderStateMixin {
  bool _isConnected = true;
  int _batteryLevel = 87;
  String _deviceId = '60742';
  DeviceTab _selectedTab = DeviceTab.battery;
  bool _isSyncing = false;
  late AnimationController _syncAnimationController;

  @override
  void initState() {
    super.initState();
    _syncAnimationController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _syncAnimationController.dispose();
    super.dispose();
  }

  void _startSync() {
    if (_isSyncing) return;
    
    setState(() {
      _isSyncing = true;
    });
    
    _syncAnimationController.reset();
    _syncAnimationController.forward();
    
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Device synced successfully!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: SafeArea(
        child: Column(
          children: [
            // Header: PlaiPin (60742) with Connected status
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PlaiPin ($_deviceId)',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _isConnected ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isConnected ? 'Connected' : 'Disconnected',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.darkGray.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Sync button with animation
                      RotationTransition(
                        turns: _syncAnimationController,
                        child: IconButton(
                          onPressed: _isSyncing ? null : _startSync,
                          icon: const Icon(Icons.sync),
                          iconSize: 28,
                          color: _isSyncing ? AppTheme.primaryPink : AppTheme.primaryPurple,
                          tooltip: 'Sync device',
                        ),
                      ),
                      // Settings button
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Settings coming soon!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings_outlined),
                        iconSize: 28,
                        color: AppTheme.darkGray,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Device Image
            Container(
              height: 280,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Image.asset(
                  'assets/images/device_3D.png',
                  width: 280,
                  height: 280,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Tab Bar: Battery Life, Apps, Audio
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildTab(
                    icon: Icons.battery_charging_full,
                    label: 'Battery Life',
                    tab: DeviceTab.battery,
                  ),
                  _buildTab(
                    icon: Icons.apps,
                    label: 'Apps',
                    tab: DeviceTab.apps,
                  ),
                  _buildTab(
                    icon: Icons.volume_up,
                    label: 'Audio',
                    tab: DeviceTab.audio,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Tab Content
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTab({
    required IconData icon,
    required String label,
    required DeviceTab tab,
  }) {
    final isSelected = _selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = tab;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryPink : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? Colors.white : AppTheme.darkGray.withOpacity(0.5),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : AppTheme.darkGray.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTabContent() {
    switch (_selectedTab) {
      case DeviceTab.battery:
        return _buildBatteryContent();
      case DeviceTab.apps:
        return _buildAppsContent();
      case DeviceTab.audio:
        return _buildAudioContent();
    }
  }
  
  Widget _buildBatteryContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getBatteryIcon(),
                      color: _getBatteryColor(),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Battery Level',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$_batteryLevel%',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _getBatteryColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _batteryLevel / 100,
                minHeight: 14,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(_getBatteryColor()),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getBatteryStatus(),
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.darkGray.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppsContent() {
    return Consumer<InventoryService>(
      builder: (context, inventoryService, _) {
        // Get equipped mini-app
        final equippedMiniApp = inventoryService.getEquippedItem('Mini-apps');
        
        // Get all mini-apps in inventory
        final allMiniApps = inventoryService.getItemsByCategory('Mini-apps');
        
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Equipped Apps',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              if (equippedMiniApp != null)
                _buildAppCard(
                  icon: _getIconForApp(equippedMiniApp.name),
                  name: equippedMiniApp.name,
                  description: equippedMiniApp.description,
                  color: AppTheme.primaryPurple,
                  isEquipped: true,
                )
              else
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.darkGray.withOpacity(0.2),
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.apps_outlined,
                          size: 48,
                          color: AppTheme.darkGray.withOpacity(0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No mini-app equipped',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.darkGray.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Go to Inventory to equip a mini-app',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.darkGray.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
              if (allMiniApps.length > 1 && equippedMiniApp != null) ...[
                const SizedBox(height: 24),
                const Text(
                  'Available Apps',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...allMiniApps
                    .where((app) => app.id != equippedMiniApp.id)
                    .map((app) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildAppCard(
                            icon: _getIconForApp(app.name),
                            name: app.name,
                            description: app.description,
                            color: AppTheme.primaryPink,
                            isEquipped: false,
                          ),
                        ))
                    .toList(),
              ],
            ],
          ),
        );
      },
    );
  }
  
  IconData _getIconForApp(String appName) {
    if (appName.toLowerCase().contains('language') || appName.toLowerCase().contains('japanese')) {
      return Icons.translate;
    } else if (appName.toLowerCase().contains('fitness') || appName.toLowerCase().contains('health')) {
      return Icons.fitness_center;
    } else if (appName.toLowerCase().contains('music')) {
      return Icons.music_note;
    } else if (appName.toLowerCase().contains('game')) {
      return Icons.games;
    }
    return Icons.apps;
  }
  
  Widget _buildAudioContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(
              Icons.volume_up,
              size: 64,
              color: AppTheme.primaryPink,
            ),
            const SizedBox(height: 16),
            const Text(
              'Audio Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildAudioSetting('Volume', 75),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppCard({
    required IconData icon,
    required String name,
    required String description,
    required Color color,
    bool isEquipped = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isEquipped 
            ? Border.all(color: AppTheme.primaryPurple, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isEquipped)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.darkGray.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppTheme.darkGray,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAudioSetting(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$value%',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.darkGray.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryPink),
          ),
        ),
      ],
    );
  }
  
  IconData _getBatteryIcon() {
    if (_batteryLevel >= 90) return Icons.battery_full;
    if (_batteryLevel >= 70) return Icons.battery_5_bar;
    if (_batteryLevel >= 50) return Icons.battery_4_bar;
    if (_batteryLevel >= 30) return Icons.battery_3_bar;
    if (_batteryLevel >= 15) return Icons.battery_2_bar;
    return Icons.battery_1_bar;
  }
  
  Color _getBatteryColor() {
    if (_batteryLevel >= 50) return Colors.green;
    if (_batteryLevel >= 20) return Colors.orange;
    return Colors.red;
  }
  
  String _getBatteryStatus() {
    if (_batteryLevel >= 80) return 'Excellent battery life';
    if (_batteryLevel >= 50) return 'Good battery level';
    if (_batteryLevel >= 20) return 'Consider charging soon';
    return 'Low battery - please charge';
  }
}
