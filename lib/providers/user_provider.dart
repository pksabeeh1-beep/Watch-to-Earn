import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:watch_to_earn_app/models/user_model.dart';
import 'package:watch_to_earn_app/services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _userModel;
  User? _firebaseUser;
  StreamSubscription? _userSubscription;

  UserModel? get user => _userModel;
  bool get isLoading => _userModel == null && _firebaseUser != null;

  UserProvider() {
    _authService.authStateChanges.listen((User? user) {
      _firebaseUser = user;
      if (user != null) {
        _subscribeToUser(user.uid);
      } else {
        _userModel = null;
        _userSubscription?.cancel();
        notifyListeners();
      }
    });
  }

  void _subscribeToUser(String uid) {
    _userSubscription?.cancel();
    _userSubscription = _firestore.collection('users').doc(uid).snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        _userModel = UserModel.fromMap(snapshot.data()!, uid);
        notifyListeners();
      }
    });
  }

  Future<void> signInWithGoogle({Function(String)? onError}) async {
    await _authService.signInWithGoogle(onError: onError);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  bool get canWatchAd {
    if (_userModel == null) return false;
    
    // Check Daily Cap
    if (_userModel!.adsWatchedToday >= 20) return false;

    // Check Cooldown
    if (_userModel!.lastAdWatchedTime == null) return true;
    
    final difference = DateTime.now().difference(_userModel!.lastAdWatchedTime!);
    return difference.inSeconds >= 60;
  }
  
  Duration get cooldownRemaining {
    if (_userModel == null || _userModel!.lastAdWatchedTime == null) return Duration.zero;
    final endCooldown = _userModel!.lastAdWatchedTime!.add(const Duration(seconds: 60));
    final remaining = endCooldown.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
