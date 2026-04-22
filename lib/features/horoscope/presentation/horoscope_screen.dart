import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

const _signs = [
  ('♈', 'Aries', 'Mar 21 - Apr 19'),
  ('♉', 'Taurus', 'Apr 20 - May 20'),
  ('♊', 'Gemini', 'May 21 - Jun 20'),
  ('♋', 'Cancer', 'Jun 21 - Jul 22'),
  ('♌', 'Leo', 'Jul 23 - Aug 22'),
  ('♍', 'Virgo', 'Aug 23 - Sep 22'),
  ('♎', 'Libra', 'Sep 23 - Oct 22'),
  ('♏', 'Scorpio', 'Oct 23 - Nov 21'),
  ('♐', 'Sagittarius', 'Nov 22 - Dec 21'),
  ('♑', 'Capricorn', 'Dec 22 - Jan 19'),
  ('♒', 'Aquarius', 'Jan 20 - Feb 18'),
  ('♓', 'Pisces', 'Feb 19 - Mar 20'),
];

class HoroscopeScreen extends ConsumerStatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  ConsumerState<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends ConsumerState<HoroscopeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(title: const Text('Horoscope')),
      body: Column(
        children: [
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: _signs.length,
              itemBuilder: (_, i) {
                final (symbol, name, _) = _signs[i];
                final selected = i == _selectedIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.cardDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.borderDark,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(symbol,
                            style: TextStyle(
                                fontSize: 22,
                                color: selected ? AppColors.accent : null)),
                        const SizedBox(height: 2),
                        Text(name,
                            style: tt.labelSmall?.copyWith(
                                color: selected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                fontSize: 10)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _HoroscopeDetail(
              sign: _signs[_selectedIndex].$2.toLowerCase(),
              displayName: _signs[_selectedIndex].$2,
              symbol: _signs[_selectedIndex].$1,
              dateRange: _signs[_selectedIndex].$3,
            ),
          ),
        ],
      ),
    );
  }
}

class _HoroscopeDetail extends StatelessWidget {
  const _HoroscopeDetail({
    required this.sign,
    required this.displayName,
    required this.symbol,
    required this.dateRange,
  });
  final String sign;
  final String displayName;
  final String symbol;
  final String dateRange;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3949AB), Color(0xFF7B1FA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Text(symbol, style: const TextStyle(fontSize: 56)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName,
                      style: tt.headlineSmall?.copyWith(color: Colors.white)),
                  Text(dateRange,
                      style: tt.bodySmall?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Today\'s Reading',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.1),
        const SizedBox(height: 16),
        ..._buildSections(tt),
      ],
    );
  }

  List<Widget> _buildSections(TextTheme tt) {
    const sections = [
      ('❤️', 'Love & Relationships',
          'The stars favor deep connections today. Venus aligns with your sign, bringing harmony and understanding in relationships.'),
      ('💼', 'Career & Finance',
          'Mercury\'s position suggests a good day for negotiations and financial decisions. Trust your instincts in professional matters.'),
      ('🌱', 'Health & Wellness',
          'Energy levels are high today. Ideal for outdoor activities and starting new health routines.'),
      ('🌟', 'General Outlook',
          'Today brings opportunities for growth and self-discovery. Stay open to new experiences and let the universe guide you.'),
    ];

    return sections.asMap().entries.map((entry) {
      final i = entry.key;
      final (icon, title, content) = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(title,
                    style:
                        tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 8),
              Text(content,
                  style: tt.bodySmall?.copyWith(
                      color: AppColors.textSecondary, height: 1.5)),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 100 * i)).slideY(begin: 0.1),
      );
    }).toList();
  }
}
