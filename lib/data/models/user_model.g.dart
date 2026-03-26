// GENERATED CODE - DO NOT MODIFY BY HAND
// Manually updated to include fields 12 (gymExperienceLevel) and 13 (profilePhotoPath)

part of 'user_model.dart';

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      name: fields[1] as String,
      totalXP: fields[2] as int,
      currentLevel: fields[3] as int,
      createdAt: fields[4] as DateTime,
      startingWeight: fields[5] as double?,
      targetWeight: fields[6] as double?,
      age: fields[7] as int?,
      heightCm: fields[8] as double?,
      isMale: fields[9] as bool,
      passwordHash: fields[10] as String?,
      isLoggedIn: fields[11] as bool? ?? false,
      gymExperienceLevel: fields[12] as int? ?? 0,
      profilePhotoPath: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.totalXP)
      ..writeByte(3)
      ..write(obj.currentLevel)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.startingWeight)
      ..writeByte(6)
      ..write(obj.targetWeight)
      ..writeByte(7)
      ..write(obj.age)
      ..writeByte(8)
      ..write(obj.heightCm)
      ..writeByte(9)
      ..write(obj.isMale)
      ..writeByte(10)
      ..write(obj.passwordHash)
      ..writeByte(11)
      ..write(obj.isLoggedIn)
      ..writeByte(12)
      ..write(obj.gymExperienceLevel)
      ..writeByte(13)
      ..write(obj.profilePhotoPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
