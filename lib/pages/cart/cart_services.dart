import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezbuy/pages/cart/cart_item_model.dart';
import 'package:ezbuy/pages/product_page/models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String get userId => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _cartRef =>
      _firestore.collection('users').doc(userId).collection('cart');

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection('products');

  String _normalize(String s) => s.trim().replaceAll(' ', '_');

  String _cartDocId(String productId, {String? color, String? size}) {
    final c = (color ?? '').trim();
    final s = (size ?? '').trim();

    if (c.isEmpty && s.isEmpty) return productId;
    if (c.isNotEmpty && s.isEmpty) return '${productId}_${_normalize(c)}';
    if (c.isEmpty && s.isNotEmpty) return '${productId}_${_normalize(s)}';
    return '${productId}_${_normalize(c)}_${_normalize(s)}';
  }

  /// Add product (or increase quantity if same product+variant exists)
  /// - qty: how many to add this call (default 1)
  /// - color/size: optional variant selection
  /// Uses a transaction to verify availability on the latest product snapshot.
  Future<void> addToCart(Product product,
      {int qty = 1, String? color, String? size}) async {
    if (qty <= 0) throw Exception('The quantity must be greater than zero');

    final pRef = _productsRef.doc(product.id);
    final cartDocId = _cartDocId(product.id, color: color, size: size);
    final cartRef = _cartRef.doc(cartDocId);

    await _firestore.runTransaction((tx) async {
      final pSnap = await tx.get(pRef);
      if (!pSnap.exists) throw Exception('Product does not exist');

      final latestProduct = Product.fromFirestore(pSnap);

      final existingSnap = await tx.get(cartRef);
      final existingQty =
          existingSnap.exists ? (existingSnap.data()?['quantity'] ?? 0) as int : 0;
      final totalRequested = existingQty + qty;

      final available =
          latestProduct.availableQuantity(color: color, size: size);

      if (available < totalRequested) {
        throw Exception(
            'Requested $totalRequested but only $available available for the selected variant.');
      }

      // Prepare cart item map (cache some product fields for UI)
      final cartItem = {
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'description': product.description,
        'imageUrl': product.images,
        'sizes': product.sizes,
        'colors': product.colors,
        'category': product.category,
        'stock': product.stock, // cached snapshot for UI only
        'isFavorite': product.isFavorite,
        'selectedColor': color,
        'selectedSize': size,
        'quantity': totalRequested,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (existingSnap.exists) {
        tx.update(cartRef, {
          'quantity': totalRequested,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        tx.set(cartRef, cartItem);
      }
    });
  }

  /// Decrease quantity or remove item if quantity becomes 0 (by product+variant)
  Future<void> decreaseQuantity(String productId,
      {String? color, String? size}) async {
    final cartDocId = _cartDocId(productId, color: color, size: size);
    await decreaseQuantityByDocId(cartDocId);
  }

  /// Decrease by cart document id (direct)
  Future<void> decreaseQuantityByDocId(String docId) async {
    final docRef = _cartRef.doc(docId);
    final doc = await docRef.get();
    if (!doc.exists) return;
    final currentQty = (doc.data()?['quantity'] ?? 1) as int;
    if (currentQty > 1) {
      await docRef.update({'quantity': currentQty - 1, 'updatedAt': FieldValue.serverTimestamp()});
    } else {
      await docRef.delete();
    }
  }

  /// Remove product (specific variant or whole product entry)
  Future<void> removeFromCart(String productId, {String? color, String? size}) async {
    final cartDocId = _cartDocId(productId, color: color, size: size);
    await removeFromCartByDocId(cartDocId);
  }

  /// Remove by doc id (direct)
  Future<void> removeFromCartByDocId(String docId) async {
    await _cartRef.doc(docId).delete();
  }

  /// Clear all items
  Future<void> clearCart() async {
    final snapshot = await _cartRef.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Get live cart items as CartItem objects
  Stream<List<CartItem>> getCartItems() {
    return _cartRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CartItem.fromDoc(doc.id, doc.data());
      }).toList();
    });
  }

  /// Get total price (uses cached product price in cart doc if present,
  /// otherwise falls back to 0)
  Stream<double> getTotalPrice() {
    return getCartItems().map((items) {
      double total = 0.0;
      for (final item in items) {
        final raw = item.rawProductData;
        final price = (raw != null && raw['price'] != null)
            ? (raw['price'] is num ? (raw['price'] as num).toDouble() : double.tryParse(raw['price'].toString()) ?? 0.0)
            : 0.0;
        total += price * item.quantity;
      }
      return total;
    });
  }

  /// Get live count of items in the cart (sum of quantities)
  Stream<int> cartItemCountStream() {
    return getCartItems().map((items) {
      int totalCount = 0;
      for (var item in items) {
        totalCount += item.quantity;
      }
      return totalCount;
    });
  }
}
