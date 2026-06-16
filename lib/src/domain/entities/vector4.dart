import 'package:equatable/equatable.dart';

/// 4-vector for Nafs scoring.
/// Maps to the four stations of the soul (Ammarah, Lawwamah, Mulhamah, Mutmainnah).
class Vector4 extends Equatable {
  final double ammarah;
  final double lawwamah;
  final double mulhamah;
  final double mutmainnah;

  const Vector4(this.ammarah, this.lawwamah, this.mulhamah, this.mutmainnah);

  /// Equal-weighted neutral baseline (used by tests / when no data).
  static const Vector4 neutral = Vector4(0.25, 0.25, 0.25, 0.25);

  /// Lawwamah baseline - the default starting state for a new user.
  /// 10/60/20/10.
  static const Vector4 lawwamahBaseline = Vector4(0.10, 0.60, 0.20, 0.10);

  static const List<NafsType> _order = NafsType.values;

  double get ammarahOrZero => ammarah.isFinite ? ammarah : 0;
  double get lawwamahOrZero => lawwamah.isFinite ? lawwamah : 0;
  double get mulhamahOrZero => mulhamah.isFinite ? mulhamah : 0;
  double get mutmainnahOrZero => mutmainnah.isFinite ? mutmainnah : 0;

  double get sum => ammarah + lawwamah + mulhamah + mutmainnah;

  Vector4 operator +(Vector4 o) => Vector4(
        ammarah + o.ammarah,
        lawwamah + o.lawwamah,
        mulhamah + o.mulhamah,
        mutmainnah + o.mutmainnah,
      );

  Vector4 operator *(double s) => Vector4(
        ammarah * s,
        lawwamah * s,
        mulhamah * s,
        mutmainnah * s,
      );

  /// Normalises the vector to sum to 1.0. If sum is 0, returns neutral.
  Vector4 get normalised {
    final s = sum;
    if (s == 0 || !s.isFinite) return neutral;
    return Vector4(ammarah / s, lawwamah / s, mulhamah / s, mutmainnah / s);
  }

  /// The dominant Nafs station (highest value wins ties by enum index).
  NafsType get dominant {
    final values = [ammarah, lawwamah, mulhamah, mutmainnah];
    var maxIdx = 0;
    for (var i = 1; i < values.length; i++) {
      if (values[i] > values[maxIdx]) maxIdx = i;
    }
    return _order[maxIdx];
  }

  /// Heart Health Score: 0-100. Derived from Mutmainnah (dominant) and Mulhamah.
  int get heartHealthScore =>
      ((mutmainnah * 0.7 + mulhamah * 0.3) * 100).round().clamp(0, 100);

  Map<NafsType, double> toMap() => {
        NafsType.ammarah: ammarah,
        NafsType.lawwamah: lawwamah,
        NafsType.mulhamah: mulhamah,
        NafsType.mutmainnah: mutmainnah,
      };

  @override
  List<Object?> get props => [ammarah, lawwamah, mulhamah, mutmainnah];
}

/// The four canonical stations of the soul.
enum NafsType { ammarah, lawwamah, mulhamah, mutmainnah }

extension NafsTypeX on NafsType {
  String get label => switch (this) {
        NafsType.ammarah => 'Ammarah',
        NafsType.lawwamah => 'Lawwamah',
        NafsType.mulhamah => 'Mulhamah',
        NafsType.mutmainnah => 'Mutmainnah',
      };

  String get arabic => switch (this) {
        NafsType.ammarah => 'الأمّارة',
        NafsType.lawwamah => 'اللوّامة',
        NafsType.mulhamah => 'الملهمة',
        NafsType.mutmainnah => 'المطمئنة',
      };

  String get labelName => switch (this) {
        NafsType.ammarah => 'Ammarah',
        NafsType.lawwamah => 'Lawwamah',
        NafsType.mulhamah => 'Mulhamah',
        NafsType.mutmainnah => 'Mutmainnah',
      };
}
