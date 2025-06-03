import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum UserRole { doctor, patient }

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  UserRole? _userRole;
  bool _isLoading = false;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserRole();
      } else {
        _userRole = null;
      }
      notifyListeners();
    });
  }

  User? get user => _user;
  UserRole? get userRole => _userRole;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _loadUserRole() async {
    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        final roleStr = doc.data()?['role'] as String?;
        if (roleStr == 'doctor') {
          _userRole = UserRole.doctor;
        } else if (roleStr == 'patient') {
          _userRole = UserRole.patient;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user role: $e');
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp(String email, String password, String name, UserRole role) async {
    try {
      _setLoading(true);
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'role': role == UserRole.doctor ? 'doctor' : 'patient',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      _userRole = role;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Sign up error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
    } finally {
      _setLoading(false);
    }
  }
}
