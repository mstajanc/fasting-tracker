import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/fast_record.dart';

class HistoryChart extends StatefulWidget {
  final List<FastRecord> fasts;

  const HistoryChart({super.key, required this.fasts});

  @override
  State<HistoryChart> createState() => _HistoryChartState();
}

class _HistoryChartState extends State<HistoryChart> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Build daily data
    final dailyHours = <DateTime, double>{};
    final dailyGoals = <DateTime, int>{};
    for (int i = 0; i < _selectedDays; i++) {
      final day = today.subtract(Duration(days: _selectedDays - 1 - i));
      dailyHours[day] = 0;
      dailyGoals[day] = 0;
    }

    for (final fast in widget.fasts) {
      if (fast.endTime == null) continue;
      final fastDay = DateTime(
          fast.startTime.year, fast.startTime.month, fast.startTime.day);
      if (dailyHours.containsKey(fastDay)) {
        dailyHours[fastDay] =
            dailyHours[fastDay]! + fast.duration.inMinutes / 60.0;
        if (fast.goalHours > dailyGoals[fastDay]!) {
          dailyGoals[fastDay] = fast.goalHours;
        }
      }
    }

    final days = dailyHours.keys.toList()..sort();
    final maxHours = dailyHours.values.fold<double>(0, max).clamp(1.0, 24.0);
    final chartMax = ((maxHours / 4).ceil() * 4).toDouble().clamp(4.0, 24.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fasting Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _buildPeriodSelector(),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: days.isEmpty
                ? Center(
                    child: Text(
                      'No data yet',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4)),
                    ),
                  )
                : _buildChart(days, dailyHours, dailyGoals, chartMax),
          ),
          const SizedBox(height: 8),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [7, 14, 30].map((days) {
        final isSelected = days == _selectedDays;
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: GestureDetector(
            onTap: () => setState(() => _selectedDays = days),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Text(
                '${days}d',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChart(List<DateTime> days, Map<DateTime, double> dailyHours,
      Map<DateTime, int> dailyGoals, double chartMax) {
    final dayFmt = DateFormat('E');
    final dateFmt = DateFormat('d/M');

    return LayoutBuilder(builder: (context, constraints) {
      final barWidth = _selectedDays <= 7
          ? 24.0
          : _selectedDays <= 14
              ? 14.0
              : 8.0;
      final spacing =
          (constraints.maxWidth - days.length * barWidth) / (days.length + 1);

      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: days.map((day) {
          final hours = dailyHours[day]!;
          final goal = dailyGoals[day]!;
          final barHeight = (hours / chartMax) * 140;

          Color barColor;
          if (hours == 0) {
            barColor = Colors.white.withValues(alpha: 0.06);
          } else if (goal > 0 && hours >= goal) {
            barColor = const Color(0xFF4CAF50);
          } else if (goal > 0 && hours >= goal * 0.75) {
            barColor = const Color(0xFFFFC107);
          } else {
            barColor = const Color(0xFFEF5350);
          }

          final isToday = day ==
              DateTime(
                  DateTime.now().year, DateTime.now().month, DateTime.now().day);
          final label =
              _selectedDays <= 14 ? dayFmt.format(day) : dateFmt.format(day);

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (hours > 0 && _selectedDays <= 14)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${hours.toStringAsFixed(hours == hours.roundToDouble() ? 0 : 1)}h',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 9,
                      ),
                    ),
                  ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  width: barWidth,
                  height: hours > 0 ? barHeight.clamp(4.0, 140.0) : 4.0,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(barWidth / 2),
                    boxShadow: hours > 0
                        ? [
                            BoxShadow(
                              color: barColor.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _selectedDays <= 14 ? label.substring(0, min(3, label.length)) : label,
                  style: TextStyle(
                    color: isToday
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.35),
                    fontSize: _selectedDays <= 14 ? 10 : 8,
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(const Color(0xFF4CAF50), 'Goal reached'),
        const SizedBox(width: 16),
        _legendDot(const Color(0xFFFFC107), 'Near goal'),
        const SizedBox(width: 16),
        _legendDot(const Color(0xFFEF5350), 'Below goal'),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
