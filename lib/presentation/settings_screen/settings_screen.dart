import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  // Reminders
  bool _reminderEnabled = true;
  int _intervalMinutes = 60;

  // Schedule
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 22, minute: 30);

  // Daily goal
  double _dailyGoalMl = 2500;
  final TextEditingController _goalController = TextEditingController();

  // Drink presets
  final List<Map<String, dynamic>> _presets = [
    {
      'label': 'Small Cup',
      'ml': 150,
      'icon': Icons.coffee_outlined,
      'color': const Color(0xFFF59E0B),
      'enabled': true,
    },
    {
      'label': 'Glass',
      'ml': 250,
      'icon': Icons.local_drink_outlined,
      'color': const Color(0xFF0EA5E9),
      'enabled': true,
    },
    {
      'label': 'Mug',
      'ml': 350,
      'icon': Icons.coffee_rounded,
      'color': const Color(0xFF8B5CF6),
      'enabled': true,
    },
    {
      'label': 'Bottle',
      'ml': 500,
      'icon': Icons.water_rounded,
      'color': const Color(0xFF10B981),
      'enabled': true,
    },
    {
      'label': 'Large Bottle',
      'ml': 750,
      'icon': Icons.sports_bar_outlined,
      'color': const Color(0xFF06B6D4),
      'enabled': false,
    },
    {
      'label': 'Litre Bottle',
      'ml': 1000,
      'icon': Icons.local_bar_outlined,
      'color': const Color(0xFFEF4444),
      'enabled': false,
    },
  ];

  static const List<Map<String, dynamic>> _intervals = [
    {'label': '30 min', 'value': 30, 'sub': 'Frequent'},
    {'label': '45 min', 'value': 45, 'sub': 'Regular'},
    {'label': '1 hour', 'value': 60, 'sub': 'Balanced'},
    {'label': '90 min', 'value': 90, 'sub': 'Relaxed'},
    {'label': '2 hours', 'value': 120, 'sub': 'Minimal'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _reminderEnabled = prefs.getBool('reminder_enabled') ?? true;
      _intervalMinutes = prefs.getInt('reminder_interval') ?? 60;
      _wakeTime = TimeOfDay(
        hour: prefs.getInt('wake_hour') ?? 7,
        minute: prefs.getInt('wake_minute') ?? 0,
      );
      _sleepTime = TimeOfDay(
        hour: prefs.getInt('sleep_hour') ?? 22,
        minute: prefs.getInt('sleep_minute') ?? 30,
      );
      _dailyGoalMl = prefs.getDouble('daily_goal_ml') ?? 2500;
      _goalController.text = _dailyGoalMl.round().toString();

      // Load preset states
      for (int i = 0; i < _presets.length; i++) {
        final key = 'preset_enabled_$i';
        if (prefs.containsKey(key)) {
          _presets[i]['enabled'] = prefs.getBool(key) ?? _presets[i]['enabled'];
        }
      }
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_enabled', _reminderEnabled);
    await prefs.setInt('reminder_interval', _intervalMinutes);
    await prefs.setInt('wake_hour', _wakeTime.hour);
    await prefs.setInt('wake_minute', _wakeTime.minute);
    await prefs.setInt('sleep_hour', _sleepTime.hour);
    await prefs.setInt('sleep_minute', _sleepTime.minute);

    final goalVal = double.tryParse(_goalController.text) ?? _dailyGoalMl;
    final clampedGoal = goalVal.clamp(500.0, 6000.0);
    await prefs.setDouble('daily_goal_ml', clampedGoal);
    setState(() => _dailyGoalMl = clampedGoal);

    for (int i = 0; i < _presets.length; i++) {
      await prefs.setBool('preset_enabled_$i', _presets[i]['enabled'] as bool);
    }

    // Re-schedule notifications
    if (_reminderEnabled) {
      final notifService = NotificationService();
      await notifService.initialize();
      await notifService.scheduleHydrationReminders(
        wakeHour: _wakeTime.hour,
        wakeMinute: _wakeTime.minute,
        sleepHour: _sleepTime.hour,
        sleepMinute: _sleepTime.minute,
        intervalMinutes: _intervalMinutes,
      );
    }

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Settings saved successfully',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _pickTime(
    TimeOfDay initial,
    Function(TimeOfDay) onChanged,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => onChanged(picked));
    }
  }

  int _estimateReminders() {
    int wakeMinutes = _wakeTime.hour * 60 + _wakeTime.minute;
    int sleepMinutes = _sleepTime.hour * 60 + _sleepTime.minute;
    if (sleepMinutes < wakeMinutes) sleepMinutes += 24 * 60;
    final awakeMinutes = sleepMinutes - wakeMinutes;
    return (awakeMinutes / _intervalMinutes).floor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: AppTheme.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          icon: Icons.track_changes_rounded,
                          iconColor: AppTheme.primary,
                          iconBg: const Color(0xFFF0F9FF),
                          title: 'Daily Hydration Goal',
                        ),
                        const SizedBox(height: 12),
                        _buildGoalCard(),
                        const SizedBox(height: 28),
                        _buildSectionHeader(
                          icon: Icons.wb_sunny_outlined,
                          iconColor: const Color(0xFFF59E0B),
                          iconBg: const Color(0xFFFFFBEB),
                          title: 'Wake & Sleep Schedule',
                        ),
                        const SizedBox(height: 12),
                        _buildScheduleCard(),
                        const SizedBox(height: 28),
                        _buildSectionHeader(
                          icon: Icons.notifications_outlined,
                          iconColor: const Color(0xFF8B5CF6),
                          iconBg: const Color(0xFFF5F3FF),
                          title: 'Reminder Frequency',
                        ),
                        const SizedBox(height: 12),
                        _buildRemindersCard(),
                        const SizedBox(height: 28),
                        _buildSectionHeader(
                          icon: Icons.local_drink_outlined,
                          iconColor: AppTheme.success,
                          iconBg: const Color(0xFFF0FDF4),
                          title: 'Drink Presets',
                        ),
                        const SizedBox(height: 12),
                        _buildPresetsCard(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                _buildSaveButton(),
              ],
            ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard() {
    final goalLiters = (_dailyGoalMl / 1000).toStringAsFixed(1);
    final glasses = (_dailyGoalMl / 250).round();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Goal',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 90,
                          child: TextField(
                            controller: _goalController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.manrope(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              hintText: '2500',
                              hintStyle: GoogleFonts.manrope(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.muted,
                              ),
                            ),
                            onChanged: (val) {
                              final parsed = double.tryParse(val);
                              if (parsed != null) {
                                setState(() => _dailyGoalMl = parsed);
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'ml',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _InfoChip(
                    label: '$goalLiters L',
                    icon: Icons.water_drop_outlined,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(height: 6),
                  _InfoChip(
                    label: '$glasses glasses',
                    icon: Icons.local_drink_outlined,
                    color: AppTheme.accent,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primary,
              inactiveTrackColor: AppTheme.border,
              thumbColor: AppTheme.primary,
              overlayColor: AppTheme.primary.withAlpha(30),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: _dailyGoalMl.clamp(500, 6000),
              min: 500,
              max: 6000,
              divisions: 110,
              onChanged: (val) {
                setState(() {
                  _dailyGoalMl = val.roundToDouble();
                  _goalController.text = _dailyGoalMl.round().toString();
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '500 ml',
                style: GoogleFonts.manrope(fontSize: 11, color: AppTheme.muted),
              ),
              Text(
                '6000 ml',
                style: GoogleFonts.manrope(fontSize: 11, color: AppTheme.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          _TimePickerRow(
            label: 'Wake Up Time',
            icon: Icons.wb_sunny_outlined,
            iconColor: const Color(0xFFF59E0B),
            iconBg: const Color(0xFFFFFBEB),
            time: _formatTime(_wakeTime),
            onTap: () => _pickTime(_wakeTime, (t) => _wakeTime = t),
            showDivider: true,
          ),
          _TimePickerRow(
            label: 'Bedtime',
            icon: Icons.bedtime_outlined,
            iconColor: const Color(0xFF8B5CF6),
            iconBg: const Color(0xFFF5F3FF),
            time: _formatTime(_sleepTime),
            onTap: () => _pickTime(_sleepTime, (t) => _sleepTime = t),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersCard() {
    final remindersCount = _estimateReminders();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable Reminders',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Get notified on iPhone & Apple Watch',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _reminderEnabled,
                onChanged: (val) => setState(() => _reminderEnabled = val),
                activeThumbColor: AppTheme.primary,
              ),
            ],
          ),
          if (_reminderEnabled) ...[
            const SizedBox(height: 20),
            Text(
              'REMINDER FREQUENCY',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.muted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: _intervals.map((item) {
                final isSelected = _intervalMinutes == item['value'];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: _intervals.last == item ? 0 : 6,
                    ),
                    child: GestureDetector(
                      onTap: () => setState(
                        () => _intervalMinutes = item['value'] as int,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary.withAlpha(20)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              item['label'] as String,
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              item['sub'] as String,
                              style: GoogleFonts.manrope(
                                fontSize: 9,
                                color: AppTheme.muted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    color: AppTheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'You\'ll receive ~$remindersCount reminders today',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPresetsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tap to toggle which presets appear in quick-log',
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.0,
            ),
            itemCount: _presets.length,
            itemBuilder: (_, i) {
              final preset = _presets[i];
              final enabled = preset['enabled'] as bool;
              final color = preset['color'] as Color;
              return GestureDetector(
                onTap: () => setState(() => _presets[i]['enabled'] = !enabled),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: enabled
                        ? color.withAlpha(20)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: enabled ? color : AppTheme.border,
                      width: enabled ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        preset['icon'] as IconData,
                        size: 26,
                        color: enabled ? color : AppTheme.muted,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        preset['label'] as String,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: enabled
                              ? AppTheme.textPrimary
                              : AppTheme.muted,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${preset['ml']} ml',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          color: enabled ? color : AppTheme.muted,
                        ),
                      ),
                      if (enabled)
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveSettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            disabledBackgroundColor: AppTheme.primaryMuted,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Save Settings',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

class _TimePickerRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String time;
  final VoidCallback onTap;
  final bool showDivider;

  const _TimePickerRow({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.time,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        time,
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.muted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            indent: 18,
            endIndent: 18,
            color: AppTheme.border,
          ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
