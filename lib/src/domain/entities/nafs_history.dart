import 'package:equatable/equatable.dart';
import 'vector4.dart';

/// Daily snapshot of the user's Nafs. Sum of 4 cols = 1.0.
class NafsHistory extends Equatable {
  final int id;
  final DateTime date;
  final double ammarah;
  final double lawwamah;
  final double mulhamah;
  final double mutmainnah;

  const NafsHistory({
    required this.id,
    required this.date,
    required this.ammarah,
    required this.lawwamah,
    required this.mulhamah,
    required this.mutmainnah,
  });

  Vector4 get vector => Vector4(ammarah, lawwamah, mulhamah, mutmainnah);

  @override
  List<Object?> get props => [id, date, ammarah, lawwamah, mulhamah, mutmainnah];
}
