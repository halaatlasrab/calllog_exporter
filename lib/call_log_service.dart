import 'package:call_log/call_log.dart' as call_log_data;
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

      final Iterable<call_log_data.CallLogEntry> entries = await call_log_data.CallLog.get();
      List<CallLogEntry> callLogs = [];

      for (final log in entries) {
        final entry = CallLogEntry(
          phoneNumber: log.number ?? '',
          contactName: log.name,
          callType: _getCallTypeString(log.callType ?? call_log_data.CallType.unknown),
          timestamp: DateTime.tryParse(log.timestamp.toString()) ?? DateTime.now(),
          duration: log.duration ?? 0,
        );
        callLogs.add(entry);
      }

      // Filter by date if needed
      if (startDate != null) {
        callLogs = callLogs.where((log) => log.timestamp.isAfter(startDate)).toList();
      }

      // Remove duplicates (keep latest entry per phone number)
      final Map<String, CallLogEntry> uniqueLogs = {};
      for (final log in callLogs) {
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

  static String _getCallTypeString(call_log_data.CallType callType) {
    switch (callType) {
      case call_log_data.CallType.incoming:
        return 'incoming';
      case call_log_data.CallType.outgoing:
        return 'outgoing';
      case call_log_data.CallType.missed:
        return 'missed';
      case call_log_data.CallType.rejected:
        return 'rejected';
      case call_log_data.CallType.blocked:
        return 'blocked';
      case call_log_data.CallType.unknown:
        return 'unknown';
      default:
        return 'unknown';
    }
  }

  static Future<List<CallLogEntry>> getLast30DaysCallLogs() async {
    final startDate = DateTime.now().subtract(const Duration(days: 30));
    return getCallLogs(startDate: startDate);
  }
}
