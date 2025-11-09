import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for linux');
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAeeM_b3ElIQGMwOSkyHXrQZ1yMQb8YDvU',
    appId: '1:863382206691:web:67741ca5a8365af8ffadd6',
    messagingSenderId: '863382206691',
    projectId: 'bookswapapp-b246c',
    authDomain: 'bookswapapp-b246c.firebaseapp.com',
    storageBucket: 'bookswapapp-b246c.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAeeM_b3ElIQGMwOSkyHXrQZ1yMQb8YDvU',
    appId: '1:863382206691:android:67741ca5a8365af8ffadd6',
    messagingSenderId: '863382206691',
    projectId: 'bookswapapp-b246c',
    storageBucket: 'bookswapapp-b246c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAeeM_b3ElIQGMwOSkyHXrQZ1yMQb8YDvU',
    appId: '1:863382206691:ios:67741ca5a8365af8ffadd6',
    messagingSenderId: '863382206691',
    projectId: 'bookswapapp-b246c',
    storageBucket: 'bookswapapp-b246c.firebasestorage.app',
    iosBundleId: 'com.example.bookswapapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAeeM_b3ElIQGMwOSkyHXrQZ1yMQb8YDvU',
    appId: '1:863382206691:macos:67741ca5a8365af8ffadd6',
    messagingSenderId: '863382206691',
    projectId: 'bookswapapp-b246c',
    storageBucket: 'bookswapapp-b246c.firebasestorage.app',
    iosBundleId: 'com.example.bookswapapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAeeM_b3ElIQGMwOSkyHXrQZ1yMQb8YDvU',
    appId: '1:863382206691:windows:67741ca5a8365af8ffadd6',
    messagingSenderId: '863382206691',
    projectId: 'bookswapapp-b246c',
    storageBucket: 'bookswapapp-b246c.firebasestorage.app',
  );
}