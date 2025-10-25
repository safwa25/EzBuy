import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart'; 

ValueNotifier<AuthService> authServiceNotifier = ValueNotifier<AuthService>(AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
    String password, {
    String? fullName,
    String? phone,
  }) async {
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
        print("User data saved successfully");
      }

      return userCredential.user;
    } catch (e) {
      print("Error registering: $e");
      return null;
    }
  }


  Future<User?> signInWithGoogle() async {
    try {

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();


      if (googleUser == null) {
        print("User cancelled Google Sign-In");
        return null;
      }


      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

   
      UserCredential userCredential = await _auth.signInWithCredential(credential);


      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': userCredential.user!.email ?? '',
          'fullName': userCredential.user!.displayName ?? '',
          'phone': '',
          'photoURL': userCredential.user!.photoURL ?? '',
          'provider': 'google',
          'createdAt': FieldValue.serverTimestamp(),
        });
        print("Google user data saved to Firestore");
      } else {
        print("Existing Google user logged in");
      }

      return userCredential.user;
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }


 
  Future<void> signOut() async {
    await _googleSignIn.signOut(); 
    await _auth.signOut(); 
    print("User signed out");
  }

 
  Stream<User?> get user {
    return _auth.authStateChanges();
  }


  Future<void> resetPasswordFromCurrentPassword(
      String newPassword, String CurrentPass, String Email) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: Email,
          password: CurrentPass,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
        print("Password updated successfully");
      }
    } catch (e) {
      print("Error resetting password: $e");
    }
  }
}

void initializeAuthService() {
  authServiceNotifier.value = AuthService();
}