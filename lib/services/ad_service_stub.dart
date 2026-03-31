// Stub AdService for web/desktop builds where google_mobile_ads is not supported.
class AdService {
  Future<void> loadAd() async {}

  Future<void> showAd({
    required Function(String) onRewardEarned,
    required Function(String) onError,
  }) async {
    onError("Ads are only available on Android/iOS.");
  }
}
