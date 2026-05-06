import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mind_bloom/theme/app_theme.dart';
import 'package:mind_bloom/providers/sleep_provider.dart';
import 'package:mind_bloom/providers/mood_provider.dart';
import 'package:mind_bloom/providers/nutrition_provider.dart';
import 'package:mind_bloom/providers/habit_provider.dart';
import 'package:mind_bloom/utils/date_utils.dart';
import 'package:mind_bloom/widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildMoodCard(context)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _buildQuickStats(context),
            ),
          ),
          SliverToBoxAdapter(child: _buildWeeklyOverview(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppDateUtils.greeting(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your Day at a Glance',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 4),
          Text(
            AppDateUtils.formatDate(DateTime.now()),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCard(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, _) {
        final todayMood = moodProvider.todayEntry;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todayMood != null
                            ? "Today you're feeling"
                            : "How are you feeling?",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        todayMood != null
                            ? todayMood.moodLabel
                            : 'Tap Mood to log',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      todayMood?.moodEmoji ?? '🌱',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Today',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Consumer<SleepProvider>(
                builder: (context, sleep, _) {
                  final entry = sleep.todayEntry;
                  return StatCard(
                    icon: Icons.bedtime_rounded,
                    iconColor: AppColors.sleep,
                    iconBgColor: AppColors.sleepLight,
                    title: 'Sleep',
                    value: entry != null ? entry.durationFormatted : '--',
                    subtitle: entry != null
                        ? '${_qualityLabel(entry.quality)} quality'
                        : 'Not logged',
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Consumer<NutritionProvider>(
                builder: (context, nutrition, _) {
                  return StatCard(
                    icon: Icons.water_drop_rounded,
                    iconColor: AppColors.water,
                    iconBgColor: AppColors.waterLight,
                    title: 'Water',
                    value:
                        '${nutrition.todayWaterGlasses}/${NutritionProvider.waterGoal}',
                    subtitle: 'glasses today',
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Consumer<NutritionProvider>(
                builder: (context, nutrition, _) {
                  return StatCard(
                    icon: Icons.restaurant_rounded,
                    iconColor: AppColors.nutrition,
                    iconBgColor: AppColors.nutritionLight,
                    title: 'Meals',
                    value: '${nutrition.todayMealCount}',
                    subtitle: nutrition.todayCalories > 0
                        ? '${nutrition.todayCalories} cal'
                        : 'logged today',
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Consumer<HabitProvider>(
                builder: (context, habit, _) {
                  return StatCard(
                    icon: Icons.check_circle_rounded,
                    iconColor: AppColors.habit,
                    iconBgColor: AppColors.habitLight,
                    title: 'Habits',
                    value: '${habit.todayCompletedCount}/${habit.totalHabits}',
                    subtitle: 'completed',
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyOverview(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.softShadow,
            ),
            child: Consumer<MoodProvider>(
              builder: (context, moodProvider, _) {
                final days = AppDateUtils.lastNDays(7).reversed.toList();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: days.map((day) {
                    final mood = moodProvider.getMoodForDate(day);
                    final isToday =
                        AppDateUtils.isSameDay(day, DateTime.now());
                    return Column(
                      children: [
                        Text(
                          AppDateUtils.formatDayOfWeek(day),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isToday ? FontWeight.w600 : FontWeight.w400,
                            color: isToday
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: mood != null
                                ? _moodColor(mood.mood).withOpacity(0.15)
                                : isToday
                                    ? AppColors.accentPale
                                    : AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(10),
                            border: isToday
                                ? Border.all(
                                    color: AppColors.secondary, width: 1.5)
                                : null,
                          ),
                          child: Center(
                            child: mood != null
                                ? Text(
                                    mood.moodEmoji,
                                    style: const TextStyle(fontSize: 18),
                                  )
                                : Icon(
                                    Icons.remove,
                                    size: 14,
                                    color: AppColors.textTertiary,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isToday ? FontWeight.w600 : FontWeight.w400,
                            color: isToday
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _qualityLabel(int quality) {
    switch (quality) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Okay';
      case 4:
        return 'Good';
      case 5:
        return 'Great';
      default:
        return '';
    }
  }

  Color _moodColor(int mood) {
    switch (mood) {
      case 1:
        return AppColors.moodAwful;
      case 2:
        return AppColors.moodBad;
      case 3:
        return AppColors.moodOkay;
      case 4:
        return AppColors.moodGood;
      case 5:
        return AppColors.moodGreat;
      default:
        return AppColors.textTertiary;
    }
  }
}
