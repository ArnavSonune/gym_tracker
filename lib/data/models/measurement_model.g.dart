// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MeasurementModelAdapter extends TypeAdapter<MeasurementModel> {
  @override
  final int typeId = 6;

  @override
  MeasurementModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MeasurementModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      chest: fields[2] as double?,
      waist: fields[3] as double?,
      shoulders: fields[4] as double?,
      arms: fields[5] as double?,
      forearms: fields[6] as double?,
      thighs: fields[7] as double?,
      calves: fields[8] as double?,
      neck: fields[9] as double?,
      bodyFatPercentage: fields[10] as double?,
      notes: fields[11] as String?,
      createdAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MeasurementModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.chest)
      ..writeByte(3)
      ..write(obj.waist)
      ..writeByte(4)
      ..write(obj.shoulders)
      ..writeByte(5)
      ..write(obj.arms)
      ..writeByte(6)
      ..write(obj.forearms)
      ..writeByte(7)
      ..write(obj.thighs)
      ..writeByte(8)
      ..write(obj.calves)
      ..writeByte(9)
      ..write(obj.neck)
      ..writeByte(10)
      ..write(obj.bodyFatPercentage)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeasurementModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
