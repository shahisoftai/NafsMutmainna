import 'package:equatable/equatable.dart';
import 'vector4.dart';

/// A row from the nafs_states table.
class NafsState extends Equatable {
  final int id;
  final int nafsId;
  final String name;
  final String arabicName;
  final String description;

  const NafsState({
    required this.id,
    required this.nafsId,
    required this.name,
    required this.arabicName,
    required this.description,
  });

  NafsType get type {
    switch (name) {
      case 'Ammarah':
        return NafsType.ammarah;
      case 'Lawwamah':
        return NafsType.lawwamah;
      case 'Mulhamah':
        return NafsType.mulhamah;
      case 'Mutmainnah':
        return NafsType.mutmainnah;
    }
    return NafsType.lawwamah;
  }

  @override
  List<Object?> get props => [id, name];
}
