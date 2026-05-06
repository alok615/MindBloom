<<<<<<< HEAD
# MindBloom 🌱

A beautiful, minimalist life tracker app built with Flutter. Track your sleep, mood, nutrition, and habits — all fully offline.

## Features

- 🛌 **Sleep Tracking** — Log bedtime, wake time, and sleep quality with weekly charts
- 😊 **Mood Tracking** — Daily mood logging with emoji picker and 4-week calendar heatmap
- 🥗 **Nutrition** — Meal logging and animated water intake tracker with daily goals
- ✅ **Habits** — Custom habits with streak tracking and weekly status dots
- 📊 **Dashboard** — Beautiful home screen with today's summary at a glance

## Design

- Minimalist, nature-inspired color palette (forest greens, clean whites)
- Google Fonts Inter typography
- Smooth animations and transitions
- Card-based UI with soft shadows
- Swipe-to-delete on entries

## Tech Stack

- **Flutter** with Material 3
- **Provider** for state management
- **SQLite** (sqflite) for fully offline storage
- **fl_chart** for data visualization
- **Google Fonts** for premium typography

## Getting Started

### Prerequisites

1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install/windows)
2. Add Flutter to your system PATH

### Setup

```bash
# Navigate to the project directory
cd MindBloom

# Generate platform folders (android, ios, web)
flutter create --project-name mind_bloom --org com.mindbloom .

# Install dependencies
flutter pub get

# Run the app
flutter run
```

> **Note**: The `flutter create .` command will generate the native platform directories (android/, ios/, web/) without overwriting your existing `lib/` code.

### Run on specific platforms

```bash
# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios

# Web
flutter run -d chrome

# Windows
flutter run -d windows
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── theme/
│   └── app_theme.dart     # Colors, typography, component themes
├── models/
│   ├── sleep_entry.dart   # Sleep data model
│   ├── mood_entry.dart    # Mood data model
│   ├── meal_entry.dart    # Meal data model
│   ├── water_entry.dart   # Water intake model
│   └── habit.dart         # Habit + HabitLog models
├── database/
│   └── db_helper.dart     # SQLite database singleton
├── providers/
│   ├── sleep_provider.dart
│   ├── mood_provider.dart
│   ├── nutrition_provider.dart
│   └── habit_provider.dart
├── screens/
│   ├── shell.dart          # Bottom navigation shell
│   ├── home_screen.dart    # Dashboard
│   ├── sleep_screen.dart   # Sleep tracker
│   ├── mood_screen.dart    # Mood tracker
│   ├── nutrition_screen.dart # Nutrition + water
│   └── habits_screen.dart  # Habit tracker
├── widgets/
│   └── stat_card.dart      # Reusable stat card
└── utils/
    └── date_utils.dart     # Date formatting helpers
```

## License

This project is for personal use.
=======
# MindBloom
MindBloom – Mental Well-Being Tracker — Flutter, Firebase, Dart, AI/ML.
>>>>>>> c2a2eb805f2f0ab7416b1f5e3718b426fa9c6c12
