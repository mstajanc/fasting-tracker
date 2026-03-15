import 'package:hive/hive.dart';

part 'fast_record.g.dart';

@HiveType(typeId: 0)
class FastRecord extends HiveObject {
  @HiveField(0)
  DateTime startTime;

  @HiveField(1)
  DateTime? endTime;

  @HiveField(2)
  int goalHours;

  FastRecord({
    required this.startTime,
    this.endTime,
    required this.goalHours,
  });

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  bool get isActive => endTime == null;

  double get progress {
    final goalDuration = Duration(hours: goalHours);
    if (goalDuration.inSeconds == 0) return 0;
    return (duration.inSeconds / goalDuration.inSeconds).clamp(0.0, 2.0);
  }

  bool get goalReached => duration >= Duration(hours: goalHours);

  String get formattedDuration {
    final d = duration;
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
