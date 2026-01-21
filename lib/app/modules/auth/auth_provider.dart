import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final forgotPasswordEmailController = TextEditingController();

  int _authModeIndex = 0; // 0 for Login, 1 for Register
  int get authModeIndex => _authModeIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  void switchView(int index) {
    _authModeIndex = index;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      _setLoading(true);
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Check for admin role in Firestore
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      _isAdmin = userDoc.data()?['role'] == 'admin';
      notifyListeners();

      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Authentication failed")),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty || nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      _setLoading(true);
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Save user to Firestore
      await _saveUserToFirestore(userCredential.user!, nameController.text.trim());

      // Sign out since Firebase auto-signs in on registration
      await _auth.signOut();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully! Please sign in.")),
        );
        switchView(0); // Switch to Login view
        // Clear registration fields
        nameController.clear();
        passwordController.clear();
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Registration failed")),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      _setLoading(true);
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setLoading(false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Save user to Firestore if new
        await _saveUserToFirestore(user, googleUser.displayName ?? "");

        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Error: ${e.code} - ${e.message}");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Auth Error: ${e.message ?? 'Unknown error'}")),
        );
      }
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign-In failed. Please check your internet and Google settings.")),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleAdminRole(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    _isAdmin = !_isAdmin;
    await _firestore.collection('users').doc(user.uid).update({'role': _isAdmin ? 'admin' : 'user'});
    notifyListeners();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Role changed to: ${_isAdmin ? 'Admin' : 'User'}")),
      );
    }
  }

  Future<void> _saveUserToFirestore(User user, String name) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'email': user.email,
      'role': 'user', // Default role
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  Future<void> resetPassword(BuildContext context) async {
    if (forgotPasswordEmailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email")),
      );
      return;
    }

    try {
      _setLoading(true);
      await _auth.sendPasswordResetEmail(email: forgotPasswordEmailController.text.trim());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset email sent!")),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Failed to send reset email")),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    forgotPasswordEmailController.dispose();
    super.dispose();
  }
}
