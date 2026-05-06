import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mind_bloom/theme/app_theme.dart';
import 'package:mind_bloom/providers/mood_provider.dart';
import 'package:mind_bloom/models/mood_entry.dart';
import 'package:mind_bloom/utils/date_utils.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  int? _selectedMood;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildMoodPicker()),
          SliverToBoxAdapter(child: _buildNoteField()),
          SliverToBoxAdapter(child: _buildSaveButton()),
          SliverToBoxAdapter(child: _buildCalendar()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text('Recent', style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          _buildRecentList(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Mood', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 4),
        Text('How are you feeling today?', style: Theme.of(context).textTheme.bodyMedium),
      ]),
    );
  }

  Widget _buildMoodPicker() {
    final moods = [
      {'emoji': '😞', 'label': 'Awful', 'color': AppColors.moodAwful},
      {'emoji': '😔', 'label': 'Bad', 'color': AppColors.moodBad},
      {'emoji': '😐', 'label': 'Okay', 'color': AppColors.moodOkay},
      {'emoji': '😊', 'label': 'Good', 'color': AppColors.moodGood},
      {'emoji': '😄', 'label': 'Great', 'color': AppColors.moodGreat},
    ];

    return Consumer<MoodProvider>(
      builder: (context, moodProv, _) {
        final todayMood = moodProv.todayEntry;
        final current = _selectedMood ?? todayMood?.mood;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppColors.softShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (i) {
                final mood = moods[i];
                final isSelected = current == (i + 1);
                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = i + 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected ? (mood['color'] as Color).withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected ? Border.all(color: mood['color'] as Color, width: 2) : null,
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(mood['emoji'] as String, style: TextStyle(fontSize: isSelected ? 32 : 26)),
                      const SizedBox(height: 4),
                      Text(mood['label'] as String, style: TextStyle(fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? mood['color'] as Color : AppColors.textTertiary)),
                    ]),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoteField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: TextField(
        controller: _noteController,
        maxLines: 2,
        decoration: const InputDecoration(hintText: 'Add a note (optional)...'),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _selectedMood == null ? null : () {
            final entry = MoodEntry(
              date: DateTime.now(),
              mood: _selectedMood!,
              note: _noteController.text.isEmpty ? null : _noteController.text,
            );
            context.read<MoodProvider>().addEntry(entry);
            _noteController.clear();
            setState(() => _selectedMood = null);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Mood saved!'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
          child: const Text('Save Mood'),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Consumer<MoodProvider>(
      builder: (context, moodProv, _) {
        final days = AppDateUtils.lastNDays(28);
        final weeks = <List<DateTime>>[];
        for (int i = 0; i < days.length; i += 7) {
          weeks.add(days.sublist(i, (i + 7).clamp(0, days.length)).reversed.toList());
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: AppColors.softShadow),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Last 4 Weeks', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              ...weeks.map((week) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: week.map((day) {
                    final mood = moodProv.getMoodForDate(day);
                    return Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: mood != null ? _moodColor(mood.mood).withOpacity(0.2) : AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(8)),
                      child: Center(child: mood != null
                        ? Text(mood.moodEmoji, style: const TextStyle(fontSize: 16))
                        : Text('${day.day}', style: TextStyle(fontSize: 10, color: AppColors.textTertiary))),
                    );
                  }).toList()),
              )),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildRecentList() {
    return Consumer<MoodProvider>(
      builder: (context, moodProv, _) {
        if (moodProv.entries.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(padding: const EdgeInsets.all(40),
              child: Column(children: [
                Icon(Icons.emoji_emotions_outlined, size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                Text('No mood entries yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              ])));
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final entry = moodProv.entries[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), boxShadow: AppColors.softShadow),
                child: Row(children: [
                  Container(width: 40, height: 40,
                    decoration: BoxDecoration(color: _moodColor(entry.mood).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(entry.moodEmoji, style: const TextStyle(fontSize: 20)))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(AppDateUtils.formatDate(entry.date), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    if (entry.note != null) ...[const SizedBox(height: 2),
                      Text(entry.note!, style: TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)],
                  ])),
                  Text(entry.moodLabel, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _moodColor(entry.mood))),
                ]),
              ),
            );
          }, childCount: moodProv.entries.length.clamp(0, 10)),
        );
      },
    );
  }

  Color _moodColor(int mood) {
    switch (mood) {
      case 1: return AppColors.moodAwful;
      case 2: return AppColors.moodBad;
      case 3: return AppColors.moodOkay;
      case 4: return AppColors.moodGood;
      case 5: return AppColors.moodGreat;
      default: return AppColors.textTertiary;
    }
  }
}
