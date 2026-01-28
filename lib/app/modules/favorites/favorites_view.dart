import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'favorites_provider.dart';
import '../home/product_detail_view.dart';
import '../../data/app_colors.dart';
import '../../global_widgets/glass_container.dart';
import '../../data/models/product_model.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Favorites",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, favoritesProvider, _) {
              if (favoritesProvider.favorites.isEmpty) return const SizedBox();
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  if (value == 'clear') {
                    _showClearAllDialog(context, favoritesProvider);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text('Clear All'),
                      ],
                    ),
                  ),
                ],
              );
            },
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
        child: Consumer<FavoritesProvider>(
          builder: (context, favoritesProvider, _) {
            if (favoritesProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (favoritesProvider.favorites.isEmpty) {
              return _buildEmptyState(context);
            }

            return Column(
              children: [
                _buildHeader(context, favoritesProvider),
                Expanded(
                  child: _buildFavoritesGrid(context, favoritesProvider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.favorite_border,
              size: 60,
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "No favorites yet",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Start adding products to your favorites\nand they'll appear here",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              "Browse Products",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FavoritesProvider favoritesProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your Favorites",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${favoritesProvider.favoritesCount} items",
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesGrid(BuildContext context, FavoritesProvider favoritesProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.75,
        ),
        itemCount: favoritesProvider.favorites.length,
        itemBuilder: (context, index) {
          final product = favoritesProvider.favorites[index];
          return _buildFavoriteProductCard(context, product, favoritesProvider);
        },
      ),
    );
  }

  Widget _buildFavoriteProductCard(BuildContext context, Product product, FavoritesProvider favoritesProvider) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailView(product: product),
          ),
        );
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(15),
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: product.imageUrl.isNotEmpty
                          ? Image.network(
                              product.imageUrl,
                              fit: BoxFit.contain,
                              height: double.infinity,
                              width: double.infinity,
                            )
                          : const Icon(
                              Icons.phone_iphone,
                              size: 50,
                              color: Colors.white24,
                            ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => favoritesProvider.toggleFavorite(product),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${product.price.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Stock: ${product.stock}",
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, FavoritesProvider favoritesProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          "Clear All Favorites?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to remove all items from your favorites?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              favoritesProvider.clearAllFavorites();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All favorites cleared")),
              );
            },
            child: const Text(
              "Clear All",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
