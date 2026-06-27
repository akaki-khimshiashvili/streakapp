import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'activity_model.dart';
import 'activity_service.dart';

const _bg = Color(0xFFF7F7F5);
const _ink = Color(0xFF1A1A2E);
const _muted = Color(0xFF9E9E9E);
const _peach = Color(0xFFFFD4B8);
const _sage = Color(0xFFB8D8C8);
const _lavender = Color(0xFFD4B8FF);
const _sky = Color(0xFFB8D8FF);
const _lemon = Color(0xFFFFF3B8);
const _coral = Color(0xFFFFB8B8);

class CreateActivitySheet extends StatefulWidget {
  const CreateActivitySheet({super.key});

  @override
  State<CreateActivitySheet> createState() => _CreateActivitySheetState();
}

class _CreateActivitySheetState extends State<CreateActivitySheet> {
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();

  String _selectedEmoji = '🏃';
  String _selectedInterval = 'daily';
  String _selectedCategory = 'Health';
  String _selectedPriority = 'medium';
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);

  // For 3x_week: user picks exactly 3 days
  final Set<int> _threeDays = {};
  // For weekly: user picks 1 day
  int _weeklyDay = 0;
  // For custom: user picks frequency 1–7
  int _customFrequency = 3;
  // For custom: user picks which days
  final Set<int> _customDays = {};

  bool _saving = false;
  int _step = 0;
  late final PageController _pageCtrl;

  static const _emojis = [
    '🏃',
    '💧',
    '📚',
    '🧘',
    '💪',
    '🎯',
    '✍️',
    '🎨',
    '🎸',
    '🍎',
    '😴',
    '🧹',
    '💊',
    '🌿',
    '🚴',
    '🏊',
    '🧠',
    '💻',
    '📝',
    '🌅',
    '🎵',
    '🏋️',
    '🥗',
    '☕',
  ];

  static const _categories = [
    ('Health', '💚'),
    ('Study', '📘'),
    ('Work', '💼'),
    ('Mindfulness', '🧘'),
    ('Fitness', '🏅'),
    ('Creative', '🎨'),
    ('Social', '👥'),
    ('Other', '✨'),
  ];

  static const _intervals = [
    ('daily', 'Daily', '📅'),
    ('3x_week', '3× / Week', '📆'),
    ('weekly', 'Weekly', '🗓️'),
    ('custom', 'Custom', '⚙️'),
  ];

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _weekdaysShort = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  static const _priorities = [
    ('low', 'Low', _sage, '🌱'),
    ('medium', 'Medium', _lemon, '⚡'),
    ('high', 'High', _coral, '🔥'),
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    _goalCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 0 && _titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please give your activity a name ✏️'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    if (_step == 1) {
      // Validate schedule selections
      if (_selectedInterval == '3x_week' && _threeDays.length != 3) {
        _showError('Pick exactly 3 days for your schedule');
        return;
      }
      if (_selectedInterval == 'custom' && _customDays.isEmpty) {
        _showError('Pick at least one day');
        return;
      }
    }
    if (_step < 2) {
      setState(() => _step++);
      _pageCtrl.animateToPage(
        _step,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _save();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _pageCtrl.animateToPage(
        _step,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<int> _resolvedScheduleDays() {
    switch (_selectedInterval) {
      case 'daily':
        return [0, 1, 2, 3, 4, 5, 6];
      case '3x_week':
        return _threeDays.toList()..sort();
      case 'weekly':
        return [_weeklyDay];
      case 'custom':
        return _customDays.toList()..sort();
      default:
        return [0, 1, 2, 3, 4, 5, 6];
    }
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError('Not signed in');
      return;
    }

    setState(() => _saving = true);

    try {
      final reminderStr = _reminderEnabled
          ? '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}'
          : null;

      final activity = Activity(
        id: const Uuid().v4(),
        userId: user.uid,
        title: _titleCtrl.text.trim(),
        iconEmoji: _selectedEmoji,
        interval: _selectedInterval,
        scheduleDays: _resolvedScheduleDays(),
        nextDueDate: _computeFirstDue(),
        category: _selectedCategory,
        priority: _selectedPriority,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        goalDefinition: _goalCtrl.text.trim().isEmpty
            ? null
            : _goalCtrl.text.trim(),
        reminderEnabled: _reminderEnabled,
        reminderTime: reminderStr,
        createdAt: DateTime.now().toIso8601String(),
      );

      await ActivityService.createActivity(activity);

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _showError('Failed to save: $e');
      }
    }
  }

  DateTime _computeFirstDue() {
    final now = DateTime.now();
    if (_selectedInterval == 'weekly') {
      return now.add(const Duration(days: 7));
    }
    return DateTime(now.year, now.month, now.day);
  }

  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [_buildStep0(), _buildStep1(), _buildStep2()],
            ),
          ),
          _buildFooter(bottom),
        ],
      ),
    );
  }

  Widget _buildHandle() => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );

  Widget _buildHeader() {
    const titles = ['New Activity', 'Schedule', 'Details'];
    const subtitles = [
      'What do you want to build a streak for?',
      'When should this repeat?',
      'Add some finishing touches',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(_selectedEmoji + _selectedCategory),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _categoryColor(_selectedCategory).withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  _selectedEmoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    titles[_step],
                    key: ValueKey(_step),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitles[_step],
                  style: const TextStyle(fontSize: 13, color: _muted),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: _ink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() => Padding(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
    child: Row(
      children: List.generate(3, (i) {
        final active = i == _step;
        final done = i < _step;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: done
                    ? _ink
                    : active
                    ? _ink.withOpacity(0.4)
                    : Colors.grey.shade300,
              ),
            ),
          ),
        );
      }),
    ),
  );

  // ── STEP 0: Basics ────────────────────────────────────────────
  Widget _buildStep0() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Activity Name'),
          const SizedBox(height: 8),
          TextField(
            controller: _titleCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
            decoration: _inputDecoration('e.g. Morning Run, Read 20 pages…'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          _sectionLabel('Icon'),
          const SizedBox(height: 10),
          _buildEmojiGrid(),
          const SizedBox(height: 24),
          _sectionLabel('Category'),
          const SizedBox(height: 10),
          _buildCategoryDropdown(),
          const SizedBox(height: 24),
          _sectionLabel('Priority'),
          const SizedBox(height: 10),
          _buildPriorityRow(),
        ],
      ),
    );
  }

  Widget _buildEmojiGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _emojis.map((e) {
        final selected = e == _selectedEmoji;
        return GestureDetector(
          onTap: () => setState(() => _selectedEmoji = e),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: selected ? _ink : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? _ink : Colors.grey.shade200),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: _ink.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _ink),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _ink,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
          items: _categories.map((cat) {
            final (name, emoji) = cat;
            return DropdownMenuItem(
              value: name,
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Text(name),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) setState(() => _selectedCategory = v);
          },
        ),
      ),
    );
  }

  Widget _buildPriorityRow() {
    return Row(
      children: _priorities.map((p) {
        final (value, label, color, emoji) = p;
        final selected = _selectedPriority == value;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPriority = value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(right: value != 'high' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected ? color : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? color : Colors.grey.shade200,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? _ink : _muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── STEP 1: Schedule ──────────────────────────────────────────
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Repeat'),
          const SizedBox(height: 10),
          _buildIntervalGrid(),
          const SizedBox(height: 24),
          // Dynamic schedule sub-section
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _buildScheduleSubSection(),
          ),
          _buildNextDueCard(),
          const SizedBox(height: 24),
          _sectionLabel('Reminder'),
          const SizedBox(height: 10),
          _buildReminderTile(),
        ],
      ),
    );
  }

  Widget _buildIntervalGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.8,
      children: _intervals.map((iv) {
        final (value, label, emoji) = iv;
        final selected = _selectedInterval == value;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedInterval = value;
            // reset sub-selections when switching
            _threeDays.clear();
            _customDays.clear();
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: selected ? _ink : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? _ink : Colors.grey.shade200),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : _ink,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScheduleSubSection() {
    switch (_selectedInterval) {
      case '3x_week':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Choose 3 days  (${_threeDays.length}/3 selected)'),
            const SizedBox(height: 10),
            _buildDayToggleRow(selectedDays: _threeDays, maxSelect: 3),
            const SizedBox(height: 24),
          ],
        );
      case 'weekly':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Which day of the week?'),
            const SizedBox(height: 10),
            _buildWeeklyDayRow(),
            const SizedBox(height: 24),
          ],
        );
      case 'custom':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('How many times per week?  ($_customFrequency×)'),
            const SizedBox(height: 8),
            _buildCustomFrequencySlider(),
            const SizedBox(height: 20),
            _sectionLabel(
              'Which days?  (${_customDays.length}/$_customFrequency selected)',
            ),
            const SizedBox(height: 10),
            _buildDayToggleRow(
              selectedDays: _customDays,
              maxSelect: _customFrequency,
            ),
            const SizedBox(height: 24),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDayToggleRow({
    required Set<int> selectedDays,
    required int maxSelect,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final active = selectedDays.contains(i);
        final atMax = selectedDays.length >= maxSelect;
        return GestureDetector(
          onTap: () {
            setState(() {
              if (active) {
                selectedDays.remove(i);
              } else if (!atMax) {
                selectedDays.add(i);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? _ink
                  : (!atMax ? Colors.white : Colors.grey.shade100),
              border: Border.all(color: active ? _ink : Colors.grey.shade300),
            ),
            child: Center(
              child: Text(
                _weekdaysShort[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: active
                      ? Colors.white
                      : (!atMax ? _ink : Colors.grey.shade400),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWeeklyDayRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final active = _weeklyDay == i;
        return GestureDetector(
          onTap: () => setState(() => _weeklyDay = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 40,
            height: 56,
            decoration: BoxDecoration(
              color: active ? _ink : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: active ? _ink : Colors.grey.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _weekdaysShort[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : _ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _weekdays[i],
                  style: TextStyle(
                    fontSize: 9,
                    color: active ? Colors.white70 : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCustomFrequencySlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final val = i + 1;
              final selected = _customFrequency == val;
              return GestureDetector(
                onTap: () => setState(() {
                  _customFrequency = val;
                  // Remove days if over new limit
                  while (_customDays.length > val) {
                    _customDays.remove(_customDays.last);
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? _ink : Colors.grey.shade100,
                  ),
                  child: Center(
                    child: Text(
                      '$val×',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : _muted,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNextDueCard() {
    final due = _computeFirstDue();
    final formatted = '${_monthName(due.month)} ${due.day}, ${due.year}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _peach.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _peach),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('📅', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Next due',
                style: TextStyle(fontSize: 12, color: _muted),
              ),
              const SizedBox(height: 2),
              Text(
                formatted,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReminderTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _lavender.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('🔔', style: TextStyle(fontSize: 18)),
              ),
            ),
            title: const Text(
              'Enable Reminder',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _ink,
              ),
            ),
            subtitle: const Text(
              'Get notified at a set time',
              style: TextStyle(fontSize: 12, color: _muted),
            ),
            trailing: Switch.adaptive(
              value: _reminderEnabled,
              onChanged: (v) => setState(() => _reminderEnabled = v),
              activeColor: _ink,
            ),
          ),
          if (_reminderEnabled) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            InkWell(
              onTap: _pickReminderTime,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _sky.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('⏰', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Remind me at',
                          style: TextStyle(fontSize: 12, color: _muted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _reminderTime.format(context),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: _muted,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _ink,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _ink,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  // ── STEP 2: Extras ────────────────────────────────────────────
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFreezeInfoCard(),
          const SizedBox(height: 24),
          _sectionLabel('Notes'),
          const SizedBox(height: 8),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontSize: 14, color: _ink),
            decoration: _inputDecoration(
              'Any extra details, rules, or context…',
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel('Why does this matter? (optional)'),
          const SizedBox(height: 8),
          TextField(
            controller: _goalCtrl,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontSize: 14, color: _ink),
            decoration: _inputDecoration('e.g. "Train for a 5K in March"'),
          ),
          const SizedBox(height: 24),
          _buildSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildFreezeInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _sky.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _sky),
      ),
      child: const Row(
        children: [
          Text('🧊', style: TextStyle(fontSize: 28)),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Streak Freeze',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'You start with 2 freeze tokens. Use one when life gets in the way — no streak lost.',
                  style: TextStyle(fontSize: 12, color: _muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final intervalLabel = _intervals
        .firstWhere((i) => i.$1 == _selectedInterval)
        .$2;
    String scheduleDetail = '';
    switch (_selectedInterval) {
      case '3x_week':
        if (_threeDays.isNotEmpty) {
          scheduleDetail = (_threeDays.toList()..sort())
              .map((i) => _weekdays[i])
              .join(', ');
        }
        break;
      case 'weekly':
        scheduleDetail = 'Every ${_weekdays[_weeklyDay]}';
        break;
      case 'custom':
        if (_customDays.isNotEmpty) {
          final days = (_customDays.toList()..sort())
              .map((i) => _weekdays[i])
              .join(', ');
          scheduleDetail = '$_customFrequency× — $days';
        }
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_selectedEmoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _titleCtrl.text.trim().isEmpty
                      ? 'Unnamed Activity'
                      : _titleCtrl.text.trim(),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ),
              _priorityBadge(_selectedPriority),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _summaryRow('📂', _selectedCategory),
          const SizedBox(height: 6),
          _summaryRow('🔁', intervalLabel),
          if (scheduleDetail.isNotEmpty) ...[
            const SizedBox(height: 6),
            _summaryRow('📋', scheduleDetail),
          ],
          const SizedBox(height: 6),
          _summaryRow('🔥', '0 day streak to start'),
          if (_reminderEnabled) ...[
            const SizedBox(height: 6),
            _summaryRow('🔔', 'Reminder at ${_reminderTime.format(context)}'),
          ],
        ],
      ),
    );
  }

  String _buildScheduleDetail() {
    switch (_selectedInterval) {
      case '3x_week':
        if (_threeDays.isEmpty) return '';
        final threeDayNames = (_threeDays.toList()..sort())
            .map((i) => _weekdays[i])
            .join(', ');
        return threeDayNames;
      case 'weekly':
        return 'Every ${_weekdays[_weeklyDay]}';
      case 'custom':
        if (_customDays.isEmpty) return '';
        final days = (_customDays.toList()..sort())
            .map((i) => _weekdays[i])
            .join(', ');
        return '$_customFrequency× — $days';
      default:
        return '';
    }
  }

  Widget _summaryRow(String emoji, String text) => Row(
    children: [
      Text(emoji, style: const TextStyle(fontSize: 14)),
      const SizedBox(width: 8),
      Expanded(
        child: Text(text, style: const TextStyle(fontSize: 13, color: _muted)),
      ),
    ],
  );

  Widget _priorityBadge(String priority) {
    final map = {
      'low': (_sage, '🌱 Low'),
      'medium': (_lemon, '⚡ Med'),
      'high': (_coral, '🔥 High'),
    };
    final (color, label) = map[priority]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _ink,
        ),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────
  Widget _buildFooter(double bottomInset) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _back,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: _ink,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _saving ? null : _next,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 52,
                decoration: BoxDecoration(
                  color: _saving ? Colors.grey.shade300 : _ink,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _step == 2 ? '🎯  Create Activity' : 'Continue →',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────
  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _ink, width: 1.5),
    ),
  );

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: _muted,
      letterSpacing: 0.5,
    ),
  );

  Color _categoryColor(String cat) {
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
    return map[cat] ?? _lemon;
  }

  String _monthName(int m) => const [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m];
}
