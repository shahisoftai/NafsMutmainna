import 'package:equatable/equatable.dart';

/// The Heart Graph - edges between attributes.
class AttributeLink extends Equatable {
  final int id;
  final int sourceAttributeId;
  final int targetAttributeId;
  final double weight;
  final String relationship; // Cure | Leads_To | Strengthens | Opposes

  const AttributeLink({
    required this.id,
    required this.sourceAttributeId,
    required this.targetAttributeId,
    required this.weight,
    required this.relationship,
  });

  @override
  List<Object?> get props => [id, sourceAttributeId, targetAttributeId, relationship];
}
