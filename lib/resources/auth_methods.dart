import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Password validation - check strength
  static Map<String, bool> validatePassword(String password) {
    return {
      'hasMinLength': password.length >= 8,
      'hasUppercase': password.contains(RegExp(r'[A-Z]')),
      'hasLowercase': password.contains(RegExp(r'[a-z]')),
      'hasNumbers': password.contains(RegExp(r'[0-9]')),
      'hasSpecialChar': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
    };
  }

  // Check if password is strong
  static bool isPasswordStrong(String password) {
    final validation = validatePassword(password);
    return validation.values.where((v) => v).length >= 4; // At least 4 criteria
  }

  // Email validation
  static bool isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  // Username validation
  static bool isValidUsername(String username) {
    return RegExp(r'^[a-zA-Z0-9_.-]{3,30}$').hasMatch(username);
  }

Future<model.User> getUserDetails() async {
  User currentUser = _auth.currentUser!;

  for (int i = 0; i < 3; i++) {
    DocumentSnapshot snap = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();
    
    if (snap.exists && snap.data() != null) {
      return model.User.fromSnap(snap);
    }
    
    // Wait before retrying (increasing delay)
    if (i < 2) {
      await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
    }
  }
  
  throw Exception('User document not found in Firestore after multiple attempts');
}

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List? file,
  }) async {
    String res = "Some error occurred";
    try {
      // Validate all inputs
      if (email.isEmpty) {
        return "Email cannot be empty";
      }
      if (!isValidEmail(email)) {
        return "Please enter a valid email";
      }
      if (password.isEmpty) {
        return "Password cannot be empty";
      }
      if (!isPasswordStrong(password)) {
        return "Password must be at least 8 characters with uppercase, lowercase, number, and special character";
      }
      if (username.isEmpty) {
        return "Username cannot be empty";
      }
      if (!isValidUsername(username)) {
        return "Username must be 3-30 characters (letters, numbers, _, -, .)";
      }

      // Check if username already exists
      final existingUser = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .get();

      if (existingUser.docs.isNotEmpty) {
        return "Username already taken";
      }

      // Register user with Firebase Auth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Upload profile picture if provided, otherwise use default
      String photoUrl = file != null
          ? await StorageMethods().uploadImageToStorage(
              'profilePics',
              file,
              false,
            )
          : "https://imgs.search.brave.com/fPJ6Tux_AaVRM3SG6dWs-BiFRSzG1cq-37KGDToX334/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9pbWcu/ZnJlZXBpay5jb20v/ZnJlZS12ZWN0b3Iv/ZHNsci1waG90b2dy/YXBoeS1jYW1lcmEt/ZmxhdC1zdHlsZV83/ODM3MC04MzUuanBn/P3NlbXQ9YWlzX2h5/YnJpZCZ3PTc0MA";

      model.User user = model.User(
        username: username.toLowerCase(),
        uid: cred.user!.uid,
        email: email,
        bio: bio.isNotEmpty ? bio : "Hey, I'm using Instagram!",
        photoUrl: photoUrl,
        followers: [],
        following: [],
      );

      // Add user to database
      await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .set(user.toJson());

      res = "success";
    } on FirebaseAuthException catch (err) {
      if (err.code == 'weak-password') {
        res = "Password is too weak";
      } else if (err.code == 'email-already-in-use') {
        res = "Email is already in use";
      } else if (err.code == 'invalid-email') {
        res = "Invalid email address";
      } else {
        res = err.message ?? "Authentication failed";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }


  // login user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "some error occurred";
    try {

       if (email.isEmpty || password.isEmpty) {
        return "Please enter all the fields";
      }

      if (!isValidEmail(email)) {
        return "Please enter a valid email";
      }

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      res = "success";
    } on FirebaseAuthException catch (err) {
      if (err.code == 'user-not-found') {
        res = "Email not registered";
      } else if (err.code == 'wrong-password') {
        res = "Incorrect password";
      } else {
        res = err.message ?? "Login failed";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
  
}
