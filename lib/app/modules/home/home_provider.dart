import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/local/models/product_local.dart';

class HomeProvider extends ChangeNotifier {
  final ProductRepository _productRepository;
  
  List<Product> _allProducts = [];
  List<Product> _products = [];
  
  List<Product> get products => _products;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  StreamSubscription? _productsSubscription;

  HomeProvider(this._productRepository) {
    _fetchProducts();
  }

  void _fetchProducts() {
    _isLoading = true;
    notifyListeners();

    _productsSubscription = _productRepository.getAllProducts().listen(
      (productList) {
        if (productList.isEmpty) {
          // Add mock data if no products available
          _products = _getMockTechProducts();
          _allProducts = _products;
        } else {
          // Convert local products to domain models
          _allProducts = productList.map(_convertToProduct).toList();
          _products = _allProducts;
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error fetching products: $error');
        // Fallback to mock data
        _products = _getMockTechProducts();
        _allProducts = _products;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Product _convertToProduct(ProductLocal localProduct) {
    return Product(
      id: localProduct.id,
      name: localProduct.name,
      description: localProduct.description,
      price: localProduct.price,
      stock: localProduct.stock,
      imageUrl: localProduct.imageUrl,
      category: localProduct.category,
      brand: localProduct.brand,
      specifications: localProduct.specifications,
    );
  }

  List<Product> _getMockTechProducts() {
    return [
      Product(
        id: '1',
        name: 'iPhone 15 Pro',
        description: 'Titanium design, A17 Pro chip, Action button.',
        price: 999.0,
        stock: 10,
        imageUrl: 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-15-pro-finish-select-202309-6-1inch-naturaltitanium?wid=2560&hei=1440&fmt=p-jpg&qlt=80&.v=1692846360609',
        category: 'Smartphones',
        brand: 'Apple',
        specifications: {'RAM': '8GB', 'Storage': '128GB', 'Processor': 'A17 Pro'},
      ),
      Product(
        id: '2',
        name: 'Samsung Galaxy S24 Ultra',
        description: 'AI-powered, S Pen included, Titanium frame.',
        price: 1199.0,
        stock: 15,
        imageUrl: 'https://images.samsung.com/is/image/samsung/p6pim/pk/2401/gallery/pk-galaxy-s24-s928-sm-s928bztnpkz-539343389',
        category: 'Smartphones',
        brand: 'Samsung',
        specifications: {'RAM': '12GB', 'Storage': '256GB', 'Processor': 'Snapdragon 8 Gen 3'},
      ),
      Product(
        id: '3',
        name: 'iPad Pro M2',
        description: 'Brilliant 12.9-inch Liquid Retina XDR display.',
        price: 1099.0,
        stock: 5,
        imageUrl: 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/ipad-pro-finish-unselect-gallery-1-202210?wid=2560&hei=1440&fmt=p-jpg&qlt=80&.v=1664393630609',
        category: 'Tablets',
        brand: 'Apple',
        specifications: {'RAM': '8GB', 'Storage': '128GB', 'Processor': 'M2'},
      ),
      Product(
        id: '4',
        name: 'Sony WH-1000XM5',
        description: 'Industry-leading noise canceling headphones.',
        price: 349.0,
        stock: 20,
        imageUrl: 'https://www.sony.com/image/5d02da5df552836db894ce56c6dbf6e3?fmt=pjpeg&wid=1014&hei=396&bgcolor=F1F5F9&bgc=F1F5F9',
        category: 'Accessories',
        brand: 'Sony',
        specifications: {'Battery': '30 Hours', 'Weight': '250g'},
      ),
    ];
  }

  void search(String query) {
    if (query.isEmpty) {
      _products = _allProducts;
    } else {
      _products = _allProducts
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    if (category == 'All') {
      _products = _allProducts;
    } else {
      _products = _allProducts
          .where((product) => product.category == category)
          .toList();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }
}
