class WaterEntry {
  final int? id;
  final DateTime date;
  final int glasses;

  WaterEntry({
    this.id,
    required this.date,
    required this.glasses,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'glasses': glasses,
    };
  }

  factory WaterEntry.fromMap(Map<String, dynamic> map) {
    return WaterEntry(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      glasses: map['glasses'] as int,
    );
  }

  WaterEntry copyWith({
    int? id,
    DateTime? date,
    int? glasses,
  }) {
    return WaterEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      glasses: glasses ?? this.glasses,
    );
  }
}
