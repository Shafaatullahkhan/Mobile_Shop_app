// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_local.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteLocalAdapter extends TypeAdapter<FavoriteLocal> {
  @override
  final int typeId = 3;

  @override
  FavoriteLocal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteLocal(
      userId: fields[0] as String,
      productId: fields[1] as String,
      addedAt: fields[2] as DateTime,
      lastSynced: fields[3] as DateTime,
      isPendingSync: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteLocal obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.addedAt)
      ..writeByte(3)
      ..write(obj.lastSynced)
      ..writeByte(4)
      ..write(obj.isPendingSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteLocalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
