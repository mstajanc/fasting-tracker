import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/fast_record.dart';
import '../services/storage_service.dart';
import 'edit_fast_screen.dart';

class HistoryScreen extends StatefulWidget {
  final StorageService storage;

  const HistoryScreen({super.key, required this.storage});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final fasts = widget.storage.completedFasts;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('History',
            style: TextStyle(fontWeight: FontWeight.w300, letterSpacing: 1)),
        centerTitle: true,
      ),
      body: fasts.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history,
                      size: 64, color: Colors.white.withValues(alpha: 0.15)),
                  const SizedBox(height: 16),
                  Text(
                    'No completed fasts yet',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: fasts.length,
              itemBuilder: (context, index) =>
                  _FastCard(record: fasts[index], storage: widget.storage, onEdited: () => setState(() {})),
            ),
    );
  }
}

class _FastCard extends StatelessWidget {
  final FastRecord record;
  final StorageService storage;
  final VoidCallback onEdited;

  const _FastCard({required this.record, required this.storage, required this.onEdited});

  Color get _statusColor {
    if (record.goalReached) return const Color(0xFF4CAF50);
    if (record.progress >= 0.75) return const Color(0xFFFFC107);
    return const Color(0xFFEF5350);
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d, yyyy');
    final timeFmt = DateFormat('HH:mm');
    final duration = record.duration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return GestureDetector(
      onTap: () async {
        final edited = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => EditFastScreen(record: record, storage: storage),
          ),
        );
        if (edited == true) onEdited();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFmt.format(record.startTime),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${timeFmt.format(record.startTime)} → ${record.endTime != null ? timeFmt.format(record.endTime!) : '—'}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${hours}h ${minutes}m',
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '/ ${record.goalHours}h goal',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.2), size: 20),
          ],
        ),
      ),
    );
  }
}
