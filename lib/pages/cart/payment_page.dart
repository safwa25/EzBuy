import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentPage extends StatefulWidget {
  final double totalAmount;

  const PaymentPage({super.key, required this.totalAmount});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String paymentMethod = 'COD'; // Default: Cash on Delivery

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final cardNumberController = TextEditingController();

  bool _isLoading = false;

  String _maskCard(String card) {
    final trimmed = card.replaceAll(' ', '');
    if (trimmed.length <= 4) return trimmed;
    return '**** **** **** ${trimmed.substring(trimmed.length - 4)}';
  }

  Future<void> _saveInvoiceAndReturnMeta() async {
    // validation
    final name = nameController.text.trim();
    final address = addressController.text.trim();
    final card = cardNumberController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your full name')));
      return;
    }
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your delivery address')));
      return;
    }
    if (paymentMethod == 'Card') {
      // basic card validation: digits only and length 12-19 (typical)
      final digits = card.replaceAll(' ', '');
      if (digits.length < 12 || digits.length > 19 || !RegExp(r'^\d+$').hasMatch(digits)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid card number')));
        return;
      }
    }

    try {
      setState(() => _isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not logged in')));
        return;
      }

      final firestore = FirebaseFirestore.instance;
      final invoiceRef = firestore.collection('users').doc(user.uid).collection('invoices');

      // build payment metadata to return to caller
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final paymentId = 'PAY-${DateTime.now().millisecondsSinceEpoch}';

      final Map<String, dynamic> paymentMeta = {
        'method': paymentMethod,
        'paymentId': paymentId,
        'amount': widget.totalAmount,
        'name': name,
        'address': address,
        'createdAt': nowIso,
      };

      // mask and include last4 if card
      String? cardLast4;
      if (paymentMethod == 'Card') {
        final digits = card.replaceAll(' ', '');
        cardLast4 = digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
        paymentMeta['cardLast4'] = cardLast4;
      }

      // save invoice/doc (do not save full card number)
      final invoiceData = {
        'total': widget.totalAmount,
        'paymentMethod': paymentMethod,
        'name': name,
        'address': address,
        'cardLast4': cardLast4, // nullable
        'date': FieldValue.serverTimestamp(),
        'paymentMeta': paymentMeta,
      };

      await invoiceRef.add(invoiceData);

      // success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order placed successfully via $paymentMethod!')),
        );
        // Important: return payment metadata to caller (e.g. CheckoutBar)
        Navigator.pop(context, paymentMeta);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving invoice: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    cardNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            RadioListTile<String>(
              title: const Text('Cash on Delivery (COD)'),
              value: 'COD',
              groupValue: paymentMethod,
              onChanged: (value) {
                setState(() => paymentMethod = value!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Credit / Debit Card'),
              value: 'Card',
              groupValue: paymentMethod,
              onChanged: (value) {
                setState(() => paymentMethod = value!);
              },
            ),
            const SizedBox(height: 16),

            // Show card fields only if 'Card' selected
            if (paymentMethod == 'Card') ...[
              const Text('Card Number'),
              TextField(
                controller: cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter card number',
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Text('Full Name'),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Enter your name'),
            ),
            const SizedBox(height: 16),

            const Text('Address'),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(hintText: 'Enter delivery address'),
            ),
            const SizedBox(height: 24),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${widget.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Confirm Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveInvoiceAndReturnMeta,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'Confirm Payment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
