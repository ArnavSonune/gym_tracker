// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeightLogModelAdapter extends TypeAdapter<WeightLogModel> {
  @override
  final int typeId = 5;

  @override
  WeightLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeightLogModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      weightKg: fields[2] as double,
      notes: fields[3] as String?,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WeightLogModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.weightKg)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
