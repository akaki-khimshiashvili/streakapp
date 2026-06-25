import 'package:flutter/material.dart';

// ─── Palette ────────────────────────────────────────────────────────────────
const _bg = Color(0xFFF5F5F0);
const _white = Color(0xFFFFFFFF);
const _textPrimary = Color(0xFF1A1A2E);
const _textSub = Color(0xFF8A8A9A);
const _accent = Color(0xFFFF6B6B);
const _navBg = Color(0xFFFFFFFF);
const _navInactive = Color(0xFFBBBBCC);
const _navActive = Color(0xFF1A1A2E);
const _plusBg = Color(0xFF1A1A2E);

// ─── Category card colors ────────────────────────────────────────────────────
const _exerciseCardBg = Color(0xFFD4E8F0); // light blue
const _educationCardBg = Color(0xFFF0E8D8); // warm beige
const _mindfulnessCardBg = Color(0xFFE8D8F0); // soft lavender
const _greenCardBg = Color(0xFFD8F0D8); // light green (4th card placeholder)

// ═══════════════════════════════════════════════════════════════════════════
//  Entry point
// ═══════════════════════════════════════════════════════════════════════════
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _HomeShell(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Shell with bottom nav
// ═══════════════════════════════════════════════════════════════════════════
class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    _TodayPage(),
    _ProgressPage(),
    _CalendarPage(),
    _ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: _pages[_selectedIndex],
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: _selectedIndex,
        onTabChanged: (i) => setState(() => _selectedIndex = i),
        onPlusTapped: () {
          // TODO: open add habit sheet
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (_) => const _AddHabitSheet(),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Bottom Navigation Bar
// ═══════════════════════════════════════════════════════════════════════════
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.selectedIndex,
    required this.onTabChanged,
    required this.onPlusTapped,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onPlusTapped;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: _navBg,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: bottomPadding > 0 ? bottomPadding : 12,
          top: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Today',
              isSelected: selectedIndex == 0,
              onTap: () => onTabChanged(0),
            ),
            _NavItem(
              icon: Icons.bar_chart_outlined,
              activeIcon: Icons.bar_chart_rounded,
              label: 'Progress',
              isSelected: selectedIndex == 1,
              onTap: () => onTabChanged(1),
            ),

            // ── Center + button ──────────────────────────────────────
            GestureDetector(
              onTap: onPlusTapped,
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: _plusBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),

            _NavItem(
              icon: Icons.calendar_today_outlined,
              activeIcon: Icons.calendar_today_rounded,
              label: 'Calendar',
              isSelected: selectedIndex == 2,
              onTap: () => onTabChanged(2),
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Profile',
              isSelected: selectedIndex == 3,
              onTap: () => onTabChanged(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? _navActive : _navInactive;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Today Page
// ═══════════════════════════════════════════════════════════════════════════
class _TodayPage extends StatelessWidget {
  const _TodayPage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  // Logo / brand
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.whatshot_rounded,
                          color: _accent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'bettermotion',
                            style: TextStyle(
                              color: _textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Good morning, Angela!',
                            style: TextStyle(color: _textSub, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Streak badge
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '12',
                        style: TextStyle(
                          color: _accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Avatar
                  ClipOval(
                    child: Container(
                      width: 36,
                      height: 36,
                      color: const Color(0xFFDDCCBB),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Category cards ───────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _CategoryCard(
                  title: 'Exercise therapy',
                  subtitle: 'Show more',
                  bgColor: _exerciseCardBg,
                  illustrationColor: const Color(0xFF7BB8CC),
                  icon: Icons.directions_run_rounded,
                ),
                const SizedBox(height: 14),
                _CategoryCard(
                  title: 'Education',
                  subtitle: 'Show more',
                  bgColor: _educationCardBg,
                  illustrationColor: const Color(0xFFCC9977),
                  icon: Icons.menu_book_rounded,
                ),
                const SizedBox(height: 14),
                _CategoryCard(
                  title: 'Mindfulness',
                  subtitle: 'Show more',
                  bgColor: _mindfulnessCardBg,
                  illustrationColor: const Color(0xFF9977CC),
                  icon: Icons.self_improvement_rounded,
                ),
                const SizedBox(height: 14),
                _CategoryCard(
                  title: 'Nutrition',
                  subtitle: 'Show more',
                  bgColor: _greenCardBg,
                  illustrationColor: const Color(0xFF77CC99),
                  icon: Icons.eco_rounded,
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Category Card
// ═══════════════════════════════════════════════════════════════════════════
class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.illustrationColor,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final Color bgColor;
  final Color illustrationColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // ── Decorative illustration placeholder (large icon) ────────
          Positioned(
            right: -10,
            top: -10,
            child: Opacity(
              opacity: 0.18,
              child: Icon(icon, size: 130, color: illustrationColor),
            ),
          ),
          // ── Foreground illustration icon ────────────────────────────
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: Icon(icon, size: 72, color: illustrationColor),
          ),
          // ── Text content ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _textSub,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: _textSub,
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Placeholder Pages
// ═══════════════════════════════════════════════════════════════════════════
class _ProgressPage extends StatelessWidget {
  const _ProgressPage();

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(
      icon: Icons.bar_chart_rounded,
      label: 'Progress',
    );
  }
}

class _CalendarPage extends StatelessWidget {
  const _CalendarPage();

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(
      icon: Icons.calendar_today_rounded,
      label: 'Calendar',
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(icon: Icons.person_rounded, label: 'Profile');
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: _textSub.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              color: _textSub,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coming soon',
            style: TextStyle(color: _textSub, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Add Habit Sheet (triggered by + button)
// ═══════════════════════════════════════════════════════════════════════════
class _AddHabitSheet extends StatelessWidget {
  const _AddHabitSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Add New Habit',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose a category to get started.',
            style: TextStyle(color: _textSub, fontSize: 14),
          ),
          const SizedBox(height: 24),
          _SheetOption(
            icon: Icons.directions_run_rounded,
            label: 'Exercise therapy',
            color: _exerciseCardBg,
            iconColor: Color(0xFF7BB8CC),
          ),
          const SizedBox(height: 12),
          _SheetOption(
            icon: Icons.menu_book_rounded,
            label: 'Education',
            color: _educationCardBg,
            iconColor: Color(0xFFCC9977),
          ),
          const SizedBox(height: 12),
          _SheetOption(
            icon: Icons.self_improvement_rounded,
            label: 'Mindfulness',
            color: _mindfulnessCardBg,
            iconColor: Color(0xFF9977CC),
          ),
          const SizedBox(height: 12),
          _SheetOption(
            icon: Icons.eco_rounded,
            label: 'Nutrition',
            color: _greenCardBg,
            iconColor: Color(0xFF77CC99),
          ),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: _textSub,
            ),
          ],
        ),
      ),
    );
  }
}
