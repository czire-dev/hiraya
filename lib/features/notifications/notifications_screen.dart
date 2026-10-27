// OWNER: Person 6 (Notifications & QA)
// Use case: "Send notification" (in-app). Notifications are created by the
// repository whenever a booking changes; this screen just displays them.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/widgets.dart';
import '../../state/app_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = state.repo.notificationsFor(state.me.id);

    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.notifications_none,
        message: 'No notifications yet.',
      );
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: state.unreadCount == 0 ? null : state.markAllRead,
            child: const Text('Mark all as read'),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final n = items[index];
              return ListTile(
                leading: Icon(
                  n.read ? Icons.notifications_none : Icons.notifications_active,
                  color: n.read ? Colors.grey : Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  n.message,
                  style: TextStyle(
                    fontWeight: n.read ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(fmtDateTime(n.createdAt)),
              );
            },
          ),
        ),
      ],
    );
  }
}
