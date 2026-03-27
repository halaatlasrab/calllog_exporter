class CallLogEntry {
  final String phoneNumber;
  final String? contactName;
  final String callType;
  final DateTime timestamp;
  final int duration;

  CallLogEntry({
    required this.phoneNumber,
    this.contactName,
    required this.callType,
    required this.timestamp,
    required this.duration,
  });

  // Normalize phone number (+964 → 0)
  static String normalizePhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('+964')) {
      return '0' + phoneNumber.substring(4);
    }
    return phoneNumber;
  }

  // Get normalized phone number
  String get normalizedPhoneNumber => normalizePhoneNumber(phoneNumber);

  // Get display name (contact name or normalized phone number)
  String get displayName => contactName ?? normalizedPhoneNumber;

  @override
  String toString() {
    return 'CallLogEntry(phoneNumber: $phoneNumber, contactName: $contactName, callType: $callType, timestamp: $timestamp, duration: $duration)';
  }

  // Convert to CSV row
  List<String> toCsvRow() {
    return [
      normalizedPhoneNumber,
      contactName ?? '',
      callType,
      timestamp.toIso8601String(),
      duration.toString(),
    ];
  }

  // CSV header
  static List<String> get csvHeader => [
    'Phone Number',
    'Contact Name',
    'Call Type',
    'Timestamp',
    'Duration (seconds)',
  ];
}
