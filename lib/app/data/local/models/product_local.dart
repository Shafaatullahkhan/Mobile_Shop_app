import 'package:hive/hive.dart';

part 'product_local.g.dart';

@HiveType(typeId: 0)
class ProductLocal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final int stock;

  @HiveField(5)
  final String imageUrl;

  @HiveField(6)
  final String category;

  @HiveField(7)
  final String brand;

  @HiveField(8)
  final Map<String, dynamic> specifications;

  @HiveField(9)
  final DateTime lastSynced;

  @HiveField(10)
  final bool isFavorite;

  ProductLocal({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.category,
    required this.brand,
    required this.specifications,
    required this.lastSynced,
    this.isFavorite = false,
  });

  // Convert from Firebase Product model
  factory ProductLocal.fromRemote(Map<String, dynamic> remoteProduct, String id) {
    return ProductLocal(
      id: id,
      name: remoteProduct['name'] ?? '',
      description: remoteProduct['description'] ?? '',
      price: (remoteProduct['price'] ?? 0.0).toDouble(),
      stock: remoteProduct['stock'] ?? 0,
      imageUrl: remoteProduct['imageUrl'] ?? '',
      category: remoteProduct['category'] ?? 'All',
      brand: remoteProduct['brand'] ?? '',
      specifications: Map<String, dynamic>.from(remoteProduct['specifications'] ?? {}),
      lastSynced: DateTime.now(),
      isFavorite: false,
    );
  }

  // Convert to Firebase Product model format
  Map<String, dynamic> toRemote() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'category': category,
      'brand': brand,
      'specifications': specifications,
    };
  }

  // Create copy with updated fields
  ProductLocal copyWith({
    String? name,
    String? description,
    double? price,
    int? stock,
    String? imageUrl,
    String? category,
    String? brand,
    Map<String, dynamic>? specifications,
    DateTime? lastSynced,
    bool? isFavorite,
  }) {
    return ProductLocal(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      specifications: specifications ?? this.specifications,
      lastSynced: lastSynced ?? this.lastSynced,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
