import 'package:flutter/material.dart';

import '../../../domain/entities/vector4.dart';
import '../../theme/colors.dart';

/// A dialog explaining the origins of all four Nafs stations
/// with citations for scholarly transparency.
class NafsStationOriginDialog extends StatelessWidget {
  const NafsStationOriginDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const NafsStationOriginDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Origins of Nafs Stations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'The four stations used in the Nafs Meter and throughout the app.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              ...kNafsOrigins.map(_buildOriginCard),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOriginCard(_NafsOrigin origin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: origin.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: origin.color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 4, right: 12),
            decoration: BoxDecoration(
              color: origin.color,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      origin.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: origin.color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      origin.arabic,
                      style: TextStyle(
                        fontSize: 12,
                        color: origin.color.withValues(alpha: 0.7),
                      ),
                    ),
                    if (origin.sourceType == _SourceType.scholarly) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Text(
                          '‡ scholarly',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentDark,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  origin.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  origin.source,
                  style: const TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _SourceType { quranic, scholarly }

class _NafsOrigin {
  final NafsType type;
  final String label;
  final String arabic;
  final String description;
  final String source;
  final Color color;
  final _SourceType sourceType;

  const _NafsOrigin({
    required this.label,
    required this.arabic,
    required this.description,
    required this.source,
    required this.color,
    required this.sourceType,
  }) : type = NafsType.ammarah; // placeholder, unused
}

const kNafsOrigins = <_NafsOrigin>[
  _NafsOrigin(
    label: 'Ammarah',
    arabic: 'الأمّارة',
    description: 'The commanding soul — the base self inclined toward '
        'desire and heedlessness without restraint.',
    source: 'Qur\'an, Surah Yusuf 12:53 — "Indeed the soul is a constant '
        'commander of evil."',
    color: AppColors.nafsAmmarah,
    sourceType: _SourceType.quranic,
  ),
  _NafsOrigin(
    label: 'Lawwamah',
    arabic: 'اللوّامة',
    description: 'The reproaching soul — conscience awakens, and the self '
        'begins to regret wrongdoing.',
    source: 'Qur\'an, Surah Al-Qiyamah 75:2 — "And I swear by the '
        'reproaching soul."',
    color: AppColors.nafsLawwamah,
    sourceType: _SourceType.quranic,
  ),
  _NafsOrigin(
    label: 'Mulhamah',
    arabic: 'الملهمة',
    description: 'The inspired soul — a stage where the soul receives '
        'spiritual insight and inspiration, recognised in classical Islamic '
        'spirituality.',
    source: 'Classical scholarship: al-Tirmidhī (d. ~905 CE) in his '
        'taxonomy of the soul, and al-Ghazālī (d. 1111 CE) in Iḥyāʾ '
        'ʿUlūm al-Dīn. Not explicitly named in the Qur\'an.',
    color: AppColors.nafsMulhamah,
    sourceType: _SourceType.scholarly,
  ),
  _NafsOrigin(
    label: 'Mutmainnah',
    arabic: 'المطمئنة',
    description: 'The tranquil soul — the highest station, at peace with '
        'its Lord, content and pleasing to Allah.',
    source: 'Qur\'an, Surah Al-Fajr 89:27–30 — "O soul in complete rest '
        'and satisfaction! Return to your Lord, well-pleased and '
        'well-pleasing."',
    color: AppColors.secondary,
    sourceType: _SourceType.quranic,
  ),
];
