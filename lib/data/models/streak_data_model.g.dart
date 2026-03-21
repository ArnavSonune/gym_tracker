// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StreakDataModelAdapter extends TypeAdapter<StreakDataModel> {
  @override
  final int typeId = 9;

  @override
  StreakDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StreakDataModel(
      currentStreak: fields[0] as int,
      highestStreak: fields[1] as int,
      lastWorkoutDate: fields[2] as DateTime?,
      workoutDates: (fields[3] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, StreakDataModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.currentStreak)
      ..writeByte(1)
      ..write(obj.highestStreak)
      ..writeByte(2)
      ..write(obj.lastWorkoutDate)
      ..writeByte(3)
      ..write(obj.workoutDates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreakDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
