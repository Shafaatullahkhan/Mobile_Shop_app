import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../modules/auth/auth_provider.dart';
import '../modules/admin/admin_view.dart';
import '../data/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authProvider = context.read<AuthProvider>();

    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          _buildHeader(user),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home_outlined,
                  title: "Home",
                  onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person_outline,
                  title: "My Profile",
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.shopping_bag_outlined,
                  title: "My Orders",
                  onTap: () => Navigator.pushNamed(context, '/orders'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.favorite_outline,
                  title: "My Favorites",
                  onTap: () => Navigator.pushNamed(context, '/favorites'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.shopping_cart_outlined,
                  title: "My Cart",
                  onTap: () => Navigator.pushNamed(context, '/cart'),
                ),
                if (authProvider.isAdmin) ...[
                  const Divider(color: Colors.white12),
                  _buildDrawerItem(
                    context,
                    icon: Icons.admin_panel_settings_outlined,
                    title: "Admin Panel",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminView()),
                    ),
                  ),
                ],
                const Divider(color: Colors.white12, height: 40),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: "Settings",
                  onTap: () {},
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  onTap: () {},
                ),
              ],
            ),
          ),
          _buildLogoutButton(context, authProvider),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(User? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: user?.photoURL != null
                ? ClipOval(child: Image.network(user!.photoURL!))
                : const Icon(Icons.person, size: 40, color: AppColors.primary),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? "Guest User",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  user?.email ?? "Sign in to see details",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          authProvider.signOut(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: Colors.redAccent, size: 20),
              SizedBox(width: 10),
              Text(
                "Sign Out",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
