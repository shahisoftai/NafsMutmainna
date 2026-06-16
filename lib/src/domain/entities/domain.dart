import 'package:equatable/equatable.dart';

/// A macro-domain of the heart. 10 rows.
class Domain extends Equatable {
  final int id;
  final String name;
  final String arabicName;
  final String description;

  const Domain({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.description,
  });

  @override
  List<Object?> get props => [id, name];
}
