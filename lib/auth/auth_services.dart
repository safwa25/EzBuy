import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

ValueNotifier<AuthService> authServiceNotifier = ValueNotifier<AuthService>(AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; 

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  Future<User?> registerWithEmail(
    String email, 
    String password,
    {String? fullName, String? phone} 
  ) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'fullName': fullName ?? '',
          'phone': phone ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
        print("✅ User data saved to Firestore");
      }

      return userCredential.user;
    } catch (e) {
      print("Error registering: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  Future<void> resetPasswordFromCurrentPassword(String newPassword, String CurrentPass, String Email) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: Email,
          password: CurrentPass,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      print("Error resetting password: $e");
    }
  }
}

void initializeAuthService() {
  authServiceNotifier.value = AuthService();
}