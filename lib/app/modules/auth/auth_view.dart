import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'login_view.dart';
import 'register_view.dart';
import '../../data/app_colors.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.background, Color(0xFF1B2339)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    const Icon(Icons.phone_iphone, size: 80, color: AppColors.primary),
                    const SizedBox(height: 20),
                    Text(
                      authProvider.authModeIndex == 0 ? "Welcome To Mobile Shop" : "Create Account",
                      style: const TextStyle(
                          color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      authProvider.authModeIndex == 0 ? "Sign in to explore latest mobiles" : "Join our tech community",
                      style: const TextStyle(color: Colors.white38, fontSize: 16),
                    ),
                    const SizedBox(height: 50),
                    if (authProvider.authModeIndex == 0)
                      const LoginView()
                    else
                      const RegisterView(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
