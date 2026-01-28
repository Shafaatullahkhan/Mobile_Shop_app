// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_local.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductLocalAdapter extends TypeAdapter<ProductLocal> {
  @override
  final int typeId = 0;

  @override
  ProductLocal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductLocal(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      price: fields[3] as double,
      stock: fields[4] as int,
      imageUrl: fields[5] as String,
      category: fields[6] as String,
      brand: fields[7] as String,
      specifications: (fields[8] as Map).cast<String, dynamic>(),
      lastSynced: fields[9] as DateTime,
      isFavorite: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ProductLocal obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.stock)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.brand)
      ..writeByte(8)
      ..write(obj.specifications)
      ..writeByte(9)
      ..write(obj.lastSynced)
      ..writeByte(10)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductLocalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
