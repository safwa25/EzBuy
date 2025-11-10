import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/firebase_options.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await uploadProducts();
}

Future<void> uploadProducts() async {
  final firestore = FirebaseFirestore.instance;
  final String jsonString = await rootBundle.loadString('assets/products.json');
  final List<dynamic> products = json.decode(jsonString);

  for (var product in products) {
    final docId = product['id'];
    await firestore.collection('products').doc(docId).set(product);
    print('Uploaded product $docId');
  }

  print('All products uploaded successfully!');
}
