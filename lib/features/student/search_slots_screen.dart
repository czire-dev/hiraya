// OWNER: Person 3 (Student booking)
// Use case: "Search faculty slots". Search a professor, then tap to see slots.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets.dart';
import '../../state/app_state.dart';
import 'instructor_slots_screen.dart';

class SearchSlotsScreen extends StatefulWidget {
  const SearchSlotsScreen({super.key});

  @override
  State<SearchSlotsScreen> createState() => _SearchSlotsScreenState();
}

class _SearchSlotsScreenState extends State<SearchSlotsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final instructors = state.repo.instructors
        .where((i) => i.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Hi, ${state.me.name.split(' ').first}!',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text('Search a faculty member to see their open consultation slots.'),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search faculty',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 12),
        if (instructors.isEmpty)
          const SizedBox(
            height: 240,
            child: EmptyState(
              icon: Icons.person_search,
              message: 'No faculty found.',
            ),
          )
        else
          ...instructors.map((i) {
            final open = state.repo.slotsFor(i.id, onlyAvailable: true).length;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text(i.initials)),
                title: Text(i.name),
                subtitle: Text('${i.department} · $open open slots'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => InstructorSlotsScreen(instructor: i),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
