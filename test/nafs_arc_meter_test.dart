import 'package:flutter_test/flutter_test.dart';
import 'package:nafsmutmainna/src/domain/entities/vector4.dart';
import 'package:nafsmutmainna/src/presentation/widgets/specific/nafs_arc_meter.dart';
import 'package:nafsmutmainna/src/presentation/widgets/specific/nafs_station_reflections.dart';

void main() {
  group('NafsArcMeter.compositePosition', () {
    test('pure Ammarah → position 0.0', () {
      final v = const Vector4(1.0, 0, 0, 0);
      expect(NafsArcMeter.compositePosition(v), closeTo(0.0, 1e-9));
    });

    test('pure Mutmainnah → position 1.0', () {
      final v = const Vector4(0, 0, 0, 1.0);
      expect(NafsArcMeter.compositePosition(v), closeTo(1.0, 1e-9));
    });

    test('pure Lawwamah → position 1/3', () {
      final v = const Vector4(0, 1.0, 0, 0);
      expect(NafsArcMeter.compositePosition(v), closeTo(1.0 / 3.0, 1e-9));
    });

    test('pure Mulhamah → position 2/3', () {
      final v = const Vector4(0, 0, 1.0, 0);
      expect(NafsArcMeter.compositePosition(v), closeTo(2.0 / 3.0, 1e-9));
    });

    test('ammarahStartup default (0.65, 0.25, 0.07, 0.03) → ~0.16', () {
      // 0*0.65 + (1/3)*0.25 + (2/3)*0.07 + 1*0.03
      //   = 0 + 0.0833 + 0.0467 + 0.03 = 0.16
      // Normalised against sum=1.0 → 0.16
      final pos = NafsArcMeter.compositePosition(Vector4.ammarahStartup);
      expect(pos, closeTo(0.16, 1e-2));
    });

    test('result is always clamped to [0, 1]', () {
      // Even with degenerate inputs, the result must stay in range.
      final pos1 = NafsArcMeter.compositePosition(const Vector4(0, 0, 0, 0));
      final pos2 = NafsArcMeter.compositePosition(const Vector4(2, 0, 0, 0));
      expect(pos1, inInclusiveRange(0.0, 1.0));
      expect(pos2, inInclusiveRange(0.0, 1.0));
    });
  });

  group('reflectionFor', () {
    test('returns the Ammarah reflection for NafsType.ammarah', () {
      final r = reflectionFor(NafsType.ammarah);
      expect(r.label, 'Ammarah');
      expect(r.descriptor, 'The commanding soul');
      expect(r.reflection, isNotEmpty);
    });

    test('returns the Mutmainnah reflection for NafsType.mutmainnah', () {
      final r = reflectionFor(NafsType.mutmainnah);
      expect(r.label, 'Mutmainnah');
      expect(r.descriptor, 'The tranquil soul');
    });

    test('every NafsType has a reflection registered', () {
      for (final t in NafsType.values) {
        final r = reflectionFor(t);
        expect(r.label, isNotEmpty,
            reason: 'No reflection registered for NafsType.$t');
      }
    });
  });
}
