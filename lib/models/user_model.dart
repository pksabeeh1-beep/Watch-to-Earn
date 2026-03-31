import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final int walletBalance;
  final int totalEarned;
  final int adsWatchedToday;
  final DateTime? lastAdWatchedTime;

  UserModel({
    required this.uid,
    required this.email,
    required this.walletBalance,
    required this.totalEarned,
    required this.adsWatchedToday,
    this.lastAdWatchedTime,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      walletBalance: data['wallet_balance'] ?? 0,
      totalEarned: data['total_earned'] ?? 0,
      adsWatchedToday: data['ads_watched_today'] ?? 0,
      lastAdWatchedTime: (data['last_ad_watched_time'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'wallet_balance': walletBalance,
      'total_earned': totalEarned,
      'ads_watched_today': adsWatchedToday,
      'last_ad_watched_time': lastAdWatchedTime,
    };
  }
}
