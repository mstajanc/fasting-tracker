import 'dart:async';
import 'package:flutter/material.dart';
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
      _startTimer();
    }
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
    _startTimer();
  }

  void _stopFast() {
    if (_activeFast == null) return;
    _activeFast!.endTime = DateTime.now();
    widget.storage.saveFast(_activeFast!);
    _timer?.cancel();
    setState(() {
      _activeFast = null;
    });
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

  @override
  Widget build(BuildContext context) {
    final isActive = _activeFast != null;
    final progress = _activeFast?.progress ?? 0.0;
    final elapsed = _activeFast?.formattedDuration ?? '00:00:00';

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
              // Refresh in case active fast was edited
              setState(() {
                _activeFast = widget.storage.activeFast;
                if (_activeFast != null) {
                  _selectedGoal = _activeFast!.goalHours;
                  _startTimer();
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
              FastingRing(
                progress: progress,
                elapsed: elapsed,
                goal: '${_selectedGoal}h',
                isActive: isActive,
              ),
              const SizedBox(height: 48),
              GoalSelector(
                selectedGoal: _selectedGoal,
                onChanged: (goal) => setState(() => _selectedGoal = goal),
                enabled: !isActive,
              ),
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: _buildActionButton(isActive),
              ),
            ],
          ),
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
}
