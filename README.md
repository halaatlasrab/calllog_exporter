# Call Log Exporter

A simple Flutter app that reads call logs from Android devices and exports them to CSV format.

## Features

- Read call logs from device
- Normalize phone numbers (+964 → 0)
- Remove duplicate entries
- Export to CSV format
- Share via Android share intent
- Filter by date (last 30 days)

## Permissions Required

- `READ_CALL_LOG` - Access call history
- `READ_CONTACTS` - Get contact names
- `READ_PHONE_STATE` - Phone state access

## Usage

1. Tap "Load Call Logs" to fetch call history
2. Use filter toggle for last 30 days if needed
3. Tap "Export CSV" to create file
4. Tap "Share File" to send via Telegram, WhatsApp, etc.

## CSV Format

```
phone,name,type,date
07801234567,John Doe,incoming,26-03-2026 14:30:25
07801234568,Jane Smith,outgoing,26-03-2026 13:15:10
07801234569,,missed,26-03-2026 12:45:33
```

## Installation

1. Clone this repository
2. Run `flutter pub get`
3. Build APK with `flutter build apk`
4. Install on Android device

## Dependencies

- `call_log: ^3.2.3` - Call log access
- `permission_handler: ^11.0.0` - Permission management
- `csv: ^5.0.2` - CSV export
- `path_provider: ^2.0.15` - File system access
- `share_plus: ^10.1.2` - Share functionality
