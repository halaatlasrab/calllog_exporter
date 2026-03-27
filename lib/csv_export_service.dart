import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'call_log_entry.dart';

class CsvExportService {
  static Future<File> exportToCsv(List<CallLogEntry> callLogs) async {
    try {
      // Get the documents directory
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/call_logs_${DateTime.now().millisecondsSinceEpoch}.csv';
      
      // Create CSV data
      List<List<dynamic>> rows = [];
      rows.add(CallLogEntry.csvHeader); // Add header
      
      // Add call log entries
      for (final log in callLogs) {
        rows.add(log.toCsvRow());
      }
      
      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(rows);
      
      // Write to file
      final file = File(path);
      await file.writeAsString(csv);
      
      return file;
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }

  static Future<void> shareFile(File file) async {
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Call Logs Export',
        text: 'Exported call logs from Call Log Exporter app',
      );
    } catch (e) {
      throw Exception('Failed to share file: $e');
    }
  }
}
