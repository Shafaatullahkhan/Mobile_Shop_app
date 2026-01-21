import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import '../../data/app_colors.dart';
import '../../global_widgets/glass_container.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Column(
          children: [
            _buildTextField("Full Name", authProvider.nameController, Icons.person_outline),
            const SizedBox(height: 20),
            _buildTextField("Email Address", authProvider.emailController, Icons.email_outlined),
            const SizedBox(height: 20),
            _buildTextField("Password", authProvider.passwordController, Icons.lock_outline, isPassword: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 5,
                  shadowColor: AppColors.primary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: authProvider.isLoading
                    ? null
                    : () => authProvider.register(context),
                child: authProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Create Account",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () => authProvider.switchView(0), // Switch to Login
              child: RichText(
                text: const TextSpan(
                  text: "Already have an account? ",
                  style: TextStyle(color: Colors.white70),
                  children: [
                    TextSpan(
                      text: "Sign In",
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon,
      {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white60, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          borderRadius: 15,
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              icon: Icon(icon, color: Colors.white38),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin(BuildContext context, AuthProvider authProvider) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider(color: Colors.white12)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text("OR", style: TextStyle(color: Colors.white24)),
            ),
            Expanded(child: Divider(color: Colors.white12)),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.g_mobiledata, size: 30),
            label: const Text("Continue with Google"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            onPressed: authProvider.isLoading ? null : () => authProvider.signInWithGoogle(context),
          ),
        ),
      ],
    );
  }
}
