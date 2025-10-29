import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Device Screen
/// ESP32-S3 hardware connection (Phase 2 - UI Shell only)
class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Connection status
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.pastelBlue, AppTheme.pastelPurple],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryPurple.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.bluetooth_disabled,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      Text(
                        'No Device Connected',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        'Connect your ESP32-S3 hardware companion\nto interact with your digital friend!',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Scan button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isScanning ? null : _onScanPressed,
                          icon: Icon(
                            _isScanning ? Icons.hourglass_empty : Icons.search,
                          ),
                          label: Text(
                            _isScanning ? 'Scanning...' : 'Scan for Devices',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPurple,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Info card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info_outline, size: 20, color: AppTheme.primaryPurple),
                                  const SizedBox(width: 8),
                                  Text(
                                    'About Hardware Companion',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(Icons.touch_app, 'Press button to poke companion'),
                              const SizedBox(height: 8),
                              _buildInfoRow(Icons.lightbulb_outline, 'LED shows companion mood'),
                              const SizedBox(height: 8),
                              _buildInfoRow(Icons.sync, 'Auto-sync companion state'),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Phase info
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.pastelYellow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🚧 Hardware integration coming in Phase 5',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.darkGray),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.darkGray,
            ),
          ),
        ),
      ],
    );
  }
  
  void _onScanPressed() {
    setState(() {
      _isScanning = true;
    });
    
    // Simulate scanning
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No devices found. Hardware feature coming in Phase 5!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }
}

