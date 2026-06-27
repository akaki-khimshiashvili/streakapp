import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:streakapp/activity/activity_model.dart';
import 'package:streakapp/activity/activity_service.dart';

const _ink = Color(0xFF1A1A2E);
const _muted = Color(0xFF9E9E9E);
const _peach = Color(0xFFFFD4B8);
const _sage = Color(0xFFB8D8C8);
const _lavender = Color(0xFFD4B8FF);
const _sky = Color(0xFFB8D8FF);
const _lemon = Color(0xFFFFF3B8);
const _coral = Color(0xFFFFB8B8);

// Top-level helper so both classes can use it without duplication
String intervalLabel(String interval, int dayCount) {
  switch (interval) {
    case 'daily':
      return 'Every day';
    case '3x_week':
      return '3× per week';
    case 'weekly':
      return 'Once a week';
    case 'custom':
      return '${dayCount}× per week';
    default:
      return interval;
  }
}

class CustomSquareWidget extends StatelessWidget {
  final Activity activity;

  const CustomSquareWidget({super.key, required this.activity});

  Color _cardColor() {
    const map = {
      'Health': _sage,
      'Study': _sky,
      'Work': _lavender,
      'Mindfulness': _lemon,
      'Fitness': _peach,
      'Creative': _coral,
      'Social': _sky,
      'Other': _lemon,
    };
    return map[activity.category] ?? _peach;
  }

  String _dueLine() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
      activity.nextDueDate.year,
      activity.nextDueDate.month,
      activity.nextDueDate.day,
    );
    final diff = due.difference(today).inDays;
    if (activity.status == 'completed') return 'Done today ✓';
    if (diff < 0) return 'Overdue';
    if (diff == 0) return 'Due today';
    if (diff == 1) return 'Due tomorrow';
    return 'In $diff days';
  }

  Color _dueColor() {
    if (activity.status == 'completed') return Colors.green.shade600;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
      activity.nextDueDate.year,
      activity.nextDueDate.month,
      activity.nextDueDate.day,
    );
    final diff = due.difference(today).inDays;
    if (diff < 0) return Colors.red.shade600;
    if (diff == 0) return Colors.orange.shade700;
    return _ink.withOpacity(0.5);
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey cardKey = GlobalKey();
    final color = _cardColor();

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
            cardColor: color,
            child: _ExpandedCardContent(activity: activity),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.55),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            // Left: emoji bubble
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  activity.iconEmoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Middle: title + due + interval
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    activity.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _dueColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _dueLine(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _dueColor(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    intervalLabel(
                      activity.interval,
                      activity.scheduleDays.length,
                    ),
                    style: const TextStyle(fontSize: 11, color: _muted),
                  ),
                ],
              ),
            ),

            // Right: streak badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '${activity.streakCount}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
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

// ── Expand route ──────────────────────────────────────────────────────────────

class _CardExpandRoute extends PageRoute<void> {
  _CardExpandRoute({
    required this.sourceRect,
    required this.child,
    required this.cardColor,
  });

  final Rect sourceRect;
  final Widget child;
  final Color cardColor;

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
      cardColor: cardColor,
      child: child,
    );
  }
}

class _CardExpandTransition extends StatelessWidget {
  const _CardExpandTransition({
    required this.animation,
    required this.sourceRect,
    required this.child,
    required this.cardColor,
  });

  final Animation<double> animation;
  final Rect sourceRect;
  final Widget child;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    const double targetW = 340;
    const double targetH = 480;
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
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
      reverseCurve: const Interval(0.0, 0.2, curve: Curves.easeIn),
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
            // Blurred backdrop
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
                      color: Colors.black.withOpacity(0.1 * backdropT),
                    ),
                  ),
                ),
              ),
            ),

            // Expanding card
            Positioned(
              left: left,
              top: top,
              width: width,
              height: height,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(color: cardColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05 + .1 * t),
                        blurRadius: lerpDouble(10, 32, t)!,
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

// ── Expanded card content ─────────────────────────────────────────────────────

class _ExpandedCardContent extends StatelessWidget {
  final Activity activity;
  const _ExpandedCardContent({required this.activity});

  String _dueLine() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
      activity.nextDueDate.year,
      activity.nextDueDate.month,
      activity.nextDueDate.day,
    );
    final diff = due.difference(today).inDays;
    if (activity.status == 'completed') return 'Completed today ✓';
    if (diff < 0) return 'Overdue by ${-diff} day${diff < -1 ? 's' : ''}';
    if (diff == 0) return 'Due today';
    if (diff == 1) return 'Due tomorrow';
    return 'Due in $diff days';
  }

  String _priorityLabel() {
    switch (activity.priority) {
      case 'low':
        return '🌱 Low';
      case 'medium':
        return '⚡ Medium';
      case 'high':
        return '🔥 High';
      default:
        return activity.priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: emoji + close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(activity.iconEmoji, style: const TextStyle(fontSize: 40)),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: _ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            activity.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _ink,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),

          // Category + priority pills
          Row(
            children: [
              _pill(activity.category),
              const SizedBox(width: 8),
              _pill(_priorityLabel()),
            ],
          ),
          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              _statBox('🔥', '${activity.streakCount}', 'Streak'),
              const SizedBox(width: 12),
              _statBox('🧊', '${activity.streakFreezeTokens}', 'Freezes'),
              const SizedBox(width: 12),
              _statBox('✅', '${activity.completionHistory.length}', 'Total'),
            ],
          ),
          const SizedBox(height: 20),

          // Info rows
          _infoRow('📅', _dueLine()),
          const SizedBox(height: 10),
          _infoRow(
            '🔁',
            intervalLabel(activity.interval, activity.scheduleDays.length),
          ),
          if (activity.reminderEnabled && activity.reminderTime != null) ...[
            const SizedBox(height: 10),
            _infoRow('🔔', 'Reminder at ${activity.reminderTime}'),
          ],
          if (activity.notes != null && activity.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _infoRow('📝', activity.notes!),
          ],
          if (activity.goalDefinition != null &&
              activity.goalDefinition!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _infoRow('🎯', activity.goalDefinition!),
          ],

          const Spacer(),

          // Mark done / completed button
          if (activity.status != 'completed')
            GestureDetector(
              onTap: () async {
                await ActivityService.markDone(activity);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _ink,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    '✓  Mark as Done',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  '✓  Completed Today',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _ink,
        ),
      ),
    );
  }

  Widget _statBox(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.45),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: _muted)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: _ink,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
