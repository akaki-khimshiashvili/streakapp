import 'package:cloud_firestore/cloud_firestore.dart';
import 'activity_model.dart';

class ActivityService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> createActivity(Activity activity) async {
    final data = activity.toMap();
    // Remove any null values Firestore might reject
    data.removeWhere((key, value) => value == null);

    await _db
        .collection('users')
        .doc(activity.userId)
        .collection('activities')
        .doc(activity.id)
        .set(data);
  }

  static Stream<List<Activity>> watchActivities(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('activities')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => Activity.fromMap(d.data())).toList(),
        );
  }

  static Future<void> markDone(Activity activity) async {
    final now = DateTime.now();
    final newHistory = [...activity.completionHistory, now];
    final newStreak = activity.streakCount + 1;
    final nextDue = _computeNextDue(activity);

    await _db
        .collection('users')
        .doc(activity.userId)
        .collection('activities')
        .doc(activity.id)
        .update({
          'status': 'completed',
          'lastCompleted': now.toIso8601String(),
          'completionHistory': newHistory
              .map((d) => d.toIso8601String())
              .toList(),
          'streakCount': newStreak,
          'nextDueDate': nextDue.toIso8601String(),
        });
  }

  static DateTime _computeNextDue(Activity activity) {
    final now = DateTime.now();
    switch (activity.interval) {
      case 'daily':
        return now.add(const Duration(days: 1));
      case 'custom':
      case '3x_week':
        return now.add(const Duration(days: 2));
      case 'weekly':
        return now.add(const Duration(days: 7));
      default:
        return now.add(const Duration(days: 1));
    }
  }

  static Future<void> deleteActivity(String userId, String activityId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('activities')
        .doc(activityId)
        .delete();
  }
}
