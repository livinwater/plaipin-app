/// Companion State Model
/// Represents the on-chain state of the companion
class CompanionState {
  final String owner;
  final int mood; // 0-100 mood score
  final int interactionCount;
  final DateTime lastInteraction;

  CompanionState({
    required this.owner,
    required this.mood,
    required this.interactionCount,
    required this.lastInteraction,
  });

  factory CompanionState.fromJson(Map<String, dynamic> json) {
    return CompanionState(
      owner: json['owner'] as String,
      mood: json['mood'] as int,
      interactionCount: json['interactionCount'] as int,
      lastInteraction: DateTime.fromMillisecondsSinceEpoch(
        json['lastInteraction'] as int,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner': owner,
      'mood': mood,
      'interactionCount': interactionCount,
      'lastInteraction': lastInteraction.millisecondsSinceEpoch,
    };
  }
}

