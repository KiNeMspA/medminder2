import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/notification_service.dart';

class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Permission Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final permissions = await ref.read(notificationServiceProvider).checkPermissionStatus();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Notifications: ${permissions['notifications']}\nExact Alarm: ${permissions['exactAlarm']}',
                    ),
                  ),
                );
              },
              child: const Text('Check Permissions'),
            ),
            const SizedBox(height: 16),
            const Text('Pending Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await ref.read(notificationServiceProvider).logPendingNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Check logs for pending notifications')),
                );
              },
              child: const Text('List Pending Notifications'),
            ),
          ],
        ),
      ),
    );
  }
}