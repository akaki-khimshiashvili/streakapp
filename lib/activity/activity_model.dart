class Activity {
  final String id;
  final String userId;
  final String title;
  final String iconEmoji;
  final String interval; // 'daily', '3x_week', 'weekly', 'custom'
  final List<int> scheduleDays; // 0=Mon ... 6=Sun
  final DateTime nextDueDate;
  final String category;
  final String priority; // 'low', 'medium', 'high'
  final String? notes;
  final String? goalDefinition;
  final int streakCount;
  final int streakFreezeTokens;
  final DateTime? lastCompleted;
  final List<DateTime> completionHistory;
  final String status; // 'due', 'completed', 'missed', 'upcoming'
  final bool reminderEnabled;
  final String? reminderTime; // "HH:mm" e.g. "08:00"
  final String createdAt;

  Activity({
    required this.id,
    required this.userId,
    required this.title,
    required this.iconEmoji,
    required this.interval,
    required this.scheduleDays,
    required this.nextDueDate,
    required this.category,
    required this.priority,
    this.notes,
    this.goalDefinition,
    this.streakCount = 0,
    this.streakFreezeTokens = 2,
    this.lastCompleted,
    this.completionHistory = const [],
    this.status = 'upcoming',
    this.reminderEnabled = false,
    this.reminderTime,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'userId': userId,
      'title': title,
      'iconEmoji': iconEmoji,
      'interval': interval,
      'scheduleDays': scheduleDays,
      'nextDueDate': nextDueDate.toIso8601String(),
      'category': category,
      'priority': priority,
      'streakCount': streakCount,
      'streakFreezeTokens': streakFreezeTokens,
      'completionHistory': completionHistory
          .map((d) => d.toIso8601String())
          .toList(),
      'status': status,
      'reminderEnabled': reminderEnabled,
      'createdAt': createdAt,
    };

    // Only write optional fields if non-null
    if (notes != null) map['notes'] = notes;
    if (goalDefinition != null) map['goalDefinition'] = goalDefinition;
    if (lastCompleted != null) {
      map['lastCompleted'] = lastCompleted!.toIso8601String();
    }
    if (reminderTime != null) map['reminderTime'] = reminderTime;

    return map;
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      iconEmoji: map['iconEmoji'] as String,
      interval: map['interval'] as String,
      scheduleDays: List<int>.from(map['scheduleDays'] as List),
      nextDueDate: DateTime.parse(map['nextDueDate'] as String),
      category: map['category'] as String,
      priority: map['priority'] as String,
      notes: map['notes'] as String?,
      goalDefinition: map['goalDefinition'] as String?,
      streakCount: (map['streakCount'] as num?)?.toInt() ?? 0,
      streakFreezeTokens: (map['streakFreezeTokens'] as num?)?.toInt() ?? 2,
      lastCompleted: map['lastCompleted'] != null
          ? DateTime.parse(map['lastCompleted'] as String)
          : null,
      completionHistory:
          (map['completionHistory'] as List<dynamic>?)
              ?.map((d) => DateTime.parse(d as String))
              .toList() ??
          [],
      status: map['status'] as String? ?? 'upcoming',
      reminderEnabled: map['reminderEnabled'] as bool? ?? false,
      reminderTime: map['reminderTime'] as String?,
      createdAt: map['createdAt'] as String,
    );
  }

  Activity copyWith({
    String? id,
    String? userId,
    String? title,
    String? iconEmoji,
    String? interval,
    List<int>? scheduleDays,
    DateTime? nextDueDate,
    String? category,
    String? priority,
    String? notes,
    String? goalDefinition,
    int? streakCount,
    int? streakFreezeTokens,
    DateTime? lastCompleted,
    List<DateTime>? completionHistory,
    String? status,
    bool? reminderEnabled,
    String? reminderTime,
    String? createdAt,
  }) {
    return Activity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      interval: interval ?? this.interval,
      scheduleDays: scheduleDays ?? this.scheduleDays,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      goalDefinition: goalDefinition ?? this.goalDefinition,
      streakCount: streakCount ?? this.streakCount,
      streakFreezeTokens: streakFreezeTokens ?? this.streakFreezeTokens,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      completionHistory: completionHistory ?? this.completionHistory,
      status: status ?? this.status,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
