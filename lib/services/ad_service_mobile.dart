import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdService {
  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-4608347725155936/4861961627'
      : 'ca-app-pub-4608347725155936/4861961627';

  Future<void> loadAd() async {
    if (_isLoading) return;
    _isLoading = true;

    await RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          _rewardedAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  Future<void> showAd({
    required Function(String) onRewardEarned,
    required Function(String) onError,
  }) async {
    if (_rewardedAd == null) {
      onError("Ad not loaded yet. Please wait a moment.");
      loadAd();
      return;
    }

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) async {
        try {
          await _verifyRewardOnServer();
          onRewardEarned("Reward verified! +10 Coins");
        } catch (e) {
          onError("Verification failed: $e");
        }
      },
    );

    _rewardedAd = null;
    loadAd();
  }

  Future<void> _verifyRewardOnServer() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (!snapshot.exists) throw Exception("User document not found");

        final data = snapshot.data()!;
        int adsToday = data['ads_watched_today'] ?? 0;
        final lastResetDate = data['last_reset_date'] as String?;
        final today = DateTime.now().toIso8601String().split('T')[0];

        if (lastResetDate != today) {
          adsToday = 0;
        }

        if (adsToday >= 20) {
          throw Exception("Daily ad limit reached.");
        }

        transaction.update(userRef, {
          'wallet_balance': FieldValue.increment(10),
          'total_earned': FieldValue.increment(10),
          'ads_watched_today': adsToday + 1,
          'last_reset_date': today,
          'last_ad_watched_time': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      debugPrint("Error verifying reward: $e");
      rethrow;
    }
  }
}
