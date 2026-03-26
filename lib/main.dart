import 'package:flutter/material.dart';
import 'dart:io';
import 'call_log_service.dart';
import 'csv_export_service.dart';
import 'call_log_entry.dart';

void main() {
  runApp(const CallLogExporterApp());
}

class CallLogExporterApp extends StatelessWidget {
  const CallLogExporterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Call Log Exporter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CallLogExporterScreen(),
    );
  }
}

class CallLogExporterScreen extends StatefulWidget {
  const CallLogExporterScreen({super.key});

  @override
  State<CallLogExporterScreen> createState() => _CallLogExporterScreenState();
}

class _CallLogExporterScreenState extends State<CallLogExporterScreen> {
  List<CallLogEntry> callLogs = [];
  bool isLoading = false;
  String? error;
  File? exportedFile;
  bool useLast30DaysFilter = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Log Exporter'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: ${isLoading ? "Loading..." : error ?? "Ready"}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Call logs found: ${callLogs.length}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (exportedFile != null)
                      Text(
                        'CSV exported: ${exportedFile!.path}',
                        style: const TextStyle(fontSize: 14),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Filter Toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text('Filter:'),
                    const Spacer(),
                    Switch(
                      value: useLast30DaysFilter,
                      onChanged: (value) {
                        setState(() {
                          useLast30DaysFilter = value;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      useLast30DaysFilter ? 'Last 30 days' : 'All logs',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Action Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : () => loadCallLogs(),
                        icon: const Icon(Icons.download),
                        label: const Text('Load Call Logs'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: callLogs.isEmpty ? null : () => exportToCsv(),
                        icon: const Icon(Icons.file_download),
                        label: const Text('Export CSV'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: exportedFile == null ? null : () => shareFile(),
                        icon: const Icon(Icons.share),
                        label: const Text('Share File'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: callLogs.isEmpty ? null : () => exportAndShare(),
                        icon: const Icon(Icons.send),
                        label: const Text('Export & Share'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadCallLogs() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final logs = useLast30DaysFilter 
          ? await CallLogService.getLast30DaysCallLogs()
          : await CallLogService.getCallLogs();
      
      setState(() {
        callLogs = logs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> exportToCsv() async {
    try {
      final file = await CsvExportService.exportToCsv(callLogs);
      setState(() {
        exportedFile = file;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV exported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> shareFile() async {
    if (exportedFile == null) return;
    
    try {
      await CsvExportService.shareFile(exportedFile!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    }
  }

  Future<void> exportAndShare() async {
    await exportToCsv();
    if (exportedFile != null) {
      await shareFile();
    }
  }
}
