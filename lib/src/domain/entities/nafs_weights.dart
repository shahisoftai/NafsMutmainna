import 'package:equatable/equatable.dart';

/// 4-vector Nafs weight for an attribute.
class AttributeNafsWeights extends Equatable {
  final int attributeId;
  final double ammarah;
  final double lawwamah;
  final double mulhamah;
  final double mutmainnah;

  const AttributeNafsWeights({
    required this.attributeId,
    required this.ammarah,
    required this.lawwamah,
    required this.mulhamah,
    required this.mutmainnah,
  });

  @override
  List<Object?> get props => [attributeId, ammarah, lawwamah, mulhamah, mutmainnah];
}

class EmotionNafsWeights extends Equatable {
  final int emotionId;
  final double ammarah;
  final double lawwamah;
  final double mulhamah;
  final double mutmainnah;

  const EmotionNafsWeights({
    required this.emotionId,
    required this.ammarah,
    required this.lawwamah,
    required this.mulhamah,
    required this.mutmainnah,
  });

  @override
  List<Object?> get props => [emotionId, ammarah, lawwamah, mulhamah, mutmainnah];
}
