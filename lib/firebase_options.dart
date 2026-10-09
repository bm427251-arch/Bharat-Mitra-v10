import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForBharatMitraWeb',
    appId: '1:1234567890:web:bharatmitra',
    messagingSenderId: '1234567890',
    projectId: 'bharat-mitra-v10',
    storageBucket: 'bharat-mitra-v10.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForBharatMitraAndroid',
    appId: '1:1234567890:android:bharatmitra',
    messagingSenderId: '1234567890',
    projectId: 'bharat-mitra-v10',
    storageBucket: 'bharat-mitra-v10.appspot.com',
  );
}
