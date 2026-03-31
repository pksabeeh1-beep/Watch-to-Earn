// File generated manually from google-services.json.
// For production, use `flutterfire configure` to auto-generate this.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS not configured. Run flutterfire configure.');
      default:
        throw UnsupportedError(
            'DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  // Android config from google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC5L0a7U7_A32dIHIqoUJNrBUpIzJ7AMio',
    appId: '1:240790015841:android:e19d71c9bf6b1fa8053f20',
    messagingSenderId: '240790015841',
    projectId: 'watch-to-earn-fc561',
    storageBucket: 'watch-to-earn-fc561.firebasestorage.app',
  );

  // Web config — NOTE: You MUST register a Web app in Firebase Console
  // and replace these values with your real web app config.
  // Firebase Console -> Project Settings -> Your Apps -> Add Web App
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC5L0a7U7_A32dIHIqoUJNrBUpIzJ7AMio',
    appId: '1:240790015841:web:REPLACE_WITH_WEB_APP_ID',
    messagingSenderId: '240790015841',
    projectId: 'watch-to-earn-fc561',
    storageBucket: 'watch-to-earn-fc561.firebasestorage.app',
    authDomain: 'watch-to-earn-fc561.firebaseapp.com',
  );
}
