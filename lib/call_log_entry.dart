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

  // Normalize phone number: +964 -> 0, remove spaces/dashes
  static String normalizePhoneNumber(String phone) {
    String normalized = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (normalized.startsWith('+964')) {
      normalized = '0' + normalized.substring(4);
    }
    return normalized;
  }

  Map<String, String> toCsvRow() {
    return {
      'phone': normalizePhoneNumber(phoneNumber),
      'name': contactName ?? '',
      'type': callType,
      'date': '${timestamp.day.toString().padLeft(2, '0')}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}',
    };
  }
}
