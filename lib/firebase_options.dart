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
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'ADD-YOUR-WEB-API-KEY',
    appId: 'ADD-YOUR-WEB-APP-ID',
    messagingSenderId: 'ADD-YOUR-SENDER-ID',
    projectId: 'ADD-YOUR-PROJECT-ID',
    authDomain: 'ADD-YOUR-AUTH-DOMAIN',
    storageBucket: 'ADD-YOUR-STORAGE-BUCKET',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAshNHlHIPI0iTiNF9Qju-zpH5QN3oRqSA',
    appId: '1:593038958929:android:db2bf9a3b3882dbf657370',
    messagingSenderId: '593038958929',
    projectId: 'fitness-tracker-6d5e8',
    storageBucket: 'fitness-tracker-6d5e8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'ADD-YOUR-IOS-API-KEY',
    appId: 'ADD-YOUR-IOS-APP-ID',
    messagingSenderId: 'ADD-YOUR-SENDER-ID',
    projectId: 'ADD-YOUR-PROJECT-ID',
    storageBucket: 'ADD-YOUR-STORAGE-BUCKET',
    iosClientId: 'ADD-YOUR-IOS-CLIENT-ID',
    iosBundleId: 'com.yourcompany.trackme',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'ADD-YOUR-MACOS-API-KEY',
    appId: 'ADD-YOUR-MACOS-APP-ID',
    messagingSenderId: 'ADD-YOUR-SENDER-ID',
    projectId: 'ADD-YOUR-PROJECT-ID',
    storageBucket: 'ADD-YOUR-STORAGE-BUCKET',
    iosClientId: 'ADD-YOUR-MACOS-CLIENT-ID',
    iosBundleId: 'com.yourcompany.trackme',
  );
} 