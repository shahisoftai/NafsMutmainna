import 'package:equatable/equatable.dart';

class DomainAttributeLink extends Equatable {
  final int id;
  final int domainId;
  final int attributeId;
  final double weight;

  const DomainAttributeLink({
    required this.id,
    required this.domainId,
    required this.attributeId,
    required this.weight,
  });

  @override
  List<Object?> get props => [id, domainId, attributeId];
}

class DomainEmotionLink extends Equatable {
  final int id;
  final int domainId;
  final int emotionId;
  final double weight;

  const DomainEmotionLink({
    required this.id,
    required this.domainId,
    required this.emotionId,
    required this.weight,
  });

  @override
  List<Object?> get props => [id, domainId, emotionId];
}
