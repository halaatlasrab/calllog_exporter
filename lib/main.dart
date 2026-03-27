import 'dart:io';
import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const CallLogExporterApp());
}

class CallLogExporterApp extends StatelessWidget {
  const CallLogExporterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Call Log Exporter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
  String? exportedFilePath;
  bool filterLast30Days = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Log Exporter'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          if (callLogs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => setState(() {
                callLogs = [];
                exportedFilePath = null;
              }),
              tooltip: 'Clear',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isLoading ? Icons.sync : Icons.info_outline,
                          color: isLoading ? Colors.blue : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Status: ${isLoading ? "Loading..." : error ?? "Ready"}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      'Call logs found: ${callLogs.length}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (exportedFilePath != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'CSV exported: ${exportedFilePath!.split('/').last}',
                        style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Options
            SwitchListTile(
              title: const Text('Last 30 days only'),
              subtitle: const Text('Filter results by date'),
              value: filterLast30Days,
              onChanged: isLoading ? null : (bool value) {
                setState(() {
                  filterLast30Days = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Action Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isLoading ? null : loadCallLogs,
                    icon: isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.refresh),
                    label: const Text('Load Call Logs'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: callLogs.isEmpty || isLoading ? null : exportToCsv,
                        icon: const Icon(Icons.file_download),
                        label: const Text('Export CSV'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: exportedFilePath == null || isLoading ? null : shareFile,
                        icon: const Icon(Icons.share),
                        label: const Text('Share File'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Preview List
            if (callLogs.isNotEmpty) ...[
              const Text(
                'Recent Logs Preview:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: callLogs.length > 5 ? 5 : callLogs.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final log = callLogs[index];
                    return ListTile(
                      dense: true,
                      leading: Icon(_getCallIcon(log.callType)),
                      title: Text(log.name ?? log.number ?? 'Unknown'),
                      subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(log.timestamp ?? 0)
                      )),
                      trailing: Text(_formatDuration(log.duration ?? 0)),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getCallIcon(CallType? type) {
    switch (type) {
      case CallType.incoming: return Icons.call_received;
      case CallType.outgoing: return Icons.call_made;
      case CallType.missed: return Icons.call_missed;
      default: return Icons.call;
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  Future<void> loadCallLogs() async {
    setState(() {
      isLoading = true;
      error = null;
      exportedFilePath = null;
    });

    try {
      // Check permissions
      if (Platform.isAndroid) {
        final status = await Permission.phone.request();
        final status2 = await Permission.contacts.request();
        if (status.isDenied || status2.isDenied) {
          throw Exception('Permissions denied');
        }
      }

      // Fetch logs
      Iterable<CallLogEntry> entries;
      if (filterLast30Days) {
        final now = DateTime.now();
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        entries = await CallLog.query(
          dateFrom: thirtyDaysAgo.millisecondsSinceEpoch,
        );
      } else {
        entries = await CallLog.get();
      }
      
      if (!mounted) return;

      setState(() {
        // Convert to list and filter/normalize
        callLogs = entries.toList();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> exportToCsv() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Create CSV data
      List<List<dynamic>> rows = [];
      rows.add(['Phone Number', 'Contact Name', 'Call Type', 'Timestamp', 'Duration (seconds)']);
      
      // Add call log entries
      for (final log in callLogs) {
        String phoneNumber = log.number ?? '';
        // Normalize phone number (+964 → 0)
        if (phoneNumber.startsWith('+964')) {
          phoneNumber = '0${phoneNumber.substring(4)}';
        }
        
        final date = DateTime.fromMillisecondsSinceEpoch(log.timestamp ?? 0);
        
        rows.add([
          phoneNumber,
          log.name ?? '',
          log.callType.toString().split('.').last,
          DateFormat('dd-MM-yyyy HH:mm:ss').format(date),
          log.duration.toString(),
        ]);
      }
      
      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(rows);
      
      // Save to temporary directory
      final directory = await getTemporaryDirectory();
      final fileName = 'call_logs_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csv);
      
      if (!mounted) return;

      setState(() {
        exportedFilePath = file.path;
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV generated: $fileName')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> shareFile() async {
    if (exportedFilePath == null) return;
    
    try {
      final file = XFile(exportedFilePath!);
      await Share.shareXFiles([file], text: 'Call Log Export');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Share failed: $e')),
      );
    }
  }
}
