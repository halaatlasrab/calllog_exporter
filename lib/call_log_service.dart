import 'package:call_log/call_log.dart';

import 'models.dart';

class CallLogService {
  String _mapCallType(CallType? type) {
    switch (type) {
      case CallType.incoming:
        return 'incoming';
      case CallType.outgoing:
        return 'outgoing';
      case CallType.missed:
        return 'missed';
      default:
        return 'unknown';
    }
  }

  Future<List<CallEntry>> fetchCallEntries() async {
    final rawEntries = await CallLog.get();
    final entries = <CallEntry>[];

    for (final entry in rawEntries) {
      final number = entry.number ?? '';
      if (number.isEmpty) continue;

      entries.add(
        CallEntry(
          phoneNumber: number,
          name: entry.name,
          timestamp: DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0),
          callType: _mapCallType(entry.callType),
          durationSeconds: entry.duration ?? 0,
        ),
      );
    }

    return entries;
  }

  List<LogContact> buildContactsFromEntries(List<CallEntry> entries) {
    final byNumber = <String, List<CallEntry>>{};

    for (final e in entries) {
      byNumber.putIfAbsent(e.phoneNumber, () => []).add(e);
    }

    final contacts = <LogContact>[];

    byNumber.forEach((phoneNumber, calls) {
      calls.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final totalCalls = calls.length;
      final incomingCount =
          calls.where((c) => c.callType == 'incoming').length;
      final outgoingCount =
          calls.where((c) => c.callType == 'outgoing').length;
      final missedCount = calls.where((c) => c.callType == 'missed').length;

      String? name;
      for (final c in calls) {
        final n = c.name;
        if (n != null && n.trim().isNotEmpty) {
          name = n;
          break;
        }
      }

      contacts.add(
        LogContact(
          phoneNumber: phoneNumber,
          name: name,
          totalCalls: totalCalls,
          incomingCount: incomingCount,
          outgoingCount: outgoingCount,
          missedCount: missedCount,
          firstSeen: calls.first.timestamp,
          lastSeen: calls.last.timestamp,
        ),
      );
    });

    contacts.sort((a, b) => b.totalCalls.compareTo(a.totalCalls));
    return contacts;
  }
}

