import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/product_model.dart';

class FavoritesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Product> _favorites = [];
  List<Product> get favorites => _favorites;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  StreamSubscription? _favoritesSubscription;

  FavoritesProvider() {
    _initFavoritesListener();
  }

  void _initFavoritesListener() {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    _favoritesSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
    }).listen((favoritesList) {
      _favorites = favoritesList;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint("Error fetching favorites: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  bool isFavorite(Product product) {
    return _favorites.any((fav) => fav.id == product.id);
  }

  Future<void> toggleFavorite(Product product) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint("User not logged in");
      return;
    }

    try {
      final favoritesRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(product.id);

      if (isFavorite(product)) {
        // Remove from favorites
        await favoritesRef.delete();
        debugPrint("Removed ${product.name} from favorites");
      } else {
        // Add to favorites
        await favoritesRef.set(product.toMap());
        debugPrint("Added ${product.name} to favorites");
      }
    } catch (e) {
      debugPrint("Error toggling favorite: $e");
    }
  }

  Future<void> removeFromFavorites(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(productId)
          .delete();
      debugPrint("Removed product from favorites");
    } catch (e) {
      debugPrint("Error removing from favorites: $e");
    }
  }

  Future<void> clearAllFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final favorites = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      for (var doc in favorites.docs) {
        await doc.reference.delete();
      }
      debugPrint("Cleared all favorites");
    } catch (e) {
      debugPrint("Error clearing favorites: $e");
    }
  }

  int get favoritesCount => _favorites.length;

  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    super.dispose();
  }
}
