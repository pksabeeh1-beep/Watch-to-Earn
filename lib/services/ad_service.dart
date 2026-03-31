import 'package:flutter/foundation.dart';
// Only import google_mobile_ads on non-web platforms
import 'ad_service_stub.dart'
    if (dart.library.io) 'ad_service_mobile.dart' as _impl;

class AdService {
  final _impl.AdService _delegate = _impl.AdService();

  Future<void> loadAd() => _delegate.loadAd();

  Future<void> showAd({
    required Function(String) onRewardEarned,
    required Function(String) onError,
  }) =>
      _delegate.showAd(onRewardEarned: onRewardEarned, onError: onError);
}
