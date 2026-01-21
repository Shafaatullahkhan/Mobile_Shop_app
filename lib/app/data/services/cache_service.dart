import 'package:get_storage/get_storage.dart';
import '../models/product_model.dart';

class CacheService {
  final _box = GetStorage();

  void saveProducts(List<Product> products) {
    final list = products.map((e) => e.toMap()).toList();
    _box.write('products', list);
  }

  List<Product> getProducts() {
    final data = _box.read<List>('products');
    if (data != null) {
      return data.map((e) => Product.fromMap(e as Map<String, dynamic>, '')).toList();
    }
    return [];
  }
}
