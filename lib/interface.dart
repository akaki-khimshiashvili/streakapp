import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'activity/create_activity_sheet.dart';

class MainInterface extends StatefulWidget {
  const MainInterface({super.key});

  @override
  State<MainInterface> createState() => _MainInterfaceState();
}

class _MainInterfaceState extends State<MainInterface> {
  int _currentIndex = 0;

  // --- STYLING CONSTANTS (Centralized Here) ---
  final Color backgroundColor = const Color(0xFFF5F7F5);
  final Color navBarColor = Colors.white;
  final Color activeColor = Colors.black;
  final Color inactiveColor = Colors.grey.shade400;

  // Pages corresponding to each navigation choice
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(), // Index 0: Renders the isolated activity screen
      _buildPlaceholderTab('Progress Screen'), // Index 1
      _buildPlaceholderTab('Calendar Screen'), // Index 2
      const ProfileScreen(), // Index 3
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody:
          true, // Crucial: lets selected views dynamically bleed under the navbar layer

      body: IndexedStack(index: _currentIndex, children: _screens),

      // Integrated Play Floating Action Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 24),
        child: FloatingActionButton(
          onPressed: () async {
            final created = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const CreateActivitySheet(),
            );
            if (created == true) {
              // Optionally trigger a HomeScreen refresh here
              // e.g. via a GlobalKey or provider setState
            }
          },
          backgroundColor: activeColor,
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(
            Icons.play_arrow_outlined,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),

      // Custom Nav Bar UI Implemented Directly Inside Interface Shell
      bottomNavigationBar: BottomAppBar(
        color: navBarColor,
        elevation: 10,
        padding: EdgeInsets.zero,
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInterfaceNavItem(0, Icons.home_filled, 'Home'),
            _buildInterfaceNavItem(1, Icons.bar_chart_rounded, 'Progress'),
            const SizedBox(
              width: 60,
            ), // Clear gap spacing for center FAB overlap
            _buildInterfaceNavItem(2, Icons.calendar_today_rounded, 'Calendar'),
            _buildInterfaceNavItem(3, Icons.person_outline_rounded, 'Profile'),
          ],
        ),
      ),
    );
  }

  // Navbar item builder layout
  Widget _buildInterfaceNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? activeColor : inactiveColor;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 3,
              width: 28,
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Spacer(),
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab(String label) {
    return Center(
      child: Text(
        label,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: activeColor,
        ),
      ),
    );
  }
}
