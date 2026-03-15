// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fast_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FastRecordAdapter extends TypeAdapter<FastRecord> {
  @override
  final int typeId = 0;

  @override
  FastRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FastRecord(
      startTime: fields[0] as DateTime,
      endTime: fields[1] as DateTime?,
      goalHours: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FastRecord obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.startTime)
      ..writeByte(1)
      ..write(obj.endTime)
      ..writeByte(2)
      ..write(obj.goalHours);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FastRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
