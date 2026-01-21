import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';

import 'app/data/app_colors.dart';
import 'app/data/services/notification_service.dart';
import 'app/modules/auth/auth_provider.dart';
import 'app/modules/home/home_provider.dart';
import 'app/modules/cart/cart_provider.dart';
import 'app/modules/checkout/checkout_provider.dart';
import 'app/modules/orders/order_provider.dart';
import 'app/modules/profile/profile_provider.dart';
import 'app/modules/admin/admin_provider.dart';

import 'app/modules/auth/auth_view.dart';
import 'app/modules/auth/splash_view.dart';
import 'app/modules/home/home_view.dart';
import 'app/modules/cart/cart_view.dart';
import 'app/modules/checkout/checkout_view.dart';
import 'app/modules/orders/order_view.dart';
import 'app/modules/profile/profile_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  
  try {
    await Firebase.initializeApp();
    await NotificationService().initialize();
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProxyProvider<CartProvider, CheckoutProvider>(
          create: (context) => CheckoutProvider(cartProvider: context.read<CartProvider>()),
          update: (context, cartProvider, previous) => CheckoutProvider(cartProvider: cartProvider),
        ),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const MobileApp(),
    ),
  );
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
      },
    );
  }
}
