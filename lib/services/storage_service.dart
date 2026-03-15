import 'package:hive_flutter/hive_flutter.dart';
import '../models/fast_record.dart';

class StorageService {
  static const String _boxName = 'fasts';
  late Box<FastRecord> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(FastRecordAdapter());
    _box = await Hive.openBox<FastRecord>(_boxName);
  }

  Box<FastRecord> get box => _box;

  Future<void> saveFast(FastRecord record) async {
    if (record.isInBox) {
      await record.save();
    } else {
      await _box.add(record);
    }
  }

  Future<void> deleteFast(FastRecord record) async {
    await record.delete();
  }

  FastRecord? get activeFast {
    try {
      return _box.values.firstWhere((r) => r.isActive);
    } catch (_) {
      return null;
    }
  }

  List<FastRecord> get completedFasts {
    final fasts = _box.values.where((r) => !r.isActive).toList();
    fasts.sort((a, b) => b.startTime.compareTo(a.startTime));
    return fasts;
  }
}
