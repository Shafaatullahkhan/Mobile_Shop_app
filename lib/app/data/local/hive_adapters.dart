import 'package:hive_flutter/hive_flutter.dart';
import 'models/product_local.dart';
import 'models/order_local.dart';
import 'models/user_local.dart';
import 'models/favorite_local.dart';

class HiveAdapters {
  static Future<void> registerAdapters() async {
    // Register all Hive adapters
    Hive.registerAdapter(ProductLocalAdapter());
    Hive.registerAdapter(OrderLocalAdapter());
    Hive.registerAdapter(UserLocalAdapter());
    Hive.registerAdapter(FavoriteLocalAdapter());
  }

  static Future<void> openBoxes() async {
    // Open all Hive boxes
    await Hive.openBox<ProductLocal>('products');
    await Hive.openBox<OrderLocal>('orders');
    await Hive.openBox<UserLocal>('users');
    await Hive.openBox<FavoriteLocal>('favorites');
  }

  static Future<void> closeBoxes() async {
    // Close all Hive boxes
    await Hive.box('products').close();
    await Hive.box('orders').close();
    await Hive.box('users').close();
    await Hive.box('favorites').close();
  }

  // Getters for boxes
  static Box<ProductLocal> get productsBox => Hive.box<ProductLocal>('products');
  static Box<OrderLocal> get ordersBox => Hive.box<OrderLocal>('orders');
  static Box<UserLocal> get usersBox => Hive.box<UserLocal>('users');
  static Box<FavoriteLocal> get favoritesBox => Hive.box<FavoriteLocal>('favorites');
}
