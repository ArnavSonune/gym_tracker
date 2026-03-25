// GENERATED CODE - DO NOT MODIFY BY HAND
// Manually updated to include HiveField(10) passwordHash and HiveField(11) isLoggedIn

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
      // fields 10 and 11 are nullable — old records won't have them
      passwordHash: fields[10] as String?,
      isLoggedIn: fields[11] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.isLoggedIn);
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
