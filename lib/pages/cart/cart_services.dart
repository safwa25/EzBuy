import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezbuy/pages/product_page/models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String get userId => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _cartRef =>
      _firestore.collection('users').doc(userId).collection('cart');

  /// Add product (or increase quantity if it exists)
  Future<void> addToCart(Product product) async {
    final doc = await _cartRef.doc(product.id).get();

    if (doc.exists) {
      await _cartRef.doc(product.id).update({
        'quantity': FieldValue.increment(1),
      });
    } else {
      await _cartRef.doc(product.id).set(product.toMap());
    }
  }

  /// Decrease quantity or remove item if 1
  Future<void> decreaseQuantity(Product product) async {
    final doc = await _cartRef.doc(product.id).get();
    if (doc.exists) {
      final currentQty = (doc.data()?['quantity'] ?? 1) as int;
      if (currentQty > 1) {
        await _cartRef.doc(product.id).update({'quantity': currentQty - 1});
      } else {
        await _cartRef.doc(product.id).delete();
      }
    }
  }

  /// Remove product
  Future<void> removeFromCart(String productId) async {
    await _cartRef.doc(productId).delete();
  }

  /// Clear all items
  Future<void> clearCart() async {
    final snapshot = await _cartRef.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Get live cart products
  Stream<List<Product>> getCartItems() {
    return _cartRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
    });
  }

  /// Get total price
  Stream<double> getTotalPrice() {
    return getCartItems().map(
      (products) => products.fold(0, (sum, p) => sum + p.totalPrice),
    );
  }

  /// Get live count of items in the cart
  Stream<int> cartItemCountStream() {
    return _cartRef.snapshots().map((snapshot) {
      int totalCount = 0;
      for (var doc in snapshot.docs) {
        final quantity = (doc.data()['quantity'] ?? 1) as int;
        totalCount += quantity;
      }
      return totalCount;
    });
  }
}
