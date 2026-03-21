// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhotoLogModelAdapter extends TypeAdapter<PhotoLogModel> {
  @override
  final int typeId = 7;

  @override
  PhotoLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PhotoLogModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      localFilePath: fields[2] as String,
      notes: fields[3] as String?,
      createdAt: fields[4] as DateTime,
      photoType: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PhotoLogModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.localFilePath)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.photoType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
