import 'package:flutter/material.dart';
import 'dart:io';
import 'package:csv/csv.dart';

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
  List<Map<String, dynamic>> callLogs = [];
  bool isLoading = false;
  String? error;
  String? exportedFilePath;

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
                    if (exportedFilePath != null)
                      Text(
                        'CSV exported: $exportedFilePath',
                        style: const TextStyle(fontSize: 14),
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
      // Mock call logs for demonstration
      await Future.delayed(const Duration(seconds: 2));
      
      List<Map<String, dynamic>> mockLogs = [
        {
          'phoneNumber': '+9647801234567',
          'contactName': 'John Doe',
          'callType': 'incoming',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'duration': 120,
        },
        {
          'phoneNumber': '+9647801234568',
          'contactName': 'Jane Smith',
          'callType': 'outgoing',
          'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
          'duration': 300,
        },
        {
          'phoneNumber': '+9647801234569',
          'contactName': null,
          'callType': 'missed',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'duration': 0,
        },
      ];
      
      setState(() {
        callLogs = mockLogs;
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
      // Create CSV data
      List<List<dynamic>> rows = [];
      rows.add(['Phone Number', 'Contact Name', 'Call Type', 'Timestamp', 'Duration (seconds)']);
      
      // Add call log entries
      for (final log in callLogs) {
        String phoneNumber = log['phoneNumber'] as String;
        // Normalize phone number (+964 → 0)
        if (phoneNumber.startsWith('+964')) {
          phoneNumber = '0' + phoneNumber.substring(4);
        }
        
        rows.add([
          phoneNumber,
          log['contactName'] ?? '',
          log['callType'],
          log['timestamp'].toString(),
          log['duration'].toString(),
        ]);
      }
      
      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(rows);
      
      // Save to downloads directory
      final directory = Directory('/Users/sino/Downloads');
      final fileName = 'call_logs_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csv);
      
      setState(() {
        exportedFilePath = file.path;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV exported to Downloads: $fileName')),
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
}
