import 'package:flutter/material.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_stage.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_widgets.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';

class CustomOpeningTimeScreen extends StatefulWidget {
  const CustomOpeningTimeScreen({super.key, required this.initialTime});

  final DateTime initialTime;

  @override
  State<CustomOpeningTimeScreen> createState() =>
      _CustomOpeningTimeScreenState();
}

class _CustomOpeningTimeScreenState extends State<CustomOpeningTimeScreen> {
  late DateTime _visibleMonth;
  late DateTime _selectedDay;
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(widget.initialTime.year, widget.initialTime.month);
    _selectedDay = DateTime(
      widget.initialTime.year,
      widget.initialTime.month,
      widget.initialTime.day,
    );
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
  }

  @override
  Widget build(BuildContext context) {
    return CapsuleStage(
      child: Stack(
        children: [
          CapsuleTopBar(
            title: 'Custom Time',
            onBack: () => Navigator.of(context).pop(),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final contentWidth = MorrowlyFrameGuard.contentWidth(
                width,
                maxWidth: 430,
                phoneGutter: 24,
              );
              final side = (width - contentWidth) / 2;
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  side,
                  MorrowlyFrameGuard.topClearance(
                    context,
                    minimum: 118,
                    extra: 48,
                  ),
                  side,
                  MorrowlyFrameGuard.bottomClearance(
                    context,
                    minimum: 28,
                    extra: 18,
                  ),
                ),
                child: Column(
                  children: [
                    _CalendarPanel(
                      visibleMonth: _visibleMonth,
                      selectedDay: _selectedDay,
                      onMonthChanged: (offset) {
                        setState(() {
                          _visibleMonth = DateTime(
                            _visibleMonth.year,
                            _visibleMonth.month + offset,
                          );
                        });
                      },
                      onDaySelected: (day) {
                        setState(() => _selectedDay = day);
                      },
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select time',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _TimeDial(
                      hour: _selectedHour,
                      minute: _selectedMinute,
                      onHourChanged: (value) {
                        setState(() => _selectedHour = value);
                      },
                      onMinuteChanged: (value) {
                        setState(() => _selectedMinute = value);
                      },
                    ),
                    const Spacer(),
                    CapsuleGlowButton(
                      label: 'Confirm',
                      width: contentWidth * 0.84,
                      onPressed: () {
                        Navigator.of(context).pop(
                          DateTime(
                            _selectedDay.year,
                            _selectedDay.month,
                            _selectedDay.day,
                            _selectedHour,
                            _selectedMinute,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CalendarPanel extends StatelessWidget {
  const _CalendarPanel({
    required this.visibleMonth,
    required this.selectedDay,
    required this.onMonthChanged,
    required this.onDaySelected,
  });

  final DateTime visibleMonth;
  final DateTime selectedDay;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final days = _monthCells(visibleMonth);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF4E4053),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => onMonthChanged(-1),
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xFFBC6DFF),
                ),
              ),
              Text(
                '${visibleMonth.year}/${visibleMonth.month.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                onPressed: () => onMonthChanged(1),
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFBC6DFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              for (final day in [
                'Mon',
                'Tue',
                'Wed',
                'Thu',
                'Fri',
                'Sat',
                'Sun',
              ])
                Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFBAA9C1),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              if (day == null) {
                return const SizedBox.shrink();
              }
              final selected = _sameDay(day, selectedDay);
              final dim = day.month != visibleMonth.month;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onDaySelected(day),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFBF73FF)
                        : dim
                        ? const Color(0xFF4B3B4F)
                        : const Color(0xFF775B82),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: dim ? 0.28 : 0.78),
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static List<DateTime?> _monthCells(DateTime visibleMonth) {
    final first = DateTime(visibleMonth.year, visibleMonth.month);
    final startPadding = first.weekday - 1;
    final daysInMonth = DateTime(
      visibleMonth.year,
      visibleMonth.month + 1,
      0,
    ).day;
    final cells = <DateTime?>[
      for (var index = 0; index < startPadding; index++) null,
      for (var day = 1; day <= daysInMonth; day++)
        DateTime(visibleMonth.year, visibleMonth.month, day),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }
}

class _TimeDial extends StatelessWidget {
  const _TimeDial({
    required this.hour,
    required this.minute,
    required this.onHourChanged,
    required this.onMinuteChanged,
  });

  final int hour;
  final int minute;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TimeBox(
          value: hour,
          onMinus: () => onHourChanged((hour - 1) % 24),
          onPlus: () => onHourChanged((hour + 1) % 24),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            ':',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        _TimeBox(
          value: minute,
          onMinus: () => onMinuteChanged((minute - 5) % 60),
          onPlus: () => onMinuteChanged((minute + 5) % 60),
        ),
      ],
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFBF73FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onMinus,
            child: const Icon(Icons.remove_rounded, color: Colors.white),
          ),
          Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPlus,
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
