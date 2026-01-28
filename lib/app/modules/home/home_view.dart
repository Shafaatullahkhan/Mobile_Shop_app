import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_provider.dart';
import '../cart/cart_provider.dart';
import '../favorites/favorites_provider.dart';
import 'product_detail_view.dart';
import '../../data/app_colors.dart';
import '../../global_widgets/glass_container.dart';
import '../../global_widgets/app_drawer.dart';
import '../../global_widgets/offline_status_indicator.dart';
import '../cart/cart_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, Color(0xFF1B2339)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildAppBar(context),
              _buildHeader(context),
              _buildCategories(context),
              _buildProductGrid(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
        child: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu, color: AppColors.primary),
            ),
          ),
        ),
      ),
      title: const SizedBox.shrink(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: const OfflineStatusIndicator(),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: IconButton(
            icon: const Icon(Icons.search, color: Colors.white70, size: 28),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Find Your Next Mobile",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 25),
            GlassContainer(
              height: 180,
              width: double.infinity,
              borderRadius: 25,
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -10,
                    child: Opacity(
                      opacity: 0.1,
                      child: const Icon(Icons.phone_android, size: 200, color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "20% OFF",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "On latest Flagships",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Shop Now",
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = ['All', 'Smartphones', 'Tablets', 'Wearables', 'Accessories'];
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final isSelected = context.watch<HomeProvider>().selectedCategory == categories[index];
            return Padding(
              padding: const EdgeInsets.only(right: 15),
              child: ChoiceChip(
                label: Text(categories[index]),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white.withOpacity(0.05),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (val) {
                  context.read<HomeProvider>().filterByCategory(categories[index]);
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: BorderSide.none,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, _) {
        if (homeProvider.isLoading) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (homeProvider.products.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text("No products found", style: TextStyle(color: Colors.white54))),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = homeProvider.products[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailView(product: product),
                      ),
                    );
                  },
                  child: _buildProductCard(context, product),
                );
              },
              childCount: homeProvider.products.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, product) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, _) {
        final isFavorite = favoritesProvider.isFavorite(product);
        return GlassContainer(
          padding: const EdgeInsets.all(12),
          borderRadius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: Hero(
                        tag: 'product_${product.id}',
                        child: product.imageUrl.isNotEmpty
                            ? Image.network(product.imageUrl, fit: BoxFit.contain)
                            : const Icon(Icons.phone_iphone, size: 80, color: Colors.white24),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () => favoritesProvider.toggleFavorite(product),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.redAccent : Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                product.brand.isNotEmpty ? product.brand : "Premium",
                style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                product.name,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "\$${product.price.toStringAsFixed(0)}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.read<CartProvider>().addToCart(product, context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home_filled, "Home", true, () {}),
          _buildNavItem(context, Icons.map_outlined, "Map", false, () {}),
          _buildNavItem(context, Icons.shopping_cart_outlined, "Cart", false, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartView()),
            );
          }),
          _buildNavItem(context, Icons.person_outline, "Profile", false, () {
            Navigator.pushNamed(context, '/profile');
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label,
      bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? AppColors.primary : Colors.white38, size: 28),
          if (isActive) ...[
            const SizedBox(height: 4),
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
            )
          ]
        ],
      ),
    );
  }
}
