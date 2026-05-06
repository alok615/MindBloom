class MealEntry {
  final int? id;
  final DateTime date;
  final String mealType; // breakfast, lunch, dinner, snack
  final String description;
  final int? calories;

  MealEntry({
    this.id,
    required this.date,
    required this.mealType,
    required this.description,
    this.calories,
  });

  String get mealTypeIcon {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return '🌅';
      case 'lunch':
        return '☀️';
      case 'dinner':
        return '🌙';
      case 'snack':
        return '🍎';
      default:
        return '🍽️';
    }
  }

  String get mealTypeLabel {
    return mealType[0].toUpperCase() + mealType.substring(1);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'meal_type': mealType,
      'description': description,
      'calories': calories,
    };
  }

  factory MealEntry.fromMap(Map<String, dynamic> map) {
    return MealEntry(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      mealType: map['meal_type'] as String,
      description: map['description'] as String,
      calories: map['calories'] as int?,
    );
  }

  MealEntry copyWith({
    int? id,
    DateTime? date,
    String? mealType,
    String? description,
    int? calories,
  }) {
    return MealEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      description: description ?? this.description,
      calories: calories ?? this.calories,
    );
  }
}
