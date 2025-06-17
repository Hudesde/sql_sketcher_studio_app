// File generated for Firebase initialization
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA9z7ctUAroLiamAGWWLIbgXLgzSuWAxi0',
    authDomain: 'sql-ketcher-studio-app.firebaseapp.com',
    projectId: 'sql-ketcher-studio-app',
    storageBucket: 'sql-ketcher-studio-app.firebasestorage.app',
    messagingSenderId: '433397743399',
    appId: '1:433397743399:web:17c095047c511807d9f302',
    measurementId: 'G-SFEJYFVTP7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC3mjVu9FRovqpWbPjabHBGGtHAa0XKl5A',
    appId: '1:433397743399:android:358b790aac4eb88bd9f302',
    messagingSenderId: '433397743399',
    projectId: 'sql-ketcher-studio-app',
    storageBucket: 'sql-ketcher-studio-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: 'sql-ketcher-studio-app',
    storageBucket: 'sql-ketcher-studio-app.firebasestorage.app',
    iosClientId: '',
    iosBundleId: '',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: 'sql-ketcher-studio-app',
    storageBucket: 'sql-ketcher-studio-app.firebasestorage.app',
    iosClientId: '',
    iosBundleId: '',
  );
}
