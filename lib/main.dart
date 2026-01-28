import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/data/app_colors.dart';
import 'app/data/services/notification_service.dart';
import 'app/data/services/connectivity_service.dart';
import 'app/data/services/offline_storage_service.dart';
import 'app/data/repositories/product_repository.dart';
import 'app/data/repositories/order_repository.dart';
import 'app/data/repositories/favorite_repository.dart';
import 'app/data/repositories/sync_repository.dart';
import 'app/modules/auth/auth_provider.dart';
import 'app/modules/home/home_provider.dart';
import 'app/modules/cart/cart_provider.dart';
import 'app/modules/checkout/checkout_provider.dart';
import 'app/modules/orders/order_provider.dart';
import 'app/modules/profile/profile_provider.dart';
import 'app/modules/admin/admin_provider.dart';
import 'app/modules/favorites/favorites_provider.dart';

import 'app/modules/auth/auth_view.dart';
import 'app/modules/auth/splash_view.dart';
import 'app/modules/home/home_view.dart';
import 'app/modules/cart/cart_view.dart';
import 'app/modules/checkout/checkout_view.dart';
import 'app/modules/orders/order_view.dart';
import 'app/modules/profile/profile_view.dart';
import 'app/modules/favorites/favorites_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  
  try {
    // Initialize Hive first
    await Hive.initFlutter();
    
    await Firebase.initializeApp();
    await NotificationService().initialize();
    
    // Initialize offline services
    final offlineStorageService = OfflineStorageService();
    await offlineStorageService.initialize();
    
    final connectivityService = ConnectivityService();
    
    // Initialize repositories
    final productRepository = ProductRepository(
      connectivityService: connectivityService,
      offlineService: offlineStorageService,
    );
    
    final orderRepository = OrderRepository(
      connectivityService: connectivityService,
      offlineService: offlineStorageService,
    );
    
    final favoriteRepository = FavoriteRepository(
      connectivityService: connectivityService,
      offlineService: offlineStorageService,
    );
    
    final syncRepository = SyncRepository(
      connectivityService: connectivityService,
      offlineService: offlineStorageService,
      productRepository: productRepository,
      orderRepository: orderRepository,
      favoriteRepository: favoriteRepository,
    );
    
    runApp(
      MultiProvider(
        providers: [
          // Services and repositories first
          Provider<OfflineStorageService>.value(value: offlineStorageService),
          Provider<ProductRepository>.value(value: productRepository),
          Provider<OrderRepository>.value(value: orderRepository),
          Provider<FavoriteRepository>.value(value: favoriteRepository),
          Provider<SyncRepository>.value(value: syncRepository),
          ChangeNotifierProvider(create: (_) => connectivityService),
          
          // Then providers that depend on them
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (context) => HomeProvider(context.read<ProductRepository>())),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProxyProvider<CartProvider, CheckoutProvider>(
            create: (context) => CheckoutProvider(cartProvider: context.read<CartProvider>()),
            update: (context, cartProvider, previous) => CheckoutProvider(cartProvider: cartProvider),
          ),
          ChangeNotifierProvider(create: (_) => OrderProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => AdminProvider()),
          ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ],
        child: const MobileApp(),
      ),
    );
  } catch (e) {
    debugPrint("Initialization failed: $e");
    runApp(ErrorApp(error: e.toString()));
  }
}

class MobileApp extends StatelessWidget {
  const MobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Mobile App",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashView(),
      routes: {
        '/auth': (context) => const AuthView(),
        '/home': (context) => const HomeView(),
        '/cart': (context) => const CartView(),
        '/checkout': (context) => const CheckoutView(),
        '/orders': (context) => const OrderView(),
        '/profile': (context) => const ProfileView(),
        '/favorites': (context) => const FavoritesView(),
      },
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Mobile App - Error",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Initialization Failed",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  error,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // Restart the app
                    main();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    "Retry",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
