import 'package:permission_handler/permission_handler.dart';
import 'call_log_entry.dart';

class CallLogService {
  static Future<bool> requestPermissions() async {
    final callLogPermission = await Permission.phone.request();
    final contactsPermission = await Permission.contacts.request();
    
    return callLogPermission.isGranted && contactsPermission.isGranted;
  }

  static Future<List<CallLogEntry>> getCallLogs({DateTime? startDate}) async {
    try {
      final hasPermissions = await requestPermissions();
      if (!hasPermissions) {
        throw Exception('Call log and contacts permissions are required');
      }

      // Mock data for now - replace with actual call log reading later
      List<CallLogEntry> mockLogs = [
        CallLogEntry(
          phoneNumber: '+9647801234567',
          contactName: 'John Doe',
          callType: 'incoming',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          duration: 120,
        ),
        CallLogEntry(
          phoneNumber: '+9647801234568',
          contactName: 'Jane Smith',
          callType: 'outgoing',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          duration: 300,
        ),
        CallLogEntry(
          phoneNumber: '+9647801234569',
          contactName: null,
          callType: 'missed',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          duration: 0,
        ),
      ];

      // Filter by date if needed
      if (startDate != null) {
        mockLogs = mockLogs.where((log) => log.timestamp.isAfter(startDate)).toList();
      }

      // Remove duplicates (keep latest entry per phone number)
      final Map<String, CallLogEntry> uniqueLogs = {};
      for (final log in mockLogs) {
        final normalizedPhone = CallLogEntry.normalizePhoneNumber(log.phoneNumber);
        if (!uniqueLogs.containsKey(normalizedPhone) || 
            log.timestamp.isAfter(uniqueLogs[normalizedPhone]!.timestamp)) {
          uniqueLogs[normalizedPhone] = log;
        }
      }

      return uniqueLogs.values.toList();
    } catch (e) {
      throw Exception('Failed to get call logs: $e');
    }
  }

  static Future<List<CallLogEntry>> getLast30DaysCallLogs() async {
    final startDate = DateTime.now().subtract(const Duration(days: 30));
    return getCallLogs(startDate: startDate);
  }
}
