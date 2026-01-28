// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_local.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderLocalAdapter extends TypeAdapter<OrderLocal> {
  @override
  final int typeId = 1;

  @override
  OrderLocal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderLocal(
      id: fields[0] as String,
      userId: fields[1] as String,
      userName: fields[2] as String,
      items: (fields[3] as List).cast<ProductLocal>(),
      totalAmount: fields[4] as double,
      status: fields[5] as String,
      timestamp: fields[6] as DateTime,
      expectedDeliveryTime: fields[7] as DateTime?,
      lastSynced: fields[8] as DateTime,
      isPendingSync: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, OrderLocal obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.userName)
      ..writeByte(3)
      ..write(obj.items)
      ..writeByte(4)
      ..write(obj.totalAmount)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.expectedDeliveryTime)
      ..writeByte(8)
      ..write(obj.lastSynced)
      ..writeByte(9)
      ..write(obj.isPendingSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderLocalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
