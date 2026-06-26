import 'package:flutter/material.dart';
import 'dart:ui';

class CustomSquareWidget extends StatelessWidget {
  const CustomSquareWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey cardKey = GlobalKey();

    return GestureDetector(
      key: cardKey,
      onTap: () {
        final RenderBox renderBox =
            cardKey.currentContext!.findRenderObject() as RenderBox;
        final Offset offset = renderBox.localToGlobal(Offset.zero);
        final Size size = renderBox.size;

        Navigator.of(context).push(
          _CardExpandRoute(
            sourceRect: offset & size,
            child: const _ExpandedCardContent(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueAccent.shade100,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            const Center(
              child: Icon(Icons.blur_on_rounded, size: 48, color: Colors.white),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Analytics',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Show more',
                    style: TextStyle(color: Colors.white.withOpacity(.8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardExpandRoute extends PageRoute<void> {
  _CardExpandRoute({required this.sourceRect, required this.child});

  final Rect sourceRect;
  final Widget child;

  @override
  bool get opaque => false;
  @override
  bool get barrierDismissible => true;
  @override
  Color get barrierColor => Colors.transparent;
  @override
  String? get barrierLabel => null;
  @override
  bool get maintainState => true;
  @override
  Duration get transitionDuration => const Duration(milliseconds: 420);
  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 360);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _CardExpandTransition(
      animation: animation,
      sourceRect: sourceRect,
      child: child,
    );
  }
}

class _CardExpandTransition extends StatelessWidget {
  const _CardExpandTransition({
    required this.animation,
    required this.sourceRect,
    required this.child,
  });

  final Animation<double> animation;
  final Rect sourceRect;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    const double targetW = 320;
    const double targetH = 320;
    final double targetLeft = (screenSize.width - targetW) / 2;
    final double targetTop = (screenSize.height - targetH) / 2;
    final Rect targetRect = Rect.fromLTWH(
      targetLeft,
      targetTop,
      targetW,
      targetH,
    );

    final cardCurved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubicEmphasized,
      reverseCurve: Curves.easeInOutCubicEmphasized.flipped,
    );

    final contentCurved = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      reverseCurve: const Interval(0.0, 0.15, curve: Curves.easeIn),
    );

    final backdropCurved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = cardCurved.value;
        final contentT = contentCurved.value;
        final backdropT = backdropCurved.value;

        final left = lerpDouble(sourceRect.left, targetRect.left, t)!;
        final top = lerpDouble(sourceRect.top, targetRect.top, t)!;
        final width = lerpDouble(sourceRect.width, targetRect.width, t)!;
        final height = lerpDouble(sourceRect.height, targetRect.height, t)!;
        final radius = lerpDouble(24, 32, t)!;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Opacity(
                  opacity: backdropT,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 18 * backdropT,
                      sigmaY: 18 * backdropT,
                    ),
                    child: Container(
                      color: Colors.white.withOpacity(0.15 * backdropT),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              width: width,
              height: height,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.shade100,
                    borderRadius: BorderRadius.circular(radius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05 + .07 * t),
                        blurRadius: lerpDouble(10, 24, t)!,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Opacity(opacity: contentT, child: child),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ExpandedCardContent extends StatelessWidget {
  const _ExpandedCardContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.blur_on_rounded, size: 120, color: Colors.white),
    );
  }
}
