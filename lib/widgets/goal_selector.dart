import 'package:flutter/material.dart';

class GoalSelector extends StatelessWidget {
  final int selectedGoal;
  final ValueChanged<int> onChanged;
  final bool enabled;

  static const goals = [12, 16, 18, 20, 24];

  static String _goalLabel(int hours) {
    final eating = 24 - hours;
    return '${hours}h fast · ${eating}h eating';
  }

  const GoalSelector({
    super.key,
    required this.selectedGoal,
    required this.onChanged,
    this.enabled = true,
  });

  void _showGoalPicker(BuildContext context) {
    if (!enabled) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'SELECT FASTING GOAL',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.5),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            ...goals.map((hours) {
              final isSelected = hours == selectedGoal;
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                title: Text(
                  '${hours}h',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
                    fontSize: 18,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                subtitle: Text(
                  _goalLabel(hours),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 13,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 22)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  onChanged(hours);
                },
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showGoalPicker(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: enabled
                ? Colors.white.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${selectedGoal}h goal',
              style: TextStyle(
                color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.5),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.expand_more,
              color: enabled
                  ? Colors.white.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
