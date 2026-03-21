// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutSetModelAdapter extends TypeAdapter<WorkoutSetModel> {
  @override
  final int typeId = 2;

  @override
  WorkoutSetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSetModel(
      setNumber: fields[0] as int,
      reps: fields[1] as int,
      weight: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSetModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.setNumber)
      ..writeByte(1)
      ..write(obj.reps)
      ..writeByte(2)
      ..write(obj.weight);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkoutModelAdapter extends TypeAdapter<WorkoutModel> {
  @override
  final int typeId = 1;

  @override
  WorkoutModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      muscleGroup: fields[2] as String,
      exerciseName: fields[3] as String,
      sets: (fields[4] as List).cast<WorkoutSetModel>(),
      notes: fields[5] as String?,
      xpEarned: fields[6] as int,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.muscleGroup)
      ..writeByte(3)
      ..write(obj.exerciseName)
      ..writeByte(4)
      ..write(obj.sets)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.xpEarned)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
