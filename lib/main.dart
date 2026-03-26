import 'package:flutter/material.dart';

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
  bool isLoading = false;
  String status = 'Ready';

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
                      'Status: ${isLoading ? "Loading..." : status}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Call logs found: 3',
                      style: TextStyle(fontSize: 14),
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
                        onPressed: () => exportToCsv(),
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
                        onPressed: () => shareFile(),
                        icon: const Icon(Icons.share),
                        label: const Text('Share File'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
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

  void loadCallLogs() async {
    setState(() {
      isLoading = true;
      status = 'Loading call logs...';
    });

    // Simulate loading
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
      status = 'Ready - 3 call logs loaded';
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Call logs loaded successfully!')),
      );
    }
  }

  void exportToCsv() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV exported successfully!')),
      );
    }
  }

  void shareFile() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Share functionality ready!')),
      );
    }
  }
}
