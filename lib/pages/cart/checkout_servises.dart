import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Exception thrown when stock shortages happen during finalize.
/// Contains a list of human-readable shortage messages and a structured map
/// suitable for the UI if you want to show more details.
class StockShortageException implements Exception {
  final List<String> messages;
  final Map<String, dynamic>? details;

  StockShortageException(this.messages, {this.details});

  @override
  String toString() => 'StockShortageException: ${messages.join("; ")}';
}

class CheckoutService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get userId {
    final u = _auth.currentUser;
    if (u == null) throw FirebaseAuthException(code: 'NO_USER', message: 'No authenticated user.');
    return u.uid;
  }

  CollectionReference<Map<String, dynamic>> get _cartRef =>
      _firestore.collection('users').doc(userId).collection('cart');

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection('products');

  CollectionReference<Map<String, dynamic>> get _ordersRef =>
      _firestore.collection('orders');

  /// Finalize order after payment.
  /// On success returns void. On shortages throws StockShortageException with details.
  Future<void> finalizeOrderAfterPayment({
    required Map<String, dynamic> paymentMeta,
  }) async {
    final cartSnapshot = await _cartRef.get();
    if (cartSnapshot.docs.isEmpty) {
      throw Exception('Cart is empty');
    }

    // Build entries from cart docs
    final List<_CartEntry> entries = cartSnapshot.docs.map((doc) {
      final data = doc.data();
      final productId = (data['id'] ?? doc.id.split('_').first).toString();
      final quantity = (data['quantity'] ?? 0) as int;
      final selectedColor = data['selectedColor'] as String?;
      final selectedSize = data['selectedSize'] as String?;
      return _CartEntry(
        cartDocRef: doc.reference,
        productId: productId,
        quantity: quantity,
        selectedColor: selectedColor,
        selectedSize: selectedSize,
      );
    }).toList();

    await _firestore.runTransaction((tx) async {
      // 1) Read and cache product docs (single read per product)
      final Map<String, Map<String, dynamic>> productDataCache = {};
      for (final e in entries) {
        if (productDataCache.containsKey(e.productId)) continue;
        final pRef = _productsRef.doc(e.productId);
        final pSnap = await tx.get(pRef);
        if (!pSnap.exists) {
          throw Exception('Product ${e.productId} does not exist');
        }
        productDataCache[e.productId] = pSnap.data() ?? {};
      }

      // 2) Aggregate required quantities per product/color/size
      // Structure: { productId: { colorKey: { sizeKey: qty } } }
      final Map<String, Map<String, Map<String, int>>> requiredPerProduct = {};
      for (final e in entries) {
        requiredPerProduct.putIfAbsent(e.productId, () => {});
        final productReq = requiredPerProduct[e.productId]!;

        final colorKey = e.selectedColor ?? '__ALL_COLORS__';
        final sizeKey = e.selectedSize ?? '__ALL_SIZES__';

        productReq.putIfAbsent(colorKey, () => {});
        final colorReq = productReq[colorKey]!;
        colorReq[sizeKey] = (colorReq[sizeKey] ?? 0) + e.quantity;
      }

      // 3) Verify availability for all required entries (using cached product data)
      final List<String> shortageMessages = [];
      final Map<String, dynamic> shortageDetails = {}; // structured details per product

      for (final productId in requiredPerProduct.keys) {
        final pdata = productDataCache[productId] ?? {};
        final rawStock = pdata['stock'];

        if (rawStock == null || rawStock is! Map) {
          // no stock info -> everything requested is shortage
          final productReq = requiredPerProduct[productId]!;
          int totalRequested = 0;
          productReq.forEach((_, sizesMap) {
            sizesMap.forEach((__, q) {
              totalRequested += q;
            });
          });
          if (totalRequested > 0) {
            final msg = 'Product $productId has no stock data (requested $totalRequested).';
            shortageMessages.add(msg);
            shortageDetails[productId] = {'requested': totalRequested, 'available': 0};
          }
          continue;
        }

        final productReq = requiredPerProduct[productId]!;
        for (final colorKey in productReq.keys) {
          final sizesMap = productReq[colorKey]!;
          for (final sizeKey in sizesMap.keys) {
            final needed = sizesMap[sizeKey] ?? 0;
            int available = 0;

            if (colorKey == '__ALL_COLORS__' && sizeKey == '__ALL_SIZES__') {
              // sum across all colors & sizes
              rawStock.forEach((_, v) {
                if (v is Map) {
                  v.forEach((__, q) {
                    available += (q is int) ? q : int.tryParse(q.toString()) ?? 0;
                  });
                }
              });
            } else if (colorKey != '__ALL_COLORS__' && sizeKey != '__ALL_SIZES__') {
              final colorMap = rawStock[colorKey];
              if (colorMap is Map) {
                final q = colorMap[sizeKey];
                available = (q is int) ? q : int.tryParse(q.toString()) ?? 0;
              } else {
                available = 0;
              }
            } else if (colorKey != '__ALL_COLORS__' && sizeKey == '__ALL_SIZES__') {
              final colorMap = rawStock[colorKey];
              if (colorMap is Map) {
                colorMap.forEach((__, q) {
                  available += (q is int) ? q : int.tryParse(q.toString()) ?? 0;
                });
              } else {
                available = 0;
              }
            } else if (colorKey == '__ALL_COLORS__' && sizeKey != '__ALL_SIZES__') {
              rawStock.forEach((_, v) {
                if (v is Map) {
                  final q = v[sizeKey];
                  available += (q is int) ? q : int.tryParse(q.toString()) ?? 0;
                }
              });
            }

            if (available < needed) {
              final colorLabel = (colorKey == '__ALL_COLORS__') ? '-' : colorKey;
              final sizeLabel = (sizeKey == '__ALL_SIZES__') ? '-' : sizeKey;
              final msg = 'Product $productId ($colorLabel / $sizeLabel) available: $available, requested: $needed';
              shortageMessages.add(msg);

              shortageDetails.putIfAbsent(productId, () => <String, dynamic>{});
              (shortageDetails[productId] as Map).putIfAbsent('$colorLabel|$sizeLabel', () => {
                    'available': available,
                    'requested': needed,
                  });
            }
          }
        }
      }

      if (shortageMessages.isNotEmpty) {
        // Throw structured exception so UI can parse shortages easily
        throw StockShortageException(shortageMessages, details: shortageDetails);
      }

      // 4) Build updatedStockPerProduct (deep copies) and apply cumulative deductions
      final Map<String, Map<String, dynamic>> updatedStockPerProduct = {};
      for (final pid in productDataCache.keys) {
        final pdata = productDataCache[pid]!;
        final rawStock = pdata['stock'];
        if (rawStock is Map) {
          final copy = <String, dynamic>{};
          rawStock.forEach((color, sizesMap) {
            if (sizesMap is Map) {
              copy[color] = Map<String, dynamic>.from(sizesMap);
            } else {
              copy[color] = sizesMap;
            }
          });
          updatedStockPerProduct[pid] = copy;
        }
      }

      // Apply deductions per product using aggregated requiredPerProduct
      for (final pid in requiredPerProduct.keys) {
        final productReq = requiredPerProduct[pid]!;
        final updatedStock = updatedStockPerProduct[pid];
        if (updatedStock == null) {
          throw Exception('Inventory missing for product $pid during deduction.');
        }

        for (final colorKey in productReq.keys) {
          final sizesMap = productReq[colorKey]!;

          if (colorKey == '__ALL_COLORS__') {
            // handle overall quantity or specific sizes across colors
            final needAllSizes = sizesMap['__ALL_SIZES__'] ?? 0;
            if (needAllSizes > 0) {
              int need = needAllSizes;
              for (final color in updatedStock.keys) {
                if (need <= 0) break;
                final curSizes = Map<String, dynamic>.from(updatedStock[color] as Map);
                for (final size in curSizes.keys) {
                  if (need <= 0) break;
                  final cur = (curSizes[size] is int) ? curSizes[size] as int : int.tryParse(curSizes[size].toString()) ?? 0;
                  final take = (cur <= need) ? cur : need;
                  curSizes[size] = cur - take;
                  need -= take;
                }
                updatedStock[color] = curSizes;
              }
            }

            // specific sizes across all colors
            for (final sizeKey in sizesMap.keys) {
              if (sizeKey == '__ALL_SIZES__') continue;
              int need = sizesMap[sizeKey] ?? 0;
              for (final color in updatedStock.keys) {
                if (need <= 0) break;
                final curSizes = Map<String, dynamic>.from(updatedStock[color] as Map);
                final cur = (curSizes[sizeKey] is int) ? curSizes[sizeKey] as int : int.tryParse((curSizes[sizeKey] ?? '0').toString()) ?? 0;
                final take = (cur <= need) ? cur : need;
                curSizes[sizeKey] = cur - take;
                need -= take;
                updatedStock[color] = curSizes;
              }
            }
          } else {
            // specific colorKey
            final color = colorKey;
            final colorSizes = Map<String, dynamic>.from(updatedStock[color] ?? {});

            int needAllSizes = sizesMap['__ALL_SIZES__'] ?? 0;
            if (needAllSizes > 0) {
              int need = needAllSizes;
              for (final sz in colorSizes.keys) {
                if (need <= 0) break;
                final cur = (colorSizes[sz] is int) ? colorSizes[sz] as int : int.tryParse(colorSizes[sz].toString()) ?? 0;
                final take = (cur <= need) ? cur : need;
                colorSizes[sz] = cur - take;
                need -= take;
              }
            }
            for (final sz in sizesMap.keys) {
              if (sz == '__ALL_SIZES__') continue;
              final cur = (colorSizes[sz] is int) ? colorSizes[sz] as int : int.tryParse((colorSizes[sz] ?? '0').toString()) ?? 0;
              colorSizes[sz] = cur - (sizesMap[sz] ?? 0);
            }
            updatedStock[color] = colorSizes;
          }
        }
      }

      // 5) Persist updatedStock per product (single update per product)
      for (final pid in updatedStockPerProduct.keys) {
        final pRef = _productsRef.doc(pid);
        tx.update(pRef, {'stock': updatedStockPerProduct[pid]});
      }

      // 6) create order doc
      final orderData = {
        'userId': userId,
        'items': entries
            .map((e) => {
                  'productId': e.productId,
                  'quantity': e.quantity,
                  'color': e.selectedColor,
                  'size': e.selectedSize,
                })
            .toList(),
        'payment': paymentMeta,
        'status': 'paid',
        'createdAt': FieldValue.serverTimestamp(),
      };
      final newOrderRef = _ordersRef.doc();
      tx.set(newOrderRef, orderData);

      // 7) delete cart docs
      for (final e in entries) {
        tx.delete(e.cartDocRef);
      }
    });
  }
}

class _CartEntry {
  final DocumentReference cartDocRef;
  final String productId;
  final int quantity;
  final String? selectedColor;
  final String? selectedSize;

  _CartEntry({
    required this.cartDocRef,
    required this.productId,
    required this.quantity,
    this.selectedColor,
    this.selectedSize,
  });
}
