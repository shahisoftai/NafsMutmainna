import 'package:equatable/equatable.dart';

/// A single check-in row. HeartOS 5-screen loop entry point.
class Checkin extends Equatable {
  final int id;
  final DateTime date;
  final int emotionId;
  final int intensity;
  final String? notes;

  const Checkin({
    required this.id,
    required this.date,
    required this.emotionId,
    required this.intensity,
    this.notes,
  });

  Checkin copyWith({int? id, DateTime? date, int? emotionId, int? intensity, String? notes}) =>
      Checkin(
        id: id ?? this.id,
        date: date ?? this.date,
        emotionId: emotionId ?? this.emotionId,
        intensity: intensity ?? this.intensity,
        notes: notes ?? this.notes,
      );

  @override
  List<Object?> get props => [id, date, emotionId, intensity, notes];
}
