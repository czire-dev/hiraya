// OWNER: Person 3 (Student booking)
// Use cases: "Book consultation" (+ optional "Upload topic & files" extension).
// The repository checks availability and locks the slot; if two students race
// for the same slot, the second gets a SlotUnavailableException.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../data/booking_repository.dart';
import '../../models/slot.dart';
import '../../state/app_state.dart';

class BookConsultationScreen extends StatefulWidget {
  const BookConsultationScreen({super.key, required this.slot});

  final Slot slot;

  @override
  State<BookConsultationScreen> createState() => _BookConsultationScreenState();
}

class _BookConsultationScreenState extends State<BookConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicCtrl = TextEditingController();
  String? _fileName;

  @override
  void dispose() {
    _topicCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      context
          .read<AppState>()
          .book(widget.slot, _topicCtrl.text.trim(), fileName: _fileName);
      nav.popUntil((route) => route.isFirst);
      messenger.showSnackBar(
        const SnackBar(content: Text('Request sent! Check the Bookings tab.')),
      );
    } on SlotUnavailableException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      nav.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final instructor = state.repo.userById(widget.slot.instructorId);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Book consultation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(instructor?.name ?? 'Instructor'),
              subtitle: Text(
                '${fmtDate(widget.slot.start)}\n${fmtRange(widget.slot.start, widget.slot.end)}',
              ),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _topicCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Consultation topic',
                hintText: 'e.g. Grade concern, missed assignment, absence excuse',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter a topic'
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          if (_fileName == null)
            OutlinedButton.icon(
              // TODO(Person 3): replace with a real picker (file_picker package)
              onPressed: () => setState(() => _fileName = 'excuse_letter.pdf'),
              icon: const Icon(Icons.attach_file),
              label: const Text('Attach file (optional)'),
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: InputChip(
                avatar: const Icon(Icons.description, size: 18),
                label: Text(_fileName!),
                onDeleted: () => setState(() => _fileName = null),
              ),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submit,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Confirm booking'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your request goes to the instructor for approval.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
