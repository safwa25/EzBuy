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

  Future<void> _saveInvoice() async {
    try {
      setState(() => _isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      final firestore = FirebaseFirestore.instance;
      final invoiceRef =
          firestore.collection('users').doc(user.uid).collection('invoices');

      await invoiceRef.add({
        'total': widget.totalAmount,
        'paymentMethod': paymentMethod,
        'name': nameController.text.trim(),
        'address': addressController.text.trim(),
        'cardNumber': paymentMethod == 'Card'
            ? cardNumberController.text.trim()
            : null,
        'date': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Order placed successfully via $paymentMethod!'),
        ),
      );

      Navigator.pop(context); // يرجع المستخدم بعد الدفع
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving invoice: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
                onPressed: _isLoading ? null : _saveInvoice,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
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