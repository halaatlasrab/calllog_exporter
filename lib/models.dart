class CallEntry {
  final String phoneNumber;
  final String? name;
  final DateTime timestamp;
  final String callType; // incoming, outgoing, missed, unknown
  final int durationSeconds;

  CallEntry({
    required this.phoneNumber,
    this.name,
    required this.timestamp,
    required this.callType,
    required this.durationSeconds,
  });
}

class LogContact {
  final String phoneNumber;
  final String? name;
  final int totalCalls;
  final int incomingCount;
  final int outgoingCount;
  final int missedCount;
  final DateTime firstSeen;
  final DateTime lastSeen;

  LogContact({
    required this.phoneNumber,
    this.name,
    required this.totalCalls,
    required this.incomingCount,
    required this.outgoingCount,
    required this.missedCount,
    required this.firstSeen,
    required this.lastSeen,
  });
}

