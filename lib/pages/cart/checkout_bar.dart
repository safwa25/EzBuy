import 'package:ezbuy/pages/cart/checkout_servises.dart'; // contains CheckoutService + StockShortageException
import 'package:ezbuy/pages/cart/payment_page.dart';
import 'package:ezbuy/pages/cart/cart_services.dart';
import 'package:flutter/material.dart';

class CheckoutBar extends StatefulWidget {
  const CheckoutBar({
    super.key,
    required this.total,
    required this.isDark,
  });

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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: error ? Colors.redAccent : Colors.green,
    ));
  }

  Future<void> _onProceed() async {
    if (widget.total <= 0) return;

    // Navigate to PaymentPage and wait for result (paymentMeta expected)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(totalAmount: widget.total),
      ),
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
            content: const Text('The order has been created and the quantities have been successfully deducted.'),
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
      _showSnack('Payment was not completed or payment information was not returned.', error: true);
    }
  }

  Future<void> _checkout_service_finalize(Map<String, dynamic> paymentMeta) async {
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
            final available = (info is Map && info['available'] != null) ? info['available'] as int : 0;
            final requested = (info is Map && info['requested'] != null) ? info['requested'] as int : 0;
            entries.add(_ShortageEntry(
              productId: pid,
              color: colorLabel == '-' ? null : colorLabel,
              size: sizeLabel == '-' ? null : sizeLabel,
              available: available,
              requested: requested,
            ));
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
    final Map<int, bool> selected = { for (int i=0;i<entries.length;i++) i: true }; // default select all

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setStateDialog) {
          return AlertDialog(
            title: const Text('Stock shortage — choose items to remove'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Some items are not available. Choose which of the unavailable entries you want to remove from your cart:'),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: entries.length,
                      separatorBuilder: (_,__) => const Divider(),
                      itemBuilder: (context, idx) {
                        final e = entries[idx];
                        if (e.isFallback) {
                          return CheckboxListTile(
                            value: selected[idx] ?? false,
                            onChanged: (v) => setStateDialog(() => selected[idx] = v ?? false),
                            title: Text(e.fallbackMessage ?? 'Unavailable item'),
                          );
                        }
                        return CheckboxListTile(
                          value: selected[idx] ?? false,
                          onChanged: (v) => setStateDialog(() => selected[idx] = v ?? false),
                          title: Text('${e.productId} — ${e.color ?? '-'} / ${e.size ?? '-'}'),
                          subtitle: Text('Available: ${e.available}, Requested: ${e.requested}'),
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
        });
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
          await _cartService.removeFromCart(e.productId, color: e.color, size: e.size);
          removedCount++;
        } catch (err) {
          // ignore single removal failures
        }
      }
      _showSnack('Removed $removedCount item(s) from cart');
    } catch (e) {
      _showSnack('Failed to remove selected items: ${e.toString()}', error: true);
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
  })  : isFallback = false,
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
