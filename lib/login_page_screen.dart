import 'package:flutter/material.dart';
import 'home_screen.dart';

// ─── Palette ────────────────────────────────────────────────────────────────
const _navy = Color(0xFF0D1B2A);
const _ink = Color(0xFF1B2A3B);
const _indigo = Color(0xFF2563EB);
const _indigoLight = Color(0xFF3B82F6);
const _muted = Color(0xFF64748B);
const _textPrimary = Color(0xFFE2E8F0);
const _textSub = Color(0xFF94A3B8);
const _divider = Color(0xFF1E3A5F);

// ─── Entry point ────────────────────────────────────────────────────────────
class LoginPageScreen extends StatelessWidget {
  const LoginPageScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _AuthShell(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Shell
// ═══════════════════════════════════════════════════════════════════════════
class _AuthShell extends StatefulWidget {
  const _AuthShell();
  @override
  State<_AuthShell> createState() => _AuthShellState();
}

class _AuthShellState extends State<_AuthShell>
    with SingleTickerProviderStateMixin {
  bool _sheetOpen = false;

  late final AnimationController _ctrl;
  late final Animation<Offset> _sheetSlide;
  late final Animation<double> _btnFade;

  double _btnScale = 1.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _sheetSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _btnFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _openSheet() async {
    setState(() => _btnScale = 0.95);
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      _btnScale = 1.0;
      _sheetOpen = true;
    });
    _ctrl.forward();
  }

  void _closeSheet() {
    _ctrl.reverse().then((_) {
      if (mounted) setState(() => _sheetOpen = false);
    });
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Blobs ──────────────────────────────────────────────────
          const Positioned(
            top: -60,
            right: -60,
            child: _Blob(size: 220, color: Color(0x592563EB)),
          ),
          const Positioned(
            bottom: -80,
            left: -80,
            child: _Blob(size: 260, color: Color(0x332563EB)),
          ),
          const Positioned(
            top: 180,
            left: -100,
            child: _Blob(size: 180, color: Color(0x1A2563EB)),
          ),

          // ── Static welcome content ─────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 56),
                  const _Logo(),
                  const Spacer(),
                  const Text(
                    'Welcome',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Improve Daily Habits, Track Progress, '
                    'and Achieve Discipline with StreakApp.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textSub,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 48),

                  AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, __) => FadeTransition(
                      opacity: _btnFade,
                      child: IgnorePointer(
                        ignoring: _sheetOpen,
                        child: AnimatedScale(
                          scale: _btnScale,
                          duration: const Duration(milliseconds: 100),
                          child: _PrimaryButton(
                            label: 'Sign In',
                            onTap: _openSheet,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 52),
                ],
              ),
            ),
          ),

          // ── Bottom sheet ───────────────────────────────────────────
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, child) =>
                SlideTransition(position: _sheetSlide, child: child),
            child: _SignInSheet(
              onClose: _closeSheet,
              onSignIn: () => _navigateToHome(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Bottom sheet — social buttons only
// ═══════════════════════════════════════════════════════════════════════════
class _SignInSheet extends StatelessWidget {
  const _SignInSheet({required this.onClose, required this.onSignIn});
  final VoidCallback onClose;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: _ink,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // drag handle
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // heading
                const Text(
                  'Sign In',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Welcome back — keep your streak alive.',
                  style: TextStyle(color: _textSub, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 28),

                // social buttons
                _SocialButton(
                  label: 'Continue with Google',
                  icon: _GoogleIcon(),
                  onTap: onSignIn,
                ),
                const SizedBox(height: 14),
                _SocialButton(
                  label: 'Continue with Facebook',
                  icon: const Icon(
                    Icons.facebook_rounded,
                    color: Color(0xFF1877F2),
                    size: 22,
                  ),
                  onTap: onSignIn,
                ),

                const SizedBox(height: 20),
                GestureDetector(
                  onTap: onClose,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Shared widgets
// ═══════════════════════════════════════════════════════════════════════════
class _Logo extends StatelessWidget {
  const _Logo();
  @override
  Widget build(BuildContext context) {
    return const Text(
      'StreakApp',
      style: TextStyle(
        color: _textPrimary,
        fontSize: 30,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_indigo, _indigoLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _indigo.withOpacity(0.45),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: _navy,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _divider, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 22, height: 22, child: CustomPaint(painter: _GPainter()));
}

class _GPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = size.width / 2;

    void arc(Color c, double start, double sweep) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.78),
        start,
        sweep,
        false,
        Paint()
          ..color = c
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.18
          ..strokeCap = StrokeCap.round,
      );
    }

    arc(const Color(0xFFEA4335), -0.1, 1.0);
    arc(const Color(0xFFFBBC05), 0.9, 0.8);
    arc(const Color(0xFF34A853), 1.7, 0.8);
    arc(const Color(0xFF4285F4), 2.5, 1.0);

    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r * 0.78, cy),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.18
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
