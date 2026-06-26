import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'interface.dart';
import 'auth_service.dart';

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
  bool _isLoading = false;
  String? _error;

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
      _error = null;
    });

    _ctrl.forward();
  }

  void _closeSheet() {
    if (_isLoading) return;

    _ctrl.reverse().then((_) {
      if (mounted) {
        setState(() {
          _sheetOpen = false;
          _error = null;
        });
      }
    });
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await AuthService.signInWithGoogle();

      if (!mounted) return;

      if (user != null) {
        _navigateToHome(context);
      } else {
        setState(() {
          _error = "Sign-in cancelled or failed.";
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = "Something went wrong during sign-in.";
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const MainInterface(),
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
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Improve Daily Habits, Track Progress, and Achieve Discipline with StreakApp.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textSub,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (_error != null)
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),

                  const SizedBox(height: 24),

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

          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, child) =>
                SlideTransition(position: _sheetSlide, child: child),
            child: _SignInSheet(
              isLoading: _isLoading,
              onClose: _closeSheet,
              onGoogleSignIn: () => _handleGoogleSignIn(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Bottom Sheet
// ═══════════════════════════════════════════════════════════════════════════
class _SignInSheet extends StatelessWidget {
  const _SignInSheet({
    required this.onClose,
    required this.onGoogleSignIn,
    required this.isLoading,
  });

  final VoidCallback onClose;
  final Future<void> Function() onGoogleSignIn;
  final bool isLoading;

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

                const Text(
                  'Sign In',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Welcome back — keep your streak alive.',
                  style: TextStyle(color: _textSub),
                ),

                const SizedBox(height: 28),

                _SocialButton(
                  label: isLoading ? 'Signing in...' : 'Continue with Google',
                  icon: const _GoogleIcon(),
                  onTap: isLoading ? () {} : onGoogleSignIn,
                ),

                const SizedBox(height: 14),

                _SocialButton(
                  label: 'Continue with Facebook',
                  icon: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
                  onTap: () {},
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: isLoading ? null : onClose,
                  child: const Text('Cancel', style: TextStyle(color: _muted)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── remaining widgets unchanged ────────────────────────────────────────────
class _Logo extends StatelessWidget {
  const _Logo();
  @override
  Widget build(BuildContext context) => const Text(
    'StreakApp',
    style: TextStyle(
      color: _textPrimary,
      fontSize: 30,
      fontWeight: FontWeight.w800,
    ),
  );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_indigo, _indigoLight]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
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
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 52,
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [icon, const SizedBox(width: 12), Text(label)],
      ),
    ),
  );
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) => const SizedBox(width: 22, height: 22);
}
