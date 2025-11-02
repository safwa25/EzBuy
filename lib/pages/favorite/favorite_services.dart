import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezbuy/pages/product_page/models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FavoriteService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String get userId => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _favRef =>
      _firestore.collection('users').doc(userId).collection('favorites');

  /// Add or remove favorite
  Future<void> toggleFavorite(Product product) async {
    final doc = await _favRef.doc(product.id).get();
    if (doc.exists) {
      await _favRef.doc(product.id).delete(); // Remove from favorite
    } else {
      await _favRef.doc(product.id).set(product.toMap()); // Add to favorite
    }
  }

  /// Check if product is favorite
  Stream<bool> isFavorite(String productId) {
    return _favRef.doc(productId).snapshots().map((doc) => doc.exists);
  }

  /// Get all favorite items
  Stream<List<Product>> getFavorites() {
    return _favRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
    });
  }

  /// Remove favorite
  Future<void> removeFavorite(String productId) async {
    await _favRef.doc(productId).delete();
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    final snapshot = await _favRef.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
