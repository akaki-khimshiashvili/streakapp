import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

// ─── Palette (matching reference UI) ────────────────────────────────────────
const _bg = Color(0xFFF7F7F5);
const _cardWhite = Color(0xFFFFFFFF);
const _textDark = Color(0xFF1A1A2E);
const _textMid = Color(0xFF6B7280);
const _textLight = Color(0xFF9CA3AF);
const _accent = Color(0xFF2563EB);
const _accentBadge = Color(0xFFEEF2FF);
const _accentBadgeText = Color(0xFF2563EB);
const _divider = Color(0xFFF0F0EE);

// ─── Stat card tints (peach / sage / lavender from reference) ───────────────
const _peach = Color(0xFFFFF0E6);
const _sage = Color(0xFFE8F5EE);
const _lavender = Color(0xFFF0EEFF);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(user: user),
              const SizedBox(height: 28),
              _StatsRow(),
              const SizedBox(height: 28),
              _SectionLabel('Account'),
              const SizedBox(height: 12),
              _MenuGroup(
                items: [
                  _MenuItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.flag_outlined,
                    label: 'Goals',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.lock_outline,
                    label: 'Privacy',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _MenuGroup(
                items: [
                  _MenuItem(
                    icon: Icons.logout_rounded,
                    label: 'Sign Out',
                    labelColor: Colors.redAccent,
                    onTap: () => _signOut(context),
                    showChevron: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await AuthService.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Top bar — avatar + name + email + badge
// ═══════════════════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  const _TopBar({required this.user});
  final User? user;

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final name = user?.displayName ?? 'User';
    final email = user?.email ?? '';
    final photoUrl = user?.photoURL;

    return Row(
      children: [
        // Avatar
        Stack(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: const Color(0xFFDDE3FF),
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? Text(
                      _initials(name),
                      style: const TextStyle(
                        color: _accent,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: _bg, width: 2),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 11,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: 16),

        // Name + email + badge
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: _textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: const TextStyle(color: _textMid, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _accentBadge,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Google Account',
                  style: TextStyle(
                    color: _accentBadgeText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Stats row — three tinted cards
// ═══════════════════════════════════════════════════════════════════════════
class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          value: '14',
          label: 'Current\nStreak',
          tint: _peach,
          valueColor: const Color(0xFFD97706),
          icon: Icons.local_fire_department_rounded,
          iconColor: const Color(0xFFD97706),
        ),
        const SizedBox(width: 10),
        _StatCard(
          value: '31',
          label: 'Best\nStreak',
          tint: _lavender,
          valueColor: const Color(0xFF6D28D9),
          icon: Icons.emoji_events_rounded,
          iconColor: const Color(0xFF6D28D9),
        ),
        const SizedBox(width: 10),
        _StatCard(
          value: '5',
          label: 'Active\nHabits',
          tint: _sage,
          valueColor: const Color(0xFF059669),
          icon: Icons.check_circle_outline_rounded,
          iconColor: const Color(0xFF059669),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.tint,
    required this.valueColor,
    required this.icon,
    required this.iconColor,
  });

  final String value;
  final String label;
  final Color tint;
  final Color valueColor;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: _textMid,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Menu
// ═══════════════════════════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _textDark,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.items});
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          return Column(
            children: [
              e.value,
              if (e.key < items.length - 1)
                const Divider(height: 1, color: _divider, indent: 52),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor = _textDark,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color labelColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final isDestructive = labelColor != _textDark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDestructive
                    ? const Color(0xFFFFEEEE)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.redAccent : _textMid,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showChevron)
              const Icon(
                Icons.chevron_right_rounded,
                color: _textLight,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
