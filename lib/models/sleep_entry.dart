class SleepEntry {
  final int? id;
  final DateTime date;
  final DateTime bedTime;
  final DateTime wakeTime;
  final int quality; // 1-5

  SleepEntry({
    this.id,
    required this.date,
    required this.bedTime,
    required this.wakeTime,
    required this.quality,
  });

  Duration get duration => wakeTime.difference(bedTime);

  String get durationFormatted {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'bed_time': bedTime.toIso8601String(),
      'wake_time': wakeTime.toIso8601String(),
      'quality': quality,
    };
  }

  factory SleepEntry.fromMap(Map<String, dynamic> map) {
    return SleepEntry(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      bedTime: DateTime.parse(map['bed_time'] as String),
      wakeTime: DateTime.parse(map['wake_time'] as String),
      quality: map['quality'] as int,
    );
  }

  SleepEntry copyWith({
    int? id,
    DateTime? date,
    DateTime? bedTime,
    DateTime? wakeTime,
    int? quality,
  }) {
    return SleepEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      bedTime: bedTime ?? this.bedTime,
      wakeTime: wakeTime ?? this.wakeTime,
      quality: quality ?? this.quality,
    );
  }
}
