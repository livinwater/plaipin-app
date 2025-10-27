import 'package:flutter/material.dart';

/// Hardware Screen
/// ESP32-S3 hardware connection mini-app
class HardwareScreen extends StatefulWidget {
  const HardwareScreen({super.key});

  @override
  State<HardwareScreen> createState() => _HardwareScreenState();
}

class _HardwareScreenState extends State<HardwareScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hardware Companion'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bluetooth,
              size: 80,
              color: Colors.purple,
            ),
            const SizedBox(height: 20),
            const Text(
              'Hardware Device',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Not connected'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement in Phase 5
              },
              icon: const Icon(Icons.search),
              label: const Text('Scan for Devices'),
            ),
          ],
        ),
      ),
    );
  }
}

