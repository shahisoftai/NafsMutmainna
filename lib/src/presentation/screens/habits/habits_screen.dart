import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/habit.dart';
import '../../../infrastructure/di/providers.dart';
import '../../navigation/app_router.dart';
import '../../theme/colors.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});
  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  List<Habit> _habits = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final h = await ref.read(habitRepositoryProvider).allHabits();
    if (!mounted) return;
    setState(() {
      _habits = h;
      _loading = false;
    });
  }

  Future<void> _add(Habit h) async {
    await ref.read(habitRepositoryProvider).insertHabit(h);
    await _load();
  }

  Future<void> _delete(int id) async {
    await ref.read(habitRepositoryProvider).deleteHabit(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom + 16),
              children: [
                if (_habits.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('No habits yet — add one to start tracking.',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                for (final h in _habits)
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.surfaceVariant),
                    ),
                    child: ListTile(
                      title: Text(h.name),
                      subtitle: Text(h.category),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () => _delete(h.id),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _showAdd,
                  icon: const Icon(Icons.add),
                  label: const Text('Add habit'),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                  child: OutlinedButton(
                    onPressed: () => context.go(AppRouter.home),
                    child: const Text('Back to Home'),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _showAdd() async {
    final nameCtrl = TextEditingController();
    String category = 'Prayer';
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add habit'),
        content: StatefulBuilder(
          builder: (ctx, setSt) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: category,
                items: const [
                  DropdownMenuItem(value: 'Prayer', child: Text('Prayer')),
                  DropdownMenuItem(value: 'Quran', child: Text('Quran')),
                  DropdownMenuItem(value: 'Dhikr', child: Text('Dhikr')),
                  DropdownMenuItem(value: 'Charity', child: Text('Charity')),
                  DropdownMenuItem(value: 'Exercise', child: Text('Exercise')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (v) => setSt(() => category = v ?? 'Other'),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isNotEmpty) {
                await _add(Habit(id: 0, name: nameCtrl.text.trim(), category: category));
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
