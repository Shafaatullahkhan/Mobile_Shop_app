class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String imageUrl;
  final String category;
  final String brand;
  final Map<String, dynamic> specifications;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    this.category = 'All',
    this.brand = '',
    this.specifications = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      stock: map['stock'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? 'All',
      brand: map['brand'] ?? '',
      specifications: Map<String, dynamic>.from(map['specifications'] ?? {}),
    );
  }
}
