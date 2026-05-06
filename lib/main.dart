import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mind_bloom/providers/sleep_provider.dart';
import 'package:mind_bloom/providers/mood_provider.dart';
import 'package:mind_bloom/providers/nutrition_provider.dart';
import 'package:mind_bloom/providers/habit_provider.dart';
import 'package:mind_bloom/theme/app_theme.dart';
import 'package:mind_bloom/screens/shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MindBloomApp());
}

class MindBloomApp extends StatelessWidget {
  const MindBloomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SleepProvider()..loadEntries()),
        ChangeNotifierProvider(create: (_) => MoodProvider()..loadEntries()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()..loadData()),
        ChangeNotifierProvider(create: (_) => HabitProvider()..loadData()),
      ],
      child: MaterialApp(
        title: 'MindBloom',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppShell(),
      ),
    );
  }
}
