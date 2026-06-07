import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError('Only web is supported.');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA63d5b6u4Vk9Sc6oRGb1SpYHPVQzzBYX0',
    authDomain: 'weather-app-9b9ab.firebaseapp.com',
    projectId: 'weather-app-9b9ab',
    storageBucket: 'weather-app-9b9ab.firebasestorage.app',
    messagingSenderId: '901057834093',
    appId: '1:901057834093:web:c3ef5b3e18194c5bcee364',
    measurementId: 'G-VH3VMQFFPF',
  );
}