/// Hardware Device Model
/// Represents ESP32-S3 companion hardware
class HardwareDevice {
  final String id;
  final String name;
  final bool isConnected;
  final int? signalStrength;

  HardwareDevice({
    required this.id,
    required this.name,
    this.isConnected = false,
    this.signalStrength,
  });

  HardwareDevice copyWith({
    String? id,
    String? name,
    bool? isConnected,
    int? signalStrength,
  }) {
    return HardwareDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      isConnected: isConnected ?? this.isConnected,
      signalStrength: signalStrength ?? this.signalStrength,
    );
  }
}

