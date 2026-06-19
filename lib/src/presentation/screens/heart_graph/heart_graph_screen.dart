import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/heart_attribute.dart';
import '../../../infrastructure/di/providers.dart';
import '../../widgets/specific/growth_path_strip.dart';
import '../../widgets/specific/master_pathway_card_widget.dart';
import '../../widgets/specific/sheikh_murabbi_panel.dart';

class HeartGraphScreen extends ConsumerStatefulWidget {
  const HeartGraphScreen({super.key});
  @override
  ConsumerState<HeartGraphScreen> createState() => _HeartGraphScreenState();
}

class _HeartGraphScreenState extends ConsumerState<HeartGraphScreen> {
  List<HeartAttribute> _path = const [];
  bool _loading = true;

  static const _masterPathways = [
    ('Anger → Mercy', 'Ghadab → Sabr → Hilm → Rifq → Rahmah', '23,75,86,85,87'),
    ('Anxiety → Peace', 'Tawakkul → Yaqeen → Sakinah', '77,80,99'),
    ('Envy → Contentment', 'Hasad → Shukr → Qana\'ah → Ridha', '21,76,82,100'),
    ('Pride → Humility', 'Kibr → Tawadu → Ikhlas', '2,98,72'),
    ('Sin → Love', 'Tawbah → Inabah → Mahabbah', '71,93,91'),
    ('Heedlessness → Presence', 'Ghaflah → Yaqzah → Ihsan', '10,161,90'),
    ('Dunya → Zuhd', 'Hubb ad-Dunya → Zuhd → Ridha', '27,81,100'),
    ('Ignorance → Nearness', 'Tafakkur → Basirah → Shawq → Wilayah', '103,107,101,198'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final latest = await ref.read(checkinRepositoryProvider).findLatest();
    if (latest != null) {
      final detected = await ref.read(detectedAttributeRepositoryProvider).findForDate(latest.date);
      if (detected.isNotEmpty) {
        final path = await ref.read(growthPathProvider).call(detected.first.attributeId);
        if (mounted) {
          setState(() {
            _path = path;
            _loading = false;
          });
          return;
        }
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Heart Graph')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                // RI-5.6: Suluk framing — these pathways follow the
                // great imams of tazkiya.
                const SulukPathwaysHeader(),
                if (_path.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Your current path',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  GrowthPathStrip(path: _path),
                  const SizedBox(height: 16),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('8 Master pathways',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                for (final p in _masterPathways)
                  MasterPathwayCardWidget(
                    title: p.$1,
                    subtitle: 'HeartOS canonical chain',
                    path: p.$2,
                    onTap: () {},
                  ),
                // RI-3.3: Sheikh/Murabbi panel — classical tazkiya requires
                // a living teacher; the app is a companion, not a replacement.
                const SheikhMurabbiPanel(),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
