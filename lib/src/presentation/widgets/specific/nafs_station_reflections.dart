import '../../../domain/entities/vector4.dart';

/// Pure data: short inspirational descriptors for the four Nafs stations.
///
/// Used by the new Nafs arc meter and the journey card. No Flutter
/// dependencies — safe to import from any layer and to test in isolation.
class NafsStationReflection {
  final String label;
  final String descriptor;
  final String reflection;

  const NafsStationReflection({
    required this.label,
    required this.descriptor,
    required this.reflection,
  });
}

const Map<NafsType, NafsStationReflection> kNafsStationReflections = {
  NafsType.ammarah: NafsStationReflection(
    label: 'Ammarah',
    descriptor: 'The commanding soul',
    reflection: 'Heedlessness. Start with one small dhikr.',
  ),
  NafsType.lawwamah: NafsStationReflection(
    label: 'Lawwamah',
    descriptor: 'The reproaching soul',
    reflection: 'Conscience is alive. Keep going.',
  ),
  NafsType.mulhamah: NafsStationReflection(
    label: 'Mulhamah',
    descriptor: 'The inspired soul',
    reflection: 'Walking the inspired path.',
  ),
  NafsType.mutmainnah: NafsStationReflection(
    label: 'Mutmainnah',
    descriptor: 'The tranquil soul',
    reflection: 'Inner peace and trust in Allah.',
  ),
};

/// Returns the reflection for [type]. Falls back to a generic label if a
/// future enum value is added but not yet reflected here.
NafsStationReflection reflectionFor(NafsType type) {
  return kNafsStationReflections[type] ??
      const NafsStationReflection(
        label: 'Unknown',
        descriptor: '—',
        reflection: 'Continue on your journey.',
      );
}
