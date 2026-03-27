import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'models.dart';

class ExportService {
  Future<File> exportContactsToCsv(List<LogContact> contacts) async {
    final csv = _toCsv(contacts);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/log_contacts.csv');
    return file.writeAsString(csv);
  }

  Future<void> shareFile(File file) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Call log contacts export',
      ),
    );
  }

  String _toCsv(List<LogContact> contacts) {
    final buffer = StringBuffer();
    buffer.writeln(
      'phoneNumber,name,totalCalls,incomingCount,outgoingCount,missedCount,firstSeen,lastSeen',
    );

    for (final c in contacts) {
      buffer.writeln([
        c.phoneNumber,
        _escapeCsv(c.name ?? ''),
        c.totalCalls,
        c.incomingCount,
        c.outgoingCount,
        c.missedCount,
        c.firstSeen.toIso8601String(),
        c.lastSeen.toIso8601String(),
      ].join(','));
    }

    return buffer.toString();
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      final escaped = value.replaceAll('"', '""');
      return '"$escaped"';
    }
    return value;
  }
}

