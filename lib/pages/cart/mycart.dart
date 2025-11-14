import 'package:ezbuy/pages/cart/cart_item_model.dart';
import 'package:ezbuy/pages/cart/cart_services.dart';
import 'package:ezbuy/pages/cart/checkout_bar.dart';
import 'package:ezbuy/pages/cart/checkout_servises.dart';
import 'package:ezbuy/pages/product_page/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../product_page/models/product_model.dart';
import 'package:ezbuy/pages/cart/payment_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();
  final Set<String> _loadingDocIds = {};

  void _setLoading(String docId, bool loading) {
    setState(() {
      if (loading) {
        _loadingDocIds.add(docId);
      } else {
        _loadingDocIds.remove(docId);
      }
    });
  }

  bool _isLoading(String docId) => _loadingDocIds.contains(docId);

  void _showMessage(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(fontSize: 28)),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: StreamBuilder<List<CartItem>>(
        stream: _cartService.getCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cartItems = snapshot.data ?? [];
          if (cartItems.isEmpty) {
            return _buildEmptyState(isDark);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return _buildCartCard(item, isDark);
            },
          );
        },
      ),
      bottomNavigationBar: StreamBuilder<double>(
        stream: _cartService.getTotalPrice(),
        builder: (context, snapshot) {
          final total = snapshot.data ?? 0.0;
          return CheckoutBar(total: total, isDark: isDark);
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Your Cart is Empty!",
            style: GoogleFonts.cairo(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add products to your cart",
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartCard(CartItem item, bool isDark) {
    final raw = item.rawProductData ?? {};

    final product = Product.fromMap({
      'id': item.productId,
      'name': raw['name'] ?? '',
      'price': raw['price'] ?? 0,
      'description': raw['description'] ?? '',
      'imageUrl': raw['imageUrl'] ?? raw['images'] ?? [],
      'sizes': raw['sizes'] ?? [],
      'colors': raw['colors'] ?? [],
      'category': raw['category'],
      'stock': raw['stock'],
      'isFavorite': raw['isFavorite'] ?? false,
      'quantity': item.quantity,
    });

    final imageList = (raw['imageUrl'] ?? raw['images'] ?? []) as List<dynamic>;
    final firstImage = imageList.isNotEmpty ? imageList[0].toString() : '';

    final imageWidget = (firstImage.isNotEmpty)
        ? (firstImage.startsWith('http')
              ? Image.network(firstImage, fit: BoxFit.cover)
              : Image.asset(firstImage, fit: BoxFit.cover))
        : Icon(Icons.image_not_supported, size: 40, color: Colors.grey);

    final docId = item.docId;
    final loading = _isLoading(docId);

    // compute available for this variant (fallback to cached snapshot)
    int cachedAvailable = product.availableQuantity(
      color: item.selectedColor,
      size: item.selectedSize,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 100,
                height: 100,
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                child: imageWidget,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailPage(
                                productId: item.productId,
                                isLoggedIn: true,
                              ),
                        ),
                      );
                    },
                    child: Text(
                      product.name,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade400,
                              Colors.deepOrange.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '\$${(product.price * item.quantity).toStringAsFixed(2)}',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (item.selectedColor != null || item.selectedSize != null)
                    Text(
                      'Variant: ${item.selectedColor ?? '-'} / ${item.selectedSize ?? '-'}',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Available: $cachedAvailable',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: cachedAvailable > 0
                          ? Colors.green.shade700
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    _quantityButton(
                      Icons.remove,
                      loading
                          ? null
                          : () async {
                              _setLoading(docId, true);
                              try {
                                await _cartService.decreaseQuantityByDocId(
                                  docId,
                                );
                              } catch (e) {
                                _showMessage(
                                  'Failed to update quantity: ${e.toString()}',
                                  error: true,
                                );
                              } finally {
                                _setLoading(docId, false);
                              }
                            },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _quantityButton(
                      Icons.add,
                      loading
                          ? null
                          : () async {
                              _setLoading(docId, true);
                              try {
                                // Fetch latest product doc to get up-to-date stock for this variant
                                final pSnap = await FirebaseFirestore.instance
                                    .collection('products')
                                    .doc(item.productId)
                                    .get();
                                if (!pSnap.exists) {
                                  _showMessage(
                                    'Product no longer exists',
                                    error: true,
                                  );
                                  return;
                                }
                                final latestProduct = Product.fromFirestore(
                                  pSnap,
                                );
                                final latestAvailable = latestProduct
                                    .availableQuantity(
                                      color: item.selectedColor,
                                      size: item.selectedSize,
                                    );

                                if (latestAvailable <= 0) {
                                  _showMessage(
                                    'This variant is out of stock',
                                    error: true,
                                  );
                                  return;
                                }
                                if (item.quantity >= latestAvailable) {
                                  _showMessage(
                                    'Only $latestAvailable item(s) available',
                                    error: true,
                                  );
                                  return;
                                }

                                // build Product from cached data to pass to addToCart (service will re-check inside transaction)
                                final prodMap = {
                                  'id': item.productId,
                                  'name': raw['name'] ?? '',
                                  'price': raw['price'] ?? 0,
                                  'description': raw['description'] ?? '',
                                  'imageUrl':
                                      raw['imageUrl'] ?? raw['images'] ?? [],
                                  'sizes': raw['sizes'] ?? [],
                                  'colors': raw['colors'] ?? [],
                                  'category': raw['category'],
                                  'stock': raw['stock'],
                                  'isFavorite': raw['isFavorite'] ?? false,
                                  'quantity': item.quantity,
                                };
                                final prod = Product.fromMap(prodMap);

                                await _cartService.addToCart(
                                  prod,
                                  qty: 1,
                                  color: item.selectedColor,
                                  size: item.selectedSize,
                                );
                              } catch (e) {
                                _showMessage(
                                  'Failed to add item: ${e.toString()}',
                                  error: true,
                                );
                              } finally {
                                _setLoading(docId, false);
                              }
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: _isLoading(docId)
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete, color: Colors.red, size: 22),
                    onPressed: _isLoading(docId)
                        ? null
                        : () async {
                            _setLoading(docId, true);
                            try {
                              await _cartService.removeFromCartByDocId(docId);
                            } catch (e) {
                              _showMessage(
                                'Failed to remove item: ${e.toString()}',
                                error: true,
                              );
                            } finally {
                              _setLoading(docId, false);
                            }
                          },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback? onPressed) {
    return Container(
      width: 32,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: IconButton(icon: Icon(icon, size: 18), onPressed: onPressed),
    );
  }
}

class CheckoutBar extends StatefulWidget {
  const CheckoutBar({super.key, required this.total, required this.isDark});

  final double total; // total price from cart
  final bool isDark; // dark or light mode

  @override
  State<CheckoutBar> createState() => _CheckoutBarState();
}

class _CheckoutBarState extends State<CheckoutBar> {
  bool _processing = false;
  final CheckoutService _checkoutService = CheckoutService();
  final CartService _cartService = CartService();

  void _showSnack(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? Colors.redAccent : Colors.green,
      ),
    );
  }

  Future<void> _onProceed() async {
    if (widget.total <= 0) return;

    // Navigate to PaymentPage and wait for result (paymentMeta expected)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaymentPage(totalAmount: widget.total)),
    );

    // If payment page returned a Map (payment metadata), proceed to finalize
    if (result != null && result is Map<String, dynamic>) {
      setState(() => _processing = true);
      try {
        await _checkout_service_finalize(result);
        // success
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Order Successful'),
            content: const Text(
              'The order has been created and the quantities have been successfully deducted.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } on StockShortageException catch (e) {
        // Show interactive dialog to let user choose which shortage entries to remove
        if (!mounted) return;
        await _showShortageSelectionDialog(e);
      } catch (e) {
        // other errors
        _showSnack('Failed to place order: ${e.toString()}', error: true);
      } finally {
        if (mounted) setState(() => _processing = false);
      }
    } else {
      // payment page didn't return metadata (user cancelled or PaymentPage handles finalize itself)
      _showSnack(
        'Payment was not completed or payment information was not returned.',
        error: true,
      );
    }
  }

  Future<void> _checkout_service_finalize(
    Map<String, dynamic> paymentMeta,
  ) async {
    await _checkoutService.finalizeOrderAfterPayment(paymentMeta: paymentMeta);
  }

  /// Shows dialog with selectable shortage items. After user selects, removes them from cart.
  Future<void> _showShortageSelectionDialog(StockShortageException ex) async {
    // ex.details: { productId: { 'color|size': {available, requested}, ... }, ... }
    final details = ex.details ?? {};
    // Build flat list of entries for UI
    final List<_ShortageEntry> entries = [];

    if (details.isNotEmpty) {
      details.forEach((pid, issues) {
        if (issues is Map) {
          issues.forEach((key, info) {
            // key format: 'color|size' where '-' means unspecified
            final parts = key.toString().split('|');
            final colorLabel = parts.isNotEmpty ? parts[0] : '-';
            final sizeLabel = parts.length > 1 ? parts[1] : '-';
            final available = (info is Map && info['available'] != null)
                ? info['available'] as int
                : 0;
            final requested = (info is Map && info['requested'] != null)
                ? info['requested'] as int
                : 0;
            entries.add(
              _ShortageEntry(
                productId: pid,
                color: colorLabel == '-' ? null : colorLabel,
                size: sizeLabel == '-' ? null : sizeLabel,
                available: available,
                requested: requested,
              ),
            );
          });
        }
      });
    } else {
      // fallback: use messages (less structured)
      for (final msg in ex.messages) {
        entries.add(_ShortageEntry.fallback(msg));
      }
    }

    // selection map
    final Map<int, bool> selected = {
      for (int i = 0; i < entries.length; i++) i: true,
    }; // default select all

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setStateDialog) {
            return AlertDialog(
              title: const Text('Stock shortage — choose items to remove'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Some items are not available. Choose which of the unavailable entries you want to remove from your cart:',
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: entries.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, idx) {
                          final e = entries[idx];
                          if (e.isFallback) {
                            return CheckboxListTile(
                              value: selected[idx] ?? false,
                              onChanged: (v) => setStateDialog(
                                () => selected[idx] = v ?? false,
                              ),
                              title: Text(
                                e.fallbackMessage ?? 'Unavailable item',
                              ),
                            );
                          }
                          return CheckboxListTile(
                            value: selected[idx] ?? false,
                            onChanged: (v) => setStateDialog(
                              () => selected[idx] = v ?? false,
                            ),
                            title: Text(
                              '${e.productId} — ${e.color ?? '-'} / ${e.size ?? '-'}',
                            ),
                            subtitle: Text(
                              'Available: ${e.available}, Requested: ${e.requested}',
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(), // cancel
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    // collect selected entries and remove them
                    final toRemove = <_ShortageEntry>[];
                    for (int i = 0; i < entries.length; i++) {
                      if (selected[i] ?? false) toRemove.add(entries[i]);
                    }
                    Navigator.of(ctx).pop(); // close dialog first
                    if (toRemove.isEmpty) {
                      _showSnack('No items selected for removal', error: true);
                      return;
                    }
                    await _removeSelectedShortages(toRemove);
                  },
                  child: const Text('Remove selected'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _removeSelectedShortages(List<_ShortageEntry> toRemove) async {
    setState(() => _processing = true);
    int removedCount = 0;
    try {
      for (final e in toRemove) {
        if (e.isFallback) {
          // cannot parse fallback messages -> skip
          continue;
        }
        try {
          await _cartService.removeFromCart(
            e.productId,
            color: e.color,
            size: e.size,
          );
          removedCount++;
        } catch (err) {
          // ignore single removal failures
        }
      }
      _showSnack('Removed $removedCount item(s) from cart');
    } catch (e) {
      _showSnack(
        'Failed to remove selected items: ${e.toString()}',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total price row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "\$${widget.total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Proceed button or loading
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_processing || widget.total <= 0) ? null : _onProceed,
              child: _processing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Proceed to Checkout",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Internal model used for shortlist entries in the shortage dialog
class _ShortageEntry {
  final String productId;
  final String? color;
  final String? size;
  final int available;
  final int requested;
  final bool isFallback;
  final String? fallbackMessage;

  _ShortageEntry({
    required this.productId,
    this.color,
    this.size,
    this.available = 0,
    this.requested = 0,
  }) : isFallback = false,
       fallbackMessage = null;

  _ShortageEntry.fallback(String msg)
    : productId = 'unknown',
      color = null,
      size = null,
      available = 0,
      requested = 0,
      isFallback = true,
      fallbackMessage = msg;
}
