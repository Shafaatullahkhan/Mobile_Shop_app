import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile_provider.dart';
import '../auth/auth_provider.dart';
import '../../data/app_colors.dart';
import '../../global_widgets/glass_container.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text("My Profile",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () => context.read<ProfileProvider>().logout(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, Color(0xFF1B2339)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<ProfileProvider>(
          builder: (context, profileProvider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const SizedBox(height: 120),
                  _buildAvatar(),
                  const SizedBox(height: 40),
                  _buildTextField(
                    label: "Full Name",
                    controller: profileProvider.nameController,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: "Email Address",
                    controller: profileProvider.emailController,
                    icon: Icons.email_outlined,
                    isReadOnly: true,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: profileProvider.isLoading
                          ? null
                          : () => profileProvider.saveProfile(context),
                      child: profileProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Save Changes",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) => SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () => auth.toggleAdminRole(context),
                        icon: Icon(auth.isAdmin ? Icons.admin_panel_settings : Icons.person_outline, color: Colors.white38),
                        label: Text(auth.isAdmin ? "Disable Admin Mode" : "Enable Admin Mode",
                            style: const TextStyle(color: Colors.white38)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [AppColors.primary, Colors.blue]),
            ),
            child: const CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.surface,
              child: Icon(Icons.person, size: 60, color: Colors.white24),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isReadOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          borderRadius: 15,
          child: TextField(
            controller: controller,
            readOnly: isReadOnly,
            style: TextStyle(color: isReadOnly ? Colors.white38 : Colors.white),
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
}
