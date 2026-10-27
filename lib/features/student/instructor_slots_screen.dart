// OWNER: Person 3 (Student booking)
// Shows one instructor's open slots grouped by day.
// REUSED by Person 4 for rescheduling: when [rescheduleBookingId] is set,
// tapping a slot moves that booking instead of opening the booking form.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/widgets.dart';
import '../../data/booking_repository.dart';
import '../../models/app_user.dart';
import '../../models/slot.dart';
import '../../state/app_state.dart';
import 'book_consultation_screen.dart';

class InstructorSlotsScreen extends StatelessWidget {
  const InstructorSlotsScreen({
    super.key,
    required this.instructor,
    this.rescheduleBookingId,
  });

  final AppUser instructor;
  final String? rescheduleBookingId;

  bool get _isReschedule => rescheduleBookingId != null;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final slots = state.repo.slotsFor(instructor.id, onlyAvailable: true);

    final byDay = <DateTime, List<Slot>>{};
    for (final s in slots) {
      final key = DateTime(s.start.year, s.start.month, s.start.day);
      byDay.putIfAbsent(key, () => []).add(s);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isReschedule ? 'Pick a new slot' : instructor.name),
      ),
      body: slots.isEmpty
          ? const EmptyState(
              icon: Icons.event_busy,
              message: 'No open slots right now.',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  _isReschedule
                      ? 'Rescheduling with ${instructor.name}. Tap a new time.'
                      : '${instructor.name} - tap a time to book.',
                ),
                const SizedBox(height: 8),
                for (final entry in byDay.entries) ...[
                  SectionHeader(fmtDate(entry.key)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in entry.value)
                        ActionChip(
                          label: Text(fmtRange(s.start, s.end)),
                          onPressed: () => _onSlotTap(context, s),
                        ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }

  Future<void> _onSlotTap(BuildContext context, Slot slot) async {
    if (!_isReschedule) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => BookConsultationScreen(slot: slot)),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reschedule booking?'),
        content: Text(
          'Move to ${fmtDateTime(slot.start)}? The instructor will need to approve again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reschedule'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      context.read<AppState>().reschedule(rescheduleBookingId!, slot.id);
      nav.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Booking rescheduled. Waiting for approval.')),
      );
    } on SlotUnavailableException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}
