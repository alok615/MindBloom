import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mind_bloom/theme/app_theme.dart';
import 'package:mind_bloom/providers/habit_provider.dart';
import 'package:mind_bloom/models/habit.dart';
import 'package:mind_bloom/utils/date_utils.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildProgressCard(context)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text('Your Habits', style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          _buildHabitList(context),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Habits', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text('Build consistency', style: Theme.of(context).textTheme.bodyMedium),
        ])),
        GestureDetector(
          onTap: () => _showAddHabitSheet(context),
          child: Container(width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 22)),
        ),
      ]),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habit, _) {
        final completed = habit.todayCompletedCount;
        final total = habit.totalHabits;
        final progress = total > 0 ? completed / total : 0.0;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.habit, AppColors.habit.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.habit.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Today's Progress", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
              const SizedBox(height: 8),
              Row(children: [
                Text('$completed/$total', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Text('habits done', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
              ]),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(value: progress,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), minHeight: 8),
              ),
              if (progress >= 1.0 && total > 0) ...[
                const SizedBox(height: 8),
                Text('🎉 All habits completed!', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ]),
          ),
        );
      },
    );
  }

  Widget _buildHabitList(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProv, _) {
        if (habitProv.habits.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(padding: const EdgeInsets.all(40),
              child: Column(children: [
                Icon(Icons.check_circle_outlined, size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                Text('No habits yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                Text('Tap + to create a habit', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              ])));
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final habit = habitProv.habits[index];
            final isCompleted = habitProv.isCompletedToday(habit.id!);
            final streak = habitProv.getStreak(habit.id!);
            final weekStatus = habitProv.getWeekStatus(habit.id!);
            final days = AppDateUtils.lastNDays(7).reversed.toList();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Dismissible(
                key: ValueKey(habit.id), direction: DismissDirection.endToStart,
                background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(color: AppColors.moodAwful.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                  child: Icon(Icons.delete_rounded, color: AppColors.moodAwful)),
                onDismissed: (_) => context.read<HabitProvider>().deleteHabit(habit.id!),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: AppColors.softShadow),
                  child: Column(children: [
                    Row(children: [
                      GestureDetector(
                        onTap: () => habitProv.toggleToday(habit.id!),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: isCompleted ? AppColors.secondary : AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(12),
                            border: isCompleted ? null : Border.all(color: AppColors.divider, width: 1.5)),
                          child: Center(child: isCompleted
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
                            : Text(habit.emoji, style: const TextStyle(fontSize: 20))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(habit.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary, decoration: isCompleted ? TextDecoration.lineThrough : null)),
                        if (streak > 0) ...[const SizedBox(height: 2),
                          Text('🔥 $streak day streak', style: TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w500))],
                      ])),
                      Text(habit.emoji, style: TextStyle(fontSize: 24, color: isCompleted ? null : AppColors.textTertiary.withOpacity(0.3))),
                    ]),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (i) {
                        final done = weekStatus[i];
                        return Column(children: [
                          Text(AppDateUtils.formatDayOfWeek(days[i]), style: TextStyle(fontSize: 9, color: AppColors.textTertiary)),
                          const SizedBox(height: 4),
                          Container(width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: done ? AppColors.secondary.withOpacity(0.2) : AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(7)),
                            child: Center(child: done
                              ? Icon(Icons.check_rounded, size: 14, color: AppColors.secondary)
                              : Text('${days[i].day}', style: TextStyle(fontSize: 9, color: AppColors.textTertiary)))),
                        ]);
                      })),
                  ]),
                ),
              ),
            );
          }, childCount: habitProv.habits.length),
        );
      },
    );
  }

  void _showAddHabitSheet(BuildContext context) {
    final nameController = TextEditingController();
    String selectedEmoji = '💪';
    final emojis = ['💪', '📚', '🧘', '💊', '🏃', '🎨', '✍️', '🧹', '💤', '🥗', '🚿', '🎵'];

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        return Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('New Habit', style: Theme.of(ctx).textTheme.headlineMedium),
            const SizedBox(height: 16),
            TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Habit name...')),
            const SizedBox(height: 16),
            Text('Choose icon', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: emojis.map((e) => GestureDetector(
              onTap: () => setState(() => selectedEmoji = e),
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: selectedEmoji == e ? AppColors.secondary.withOpacity(0.15) : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: selectedEmoji == e ? Border.all(color: AppColors.secondary, width: 1.5) : null),
                child: Center(child: Text(e, style: const TextStyle(fontSize: 22)))),
            )).toList()),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty) return;
                context.read<HabitProvider>().addHabit(Habit(name: nameController.text, emoji: selectedEmoji, createdAt: DateTime.now()));
                Navigator.pop(ctx);
              },
              child: const Text('Create Habit'))),
          ]),
        );
      }),
    );
  }
}
