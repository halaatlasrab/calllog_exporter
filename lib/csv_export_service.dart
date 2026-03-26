import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'call_log_entry.dart';

class CsvExportService {
  static Future<File> exportToCsv(List<CallLogEntry> callLogs) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/call_log_export.csv');

    // Create CSV data
    List<List<dynamic>> csvData = [
      ['phone', 'name', 'type', 'date']
    ];

    for (final log in callLogs) {
      final row = log.toCsvRow();
      csvData.add([row['phone'], row['name'], row['type'], row['date']]);
    }

    // Convert to CSV string
    String csv = const ListToCsvConverter().convert(csvData);

    // Write to file
    await file.writeAsString(csv);
    return file;
  }

  static Future<void> shareFile(File file) async {
    await Share.shareXFiles([XFile(file.path)], text: 'Call Log Export');
  }
}
