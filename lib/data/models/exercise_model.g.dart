// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseModelAdapter extends TypeAdapter<ExerciseModel> {
  @override
  final int typeId = 4;

  @override
  ExerciseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseModel(
      id: fields[0] as String,
      name: fields[1] as String,
      muscleGroup: fields[2] as String,
      isCustom: fields[3] as bool,
      createdAt: fields[4] as DateTime,
      prWeight: fields[5] as double,
      prAchievedDate: fields[6] as DateTime?,
      bestVolume: fields[7] as double,
      bestVolumeDate: fields[8] as DateTime?,
      lastPerformed: fields[9] as DateTime?,
      totalSessions: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.muscleGroup)
      ..writeByte(3)
      ..write(obj.isCustom)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.prWeight)
      ..writeByte(6)
      ..write(obj.prAchievedDate)
      ..writeByte(7)
      ..write(obj.bestVolume)
      ..writeByte(8)
      ..write(obj.bestVolumeDate)
      ..writeByte(9)
      ..write(obj.lastPerformed)
      ..writeByte(10)
      ..write(obj.totalSessions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
