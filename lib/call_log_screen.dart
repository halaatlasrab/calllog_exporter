import 'package:flutter/material.dart';

import 'call_log_service.dart';
import 'export_service.dart';
import 'models.dart';
import 'permissions_screen.dart';
import 'permissions_service.dart';

class CallLogScreen extends StatefulWidget {
  const CallLogScreen({super.key});

  @override
  State<CallLogScreen> createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  final _permissions = PermissionsService();
  final _callLogService = CallLogService();
  final _exportService = ExportService();

  bool _loading = false;
  String? _error;
  List<LogContact> _contacts = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final granted = await _permissions.hasCallLogPermission();
    if (!granted) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PermissionsScreen()),
      );
      return;
    }

    try {
      final entries = await _callLogService.fetchCallEntries();
      final contacts = _callLogService.buildContactsFromEntries(entries);
      if (!mounted) return;
      setState(() {
        _contacts = contacts;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load call log';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _exportAndShare() async {
    if (_contacts.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting ${_contacts.length} contacts...')),
    );

    try {
      final file = await _exportService.exportContactsToCsv(_contacts);
      await _exportService.shareFile(file);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to export contacts')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canExport = !_loading && _error == null && _contacts.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Contacts Exporter'),
        actions: [
          IconButton(
            onPressed: canExport ? _exportAndShare : null,
            icon: const Icon(Icons.share),
            tooltip: 'Export CSV and share',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_contacts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No contacts found in your call log.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _contacts.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final c = _contacts[index];
        final title = (c.name != null && c.name!.trim().isNotEmpty)
            ? c.name!.trim()
            : c.phoneNumber;
        final subtitleLines = <String>[];
        if (c.name != null && c.name!.trim().isNotEmpty) {
          subtitleLines.add(c.phoneNumber);
        }
        subtitleLines.add(
          '${c.totalCalls} calls • ${c.outgoingCount} outgoing, ${c.incomingCount} incoming, ${c.missedCount} missed',
        );

        final lastSeen = c.lastSeen;
        final lastSeenText =
            '${lastSeen.year}-${lastSeen.month.toString().padLeft(2, '0')}-${lastSeen.day.toString().padLeft(2, '0')}';

        return ListTile(
          title: Text(title),
          subtitle: Text(subtitleLines.join('\n')),
          isThreeLine: true,
          trailing: Text(lastSeenText),
        );
      },
    );
  }
}

