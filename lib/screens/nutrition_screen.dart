import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mind_bloom/theme/app_theme.dart';
import 'package:mind_bloom/providers/nutrition_provider.dart';
import 'package:mind_bloom/models/meal_entry.dart';
import 'package:mind_bloom/utils/date_utils.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildWaterTracker(context)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(children: [
                Expanded(child: Text("Today's Meals", style: Theme.of(context).textTheme.titleLarge)),
                GestureDetector(
                  onTap: () => _showAddMealSheet(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ]),
            ),
          ),
          _buildMealList(context),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Nutrition', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 4),
        Text('Fuel your day', style: Theme.of(context).textTheme.bodyMedium),
      ]),
    );
  }

  Widget _buildWaterTracker(BuildContext context) {
    return Consumer<NutritionProvider>(
      builder: (context, nutrition, _) {
        final glasses = nutrition.todayWaterGlasses;
        final goal = NutritionProvider.waterGoal;
        final progress = nutrition.waterProgress.clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.water, AppColors.water.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.water.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Column(children: [
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Water Intake', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('$glasses', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700)),
                    Padding(padding: const EdgeInsets.only(bottom: 6),
                      child: Text(' / $goal glasses', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14))),
                  ]),
                ]),
                const Spacer(),
                Column(children: [
                  GestureDetector(
                    onTap: () => nutrition.addWaterGlass(),
                    child: Container(width: 44, height: 44,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 24)),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => nutrition.removeWaterGlass(),
                    child: Container(width: 44, height: 44,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.remove_rounded, color: Colors.white, size: 24)),
                  ),
                ]),
              ]),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(progress >= 1.0 ? '🎉 Goal reached!' : '${(progress * 100).toInt()}% of daily goal',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                Row(children: List.generate(goal, (i) => Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: Icon(Icons.water_drop_rounded, size: 14,
                    color: i < glasses ? Colors.white : Colors.white.withOpacity(0.3)),
                ))),
              ]),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildMealList(BuildContext context) {
    return Consumer<NutritionProvider>(
      builder: (context, nutrition, _) {
        final todayMeals = nutrition.todayMeals;
        if (todayMeals.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(padding: const EdgeInsets.all(40),
              child: Column(children: [
                Icon(Icons.restaurant_outlined, size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                Text('No meals logged today', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                Text('Tap + to add a meal', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              ])));
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final meal = todayMeals[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Dismissible(
                key: ValueKey(meal.id), direction: DismissDirection.endToStart,
                background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(color: AppColors.moodAwful.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                  child: Icon(Icons.delete_rounded, color: AppColors.moodAwful)),
                onDismissed: (_) => context.read<NutritionProvider>().deleteMeal(meal.id!),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), boxShadow: AppColors.softShadow),
                  child: Row(children: [
                    Container(width: 44, height: 44,
                      decoration: BoxDecoration(color: AppColors.nutritionLight, borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text(meal.mealTypeIcon, style: const TextStyle(fontSize: 22)))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(meal.mealTypeLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(meal.description, style: TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ])),
                    if (meal.calories != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.nutritionLight, borderRadius: BorderRadius.circular(8)),
                        child: Text('${meal.calories} cal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.nutrition)),
                      ),
                  ]),
                ),
              ),
            );
          }, childCount: todayMeals.length),
        );
      },
    );
  }

  void _showAddMealSheet(BuildContext context) {
    String mealType = 'breakfast';
    final descController = TextEditingController();
    final calController = TextEditingController();
    final types = ['breakfast', 'lunch', 'dinner', 'snack'];
    final typeIcons = ['🌅', '☀️', '🌙', '🍎'];

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        return Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Add Meal', style: Theme.of(ctx).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Row(children: List.generate(4, (i) => Expanded(
              child: GestureDetector(
                onTap: () => setState(() => mealType = types[i]),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: mealType == types[i] ? AppColors.secondary.withOpacity(0.15) : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                    border: mealType == types[i] ? Border.all(color: AppColors.secondary, width: 1.5) : null),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(typeIcons[i], style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 2),
                    Text(types[i][0].toUpperCase() + types[i].substring(1), style: TextStyle(fontSize: 10,
                      fontWeight: mealType == types[i] ? FontWeight.w600 : FontWeight.w400,
                      color: mealType == types[i] ? AppColors.secondary : AppColors.textTertiary)),
                  ]),
                ),
              ),
            ))),
            const SizedBox(height: 16),
            TextField(controller: descController, decoration: const InputDecoration(hintText: 'What did you eat?')),
            const SizedBox(height: 12),
            TextField(controller: calController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Calories (optional)')),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () {
                if (descController.text.isEmpty) return;
                final meal = MealEntry(
                  date: DateTime.now(), mealType: mealType, description: descController.text,
                  calories: calController.text.isNotEmpty ? int.tryParse(calController.text) : null,
                );
                context.read<NutritionProvider>().addMeal(meal);
                Navigator.pop(ctx);
              },
              child: const Text('Save'))),
          ]),
        );
      }),
    );
  }
}
