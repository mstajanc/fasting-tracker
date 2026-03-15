import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/fast_record.dart';
import '../services/storage_service.dart';

class EditFastScreen extends StatefulWidget {
  final FastRecord record;
  final StorageService storage;

  const EditFastScreen({
    super.key,
    required this.record,
    required this.storage,
  });

  @override
  State<EditFastScreen> createState() => _EditFastScreenState();
}

class _EditFastScreenState extends State<EditFastScreen> {
  late DateTime _startTime;
  late DateTime? _endTime;
  late int _goalHours;

  static const _goals = [16, 18, 20, 24];

  @override
  void initState() {
    super.initState();
    _startTime = widget.record.startTime;
    _endTime = widget.record.endTime;
    _goalHours = widget.record.goalHours;
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final current = isStart ? _startTime : (_endTime ?? DateTime.now());

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
    if (date == null || !mounted) return;

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
    if (time == null || !mounted) return;

    final picked = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  void _save() {
    if (_endTime != null && _endTime!.isBefore(_startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Color(0xFFEF5350),
        ),
      );
      return;
    }

    widget.record.startTime = _startTime;
    widget.record.endTime = _endTime;
    widget.record.goalHours = _goalHours;
    widget.storage.saveFast(widget.record);
    Navigator.pop(context, true);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Fast?', style: TextStyle(color: Colors.white)),
        content: Text(
          'This will permanently remove this fasting record.',
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
              widget.storage.deleteFast(widget.record);
              Navigator.pop(context, true);
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFEF5350))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy – HH:mm');
    final duration = (_endTime ?? DateTime.now()).difference(_startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Edit Fast',
            style: TextStyle(fontWeight: FontWeight.w300, letterSpacing: 1)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF5350)),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildTimeCard(
            label: 'Start Time',
            value: fmt.format(_startTime),
            onTap: () => _pickDateTime(isStart: true),
          ),
          const SizedBox(height: 16),
          _buildTimeCard(
            label: 'End Time',
            value: _endTime != null ? fmt.format(_endTime!) : 'Still fasting',
            onTap: () => _pickDateTime(isStart: false),
          ),
          const SizedBox(height: 24),
          Text(
            'Duration: ${hours}h ${minutes}m',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Fasting Goal',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.5),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: _goals.map((g) {
              final selected = g == _goalHours;
              return ChoiceChip(
                label: Text('${g}h'),
                selected: selected,
                onSelected: (_) => setState(() => _goalHours = g),
                selectedColor: Colors.white.withValues(alpha: 0.15),
                backgroundColor: const Color(0xFF1E1E1E),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 48),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                foregroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                  side: BorderSide(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.5)),
                ),
                elevation: 0,
              ),
              child: const Text(
                'SAVE CHANGES',
                style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.4),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_outlined,
                color: Colors.white.withValues(alpha: 0.3), size: 20),
          ],
        ),
      ),
    );
  }
}
