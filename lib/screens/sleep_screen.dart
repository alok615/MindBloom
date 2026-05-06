import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mind_bloom/theme/app_theme.dart';
import 'package:mind_bloom/providers/sleep_provider.dart';
import 'package:mind_bloom/models/sleep_entry.dart';
import 'package:mind_bloom/utils/date_utils.dart';

class SleepScreen extends StatelessWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildStats(context)),
          SliverToBoxAdapter(child: _buildSleepChart(context)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text('Recent Entries', style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          _buildEntryList(context),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sleep', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 4),
                Text('Track your rest', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showAddSleepSheet(context),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Consumer<SleepProvider>(
      builder: (context, sleep, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Expanded(child: _miniStat(Icons.schedule_rounded, 'Avg Duration',
                  sleep.entries.isEmpty ? '--' : '${sleep.averageSleepHours.toStringAsFixed(1)}h', AppColors.sleep)),
              const SizedBox(width: 12),
              Expanded(child: _miniStat(Icons.star_rounded, 'Avg Quality',
                  sleep.entries.isEmpty ? '--' : '${sleep.averageQuality.toStringAsFixed(1)}/5', AppColors.secondary)),
            ],
          ),
        );
      },
    );
  }

  Widget _miniStat(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), boxShadow: AppColors.softShadow),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text(label, style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
        ]),
      ]),
    );
  }

  Widget _buildSleepChart(BuildContext context) {
    return Consumer<SleepProvider>(
      builder: (context, sleep, _) {
        final weekEntries = sleep.thisWeekEntries;
        final days = AppDateUtils.lastNDays(7).reversed.toList();
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: AppColors.softShadow),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('This Week', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: days.map((day) {
                  final entry = weekEntries.where((e) => AppDateUtils.isSameDay(e.date, day)).toList();
                  final hours = entry.isNotEmpty ? entry.first.duration.inMinutes / 60 : 0.0;
                  final barHeight = (hours / 12.0 * 100).clamp(0.0, 100.0);
                  final isToday = AppDateUtils.isSameDay(day, DateTime.now());
                  return Expanded(
                    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                        if (hours > 0) Text('${hours.toStringAsFixed(1)}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.sleep)),
                        const SizedBox(height: 4),
                        AnimatedContainer(duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic,
                          height: barHeight, decoration: BoxDecoration(
                            color: hours > 0 ? (isToday ? AppColors.sleep : AppColors.sleep.withOpacity(0.5)) : AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(6))),
                        const SizedBox(height: 6),
                        Text(AppDateUtils.formatDayOfWeek(day), style: TextStyle(fontSize: 10,
                          fontWeight: isToday ? FontWeight.w600 : FontWeight.w400, color: isToday ? AppColors.primary : AppColors.textTertiary)),
                      ])));
                }).toList()),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildEntryList(BuildContext context) {
    return Consumer<SleepProvider>(
      builder: (context, sleep, _) {
        if (sleep.entries.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(padding: const EdgeInsets.all(40),
              child: Column(children: [
                Icon(Icons.bedtime_outlined, size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                Text('No sleep entries yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                Text('Tap + to log your sleep', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              ])));
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final entry = sleep.entries[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Dismissible(
                key: ValueKey(entry.id), direction: DismissDirection.endToStart,
                background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(color: AppColors.moodAwful.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                  child: Icon(Icons.delete_rounded, color: AppColors.moodAwful)),
                onDismissed: (_) => context.read<SleepProvider>().deleteEntry(entry.id!),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), boxShadow: AppColors.softShadow),
                  child: Row(children: [
                    Container(width: 44, height: 44,
                      decoration: BoxDecoration(color: AppColors.sleepLight, borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.nights_stay_rounded, color: AppColors.sleep, size: 22)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(AppDateUtils.formatDate(entry.date), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text('${AppDateUtils.formatTime(entry.bedTime)} → ${AppDateUtils.formatTime(entry.wakeTime)}',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(entry.durationFormatted, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.sleep)),
                      Row(children: List.generate(5, (i) => Icon(Icons.star_rounded, size: 12,
                        color: i < entry.quality ? AppColors.nutrition : AppColors.divider))),
                    ]),
                  ]),
                ),
              ),
            );
          }, childCount: sleep.entries.length.clamp(0, 10)),
        );
      },
    );
  }

  void _showAddSleepSheet(BuildContext context) {
    TimeOfDay bedTime = const TimeOfDay(hour: 22, minute: 0);
    TimeOfDay wakeTime = const TimeOfDay(hour: 6, minute: 30);
    int quality = 3;
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        return Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Log Sleep', style: Theme.of(ctx).textTheme.headlineMedium),
            const SizedBox(height: 20),
            _timePicker(ctx, 'Bedtime', Icons.bedtime_rounded, bedTime, () async {
              final p = await showTimePicker(context: ctx, initialTime: bedTime);
              if (p != null) setState(() => bedTime = p);
            }),
            const SizedBox(height: 12),
            _timePicker(ctx, 'Wake up', Icons.wb_sunny_rounded, wakeTime, () async {
              final p = await showTimePicker(context: ctx, initialTime: wakeTime);
              if (p != null) setState(() => wakeTime = p);
            }),
            const SizedBox(height: 20),
            Text('Sleep Quality', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Row(children: List.generate(5, (i) => Expanded(child: GestureDetector(
              onTap: () => setState(() => quality = i + 1),
              child: Container(margin: const EdgeInsets.symmetric(horizontal: 3), padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: i < quality ? AppColors.secondary.withOpacity(0.15) : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: i < quality ? Border.all(color: AppColors.secondary, width: 1.5) : null),
                child: Center(child: Icon(Icons.star_rounded, size: 22, color: i < quality ? AppColors.secondary : AppColors.textTertiary))))))),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () {
                final now = DateTime.now();
                final bed = DateTime(now.year, now.month, now.day, bedTime.hour, bedTime.minute);
                var wake = DateTime(now.year, now.month, now.day, wakeTime.hour, wakeTime.minute);
                if (wake.isBefore(bed)) wake = wake.add(const Duration(days: 1));
                context.read<SleepProvider>().addEntry(SleepEntry(date: AppDateUtils.today(), bedTime: bed, wakeTime: wake, quality: quality));
                Navigator.pop(ctx);
              },
              child: const Text('Save'))),
          ]),
        );
      }),
    );
  }

  Widget _timePicker(BuildContext ctx, String label, IconData icon, TimeOfDay time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, color: AppColors.sleep, size: 20), const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)), const Spacer(),
          Text(time.format(ctx), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(width: 4), Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
        ]),
      ),
    );
  }
}
