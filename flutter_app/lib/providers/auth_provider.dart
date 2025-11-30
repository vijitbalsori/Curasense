import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  bool get isLoggedIn => _token != null;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("token");
    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        return; // user cancelled
      }

      // CORRECT: Must use await (googleAuth is a Future)
      final GoogleSignInAuthentication googleAuth =
          await account.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user == null) {
        throw Exception("Sign-in failed: No user object returned.");
      }

      final String? idToken = await user.getIdToken();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", idToken!);

      _token = idToken;
      notifyListeners();
    } catch (e, st) {
      print("Google Login Exception: $e\n$st");
      rethrow;
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");

    _token = null;
    notifyListeners();
  }
}
