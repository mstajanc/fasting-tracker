import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/fast_record.dart';
import '../services/storage_service.dart';
import '../widgets/fasting_ring.dart';
import '../widgets/goal_selector.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storage;

  const HomeScreen({super.key, required this.storage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  int _selectedGoal = 16;
  FastRecord? _activeFast;

  @override
  void initState() {
    super.initState();
    _activeFast = widget.storage.activeFast;
    if (_activeFast != null) {
      _selectedGoal = _activeFast!.goalHours;
    }
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _startFast() {
    final record = FastRecord(
      startTime: DateTime.now(),
      goalHours: _selectedGoal,
    );
    widget.storage.saveFast(record);
    setState(() {
      _activeFast = record;
    });
  }

  void _stopFast() {
    if (_activeFast == null) return;
    _activeFast!.endTime = DateTime.now();
    widget.storage.saveFast(_activeFast!);
    _timer?.cancel();
    setState(() {
      _activeFast = null;
    });
    _startTimer();
  }

  void _confirmStop() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('End Fast?', style: TextStyle(color: Colors.white)),
        content: Text(
          'You have been fasting for ${_activeFast?.formattedDuration ?? "00:00:00"}. End this fast?',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _stopFast();
            },
            child:
                const Text('End Fast', style: TextStyle(color: Color(0xFFEF5350))),
          ),
        ],
      ),
    );
  }

  Future<void> _editStartTime() async {
    if (_activeFast == null) return;
    final picked = await _pickDateTime(_activeFast!.startTime);
    if (picked == null) return;
    if (picked.isAfter(DateTime.now())) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start time cannot be in the future'),
          backgroundColor: Color(0xFFEF5350),
        ),
      );
      return;
    }
    setState(() {
      _activeFast!.startTime = picked;
    });
    widget.storage.saveFast(_activeFast!);
  }

  Future<void> _editEatingStartTime() async {
    final completed = widget.storage.completedFasts;
    if (completed.isEmpty) return;
    final lastFast = completed.first;
    if (lastFast.endTime == null) return;

    final picked = await _pickDateTime(lastFast.endTime!);
    if (picked == null) return;
    if (picked.isBefore(lastFast.startTime)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Eating start cannot be before fast start'),
          backgroundColor: Color(0xFFEF5350),
        ),
      );
      return;
    }
    if (picked.isAfter(DateTime.now())) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Time cannot be in the future'),
          backgroundColor: Color(0xFFEF5350),
        ),
      );
      return;
    }
    lastFast.endTime = picked;
    widget.storage.saveFast(lastFast);
    setState(() {});
  }

  Future<DateTime?> _pickDateTime(DateTime current) async {
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF4CAF50),
            surface: Color(0xFF1E1E1E),
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF4CAF50),
            surface: Color(0xFF1E1E1E),
          ),
        ),
        child: child!,
      ),
    );
    if (time == null || !mounted) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  /// Returns the last completed fast's eating window info, or null.
  _EatingWindowInfo? get _eatingWindowInfo {
    if (_activeFast != null) return null;
    final completed = widget.storage.completedFasts;
    if (completed.isEmpty) return null;
    final lastFast = completed.first; // already sorted newest first
    if (lastFast.endTime == null) return null;

    final eatingWindowHours = 24 - lastFast.goalHours;
    final eatingEnd = lastFast.endTime!.add(Duration(hours: eatingWindowHours));
    final now = DateTime.now();
    final remaining = eatingEnd.difference(now);

    if (remaining.isNegative) return null; // eating window has passed

    final totalEatingSeconds = Duration(hours: eatingWindowHours).inSeconds;
    final elapsedEatingSeconds = now.difference(lastFast.endTime!).inSeconds;
    final progress = (elapsedEatingSeconds / totalEatingSeconds).clamp(0.0, 1.0);

    return _EatingWindowInfo(
      elapsed: _formatDuration(now.difference(lastFast.endTime!)),
      remaining: _formatDuration(remaining),
      totalHours: eatingWindowHours,
      progress: progress,
      startTime: lastFast.endTime!,
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.abs();
    final minutes = d.inMinutes.remainder(60).abs();
    final seconds = d.inSeconds.remainder(60).abs();
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _activeFast != null;
    final progress = _activeFast?.progress ?? 0.0;
    final elapsed = _activeFast?.formattedDuration ?? '00:00:00';
    final eatingInfo = _eatingWindowInfo;
    final timeFmt = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Fasting Tracker',
          style: TextStyle(
            fontWeight: FontWeight.w300,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(storage: widget.storage),
                ),
              );
              setState(() {
                _activeFast = widget.storage.activeFast;
                if (_activeFast != null) {
                  _selectedGoal = _activeFast!.goalHours;
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              if (isActive)
                FastingRing(
                  progress: progress,
                  elapsed: elapsed,
                  goal: '${_selectedGoal}h',
                  isActive: true,
                  mode: RingMode.fasting,
                )
              else if (eatingInfo != null)
                FastingRing(
                  progress: eatingInfo.progress,
                  elapsed: eatingInfo.elapsed,
                  goal: '${eatingInfo.totalHours}h',
                  isActive: true,
                  mode: RingMode.eating,
                  remaining: eatingInfo.remaining,
                )
              else
                FastingRing(
                  progress: 0,
                  elapsed: '00:00:00',
                  goal: '${_selectedGoal}h',
                  isActive: false,
                  mode: RingMode.fasting,
                ),
              const SizedBox(height: 16),
              // Editable start time chip
              if (isActive)
                _buildTimeChip(
                  icon: Icons.play_arrow_rounded,
                  label: 'Started ${timeFmt.format(_activeFast!.startTime)}',
                  onTap: _editStartTime,
                  color: const Color(0xFFEF5350),
                )
              else if (eatingInfo != null)
                _buildTimeChip(
                  icon: Icons.restaurant,
                  label: 'Eating since ${timeFmt.format(eatingInfo.startTime)}',
                  onTap: _editEatingStartTime,
                  color: const Color(0xFF42A5F5),
                ),
              const SizedBox(height: 24),
              GoalSelector(
                selectedGoal: _selectedGoal,
                onChanged: (goal) => setState(() => _selectedGoal = goal),
                enabled: !isActive && eatingInfo == null,
              ),
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: isActive || eatingInfo == null
                    ? _buildActionButton(isActive)
                    : _buildEatingActions(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color.withValues(alpha: 0.7)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit_outlined, size: 12, color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(bool isActive) {
    return GestureDetector(
      onTap: isActive ? _confirmStop : _startFast,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 180,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: isActive
              ? const Color(0xFFEF5350).withValues(alpha: 0.15)
              : const Color(0xFF4CAF50).withValues(alpha: 0.15),
          border: Border.all(
            color: isActive
                ? const Color(0xFFEF5350).withValues(alpha: 0.5)
                : const Color(0xFF4CAF50).withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          isActive ? 'STOP FAST' : 'START FAST',
          style: TextStyle(
            color: isActive ? const Color(0xFFEF5350) : const Color(0xFF4CAF50),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildEatingActions() {
    return GestureDetector(
      onTap: _startFast,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 200,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
          border: Border.all(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: const Text(
          'START NEW FAST',
          style: TextStyle(
            color: Color(0xFF4CAF50),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

class _EatingWindowInfo {
  final String elapsed;
  final String remaining;
  final int totalHours;
  final double progress;
  final DateTime startTime;

  _EatingWindowInfo({
    required this.elapsed,
    required this.remaining,
    required this.totalHours,
    required this.progress,
    required this.startTime,
  });
}
