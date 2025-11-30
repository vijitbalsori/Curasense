// lib/login_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(const MyApp());
}

/// Minimal app wrapper to test the LoginScreen directly.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Sign-In Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// A complete login screen that uses google_sign_in without `.instance`
/// and without relying on `currentUser` getter.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Create the GoogleSignIn object with the constructor (compatible with many versions)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      // add other scopes if needed
    ],
  );

  GoogleSignInAccount? _currentUser;
  StreamSubscription<GoogleSignInAccount?>? _authEventsSub;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    // Listen for auth changes (sign in / sign out)
    _authEventsSub = _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _currentUser = account;
      });
    });

    // Attempt silent sign-in if a previous account exists
    _trySignInSilently();
  }

  Future<void> _trySignInSilently() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final GoogleSignInAccount? acct = await _googleSignIn.signInSilently();
      setState(() {
        _currentUser = acct;
      });
    } catch (e) {
      // don't crash the UI; show a small error message if needed
      setState(() {
        _error = 'Silent sign-in failed: $e';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final GoogleSignInAccount? acct = await _googleSignIn.signIn();
      if (acct == null) {
        // user cancelled the sign-in dialog
        return;
      }
      await acct.authentication;
      // You can now use auth.accessToken / auth.idToken if you need to call your backend
      setState(() {
        _currentUser = acct;
      });
    } catch (e) {
      setState(() {
        _error = 'Sign-in failed: $e';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _handleSignOut() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // You can use signOut() or disconnect() as appropriate
      await _googleSignIn.signOut();
      setState(() {
        _currentUser = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Sign-out failed: $e';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  @override
  void dispose() {
    // cancel the subscription to avoid memory leaks
    _authEventsSub?.cancel();
    super.dispose();
  }

  Widget _buildSignedIn() {
    final name = _currentUser?.displayName ?? 'No name';
    final email = _currentUser?.email ?? 'No email';
    final photoUrl = _currentUser?.photoUrl;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (photoUrl != null)
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(photoUrl),
          )
        else
          const CircleAvatar(
            radius: 40,
            child: Icon(Icons.person, size: 40),
          ),
        const SizedBox(height: 12),
        Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(email, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 18),
        ElevatedButton.icon(
          onPressed: _busy ? null : _handleSignOut,
          icon: const Icon(Icons.logout),
          label: const Text('Sign out'),
        ),
      ],
    );
  }

  Widget _buildSignedOut() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const FlutterLogo(size: 80),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _busy ? null : _handleSignIn,
          icon: const Icon(Icons.login),
          label: const Text('Sign in with Google'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _busy ? null : _trySignInSilently,
          child: const Text('Try silent sign-in'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _currentUser == null ? _buildSignedOut() : _buildSignedIn();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Screen'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(child: body),
          if (_busy)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: _error == null
          ? null
          : Container(
              color: Colors.red.shade100,
              padding: const EdgeInsets.all(12),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
    );
  }
}
