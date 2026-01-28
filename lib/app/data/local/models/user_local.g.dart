// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_local.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserLocalAdapter extends TypeAdapter<UserLocal> {
  @override
  final int typeId = 2;

  @override
  UserLocal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserLocal(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      photoURL: fields[3] as String?,
      role: fields[4] as String,
      lastSynced: fields[5] as DateTime,
      isLoggedIn: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserLocal obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.photoURL)
      ..writeByte(4)
      ..write(obj.role)
      ..writeByte(5)
      ..write(obj.lastSynced)
      ..writeByte(6)
      ..write(obj.isLoggedIn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLocalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
