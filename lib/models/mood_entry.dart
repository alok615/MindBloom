class MoodEntry {
  final int? id;
  final DateTime date;
  final int mood; // 1=awful, 2=bad, 3=okay, 4=good, 5=great
  final String? note;

  MoodEntry({
    this.id,
    required this.date,
    required this.mood,
    this.note,
  });

  String get moodLabel {
    switch (mood) {
      case 1:
        return 'Awful';
      case 2:
        return 'Bad';
      case 3:
        return 'Okay';
      case 4:
        return 'Good';
      case 5:
        return 'Great';
      default:
        return 'Unknown';
    }
  }

  String get moodEmoji {
    switch (mood) {
      case 1:
        return '😞';
      case 2:
        return '😔';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '😄';
      default:
        return '❓';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mood': mood,
      'note': note,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      mood: map['mood'] as int,
      note: map['note'] as String?,
    );
  }

  MoodEntry copyWith({
    int? id,
    DateTime? date,
    int? mood,
    String? note,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      note: note ?? this.note,
    );
  }
}
