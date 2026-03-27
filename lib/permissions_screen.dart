import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'call_log_screen.dart';
import 'permissions_service.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final _service = PermissionsService();
  bool _busy = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _checkAndRoute();
  }

  Future<void> _checkAndRoute() async {
    setState(() {
      _busy = true;
      _message = null;
    });

    final granted = await _service.hasCallLogPermission();
    if (granted) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CallLogScreen()),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _busy = false;
    });
  }

  Future<void> _request() async {
    setState(() {
      _busy = true;
      _message = null;
    });

    final status = await _service.requestCallLogPermission();
    if (!mounted) return;

    if (status.isGranted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CallLogScreen()),
      );
      return;
    }

    setState(() {
      _busy = false;
      if (status.isPermanentlyDenied) {
        _message =
            'Permission permanently denied. Please enable it from Settings.';
      } else if (status.isDenied) {
        _message = 'Permission denied. You can try again.';
      } else if (status.isRestricted) {
        _message = 'Permission restricted by device policy.';
      } else {
        _message = 'Permission not granted.';
      }
    });
  }

  Future<void> _openSettings() async {
    await _service.openSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permission Required')),
      body: Center(
        child: _busy
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'This app needs call log permission to create a CSV file of numbers and names found in your call history. No data is uploaded; everything stays on your device until you share the CSV.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (_message != null)
                      Text(
                        _message!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: _request,
                          child: const Text('Grant'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: _openSettings,
                          child: const Text('Open settings'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

