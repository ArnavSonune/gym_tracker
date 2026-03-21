// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cardio_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardioModelAdapter extends TypeAdapter<CardioModel> {
  @override
  final int typeId = 3;

  @override
  CardioModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardioModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      cardioType: fields[2] as String,
      durationMinutes: fields[3] as int,
      distanceKm: fields[4] as double?,
      caloriesBurned: fields[5] as int?,
      notes: fields[6] as String?,
      xpEarned: fields[7] as int,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CardioModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.cardioType)
      ..writeByte(3)
      ..write(obj.durationMinutes)
      ..writeByte(4)
      ..write(obj.distanceKm)
      ..writeByte(5)
      ..write(obj.caloriesBurned)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.xpEarned)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardioModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
