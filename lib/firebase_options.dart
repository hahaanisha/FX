// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyC5ZSuw4l5wL4MZasI1fQwV_lr2sxodKCU',
    appId: '1:14870803551:web:6d0d744abe64f53ba797ea',
    messagingSenderId: '14870803551',
    projectId: 'optiway-d6ee4',
    authDomain: 'optiway-d6ee4.firebaseapp.com',
    storageBucket: 'optiway-d6ee4.firebasestorage.app',
    measurementId: 'G-ZEMVWZ0MY9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBRYsldw3fFc-CdAvDGXS0at2DgevA56uo',
    appId: '1:14870803551:android:8c2e281ca0e875cba797ea',
    messagingSenderId: '14870803551',
    projectId: 'optiway-d6ee4',
    storageBucket: 'optiway-d6ee4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDfyDN1okFt9tnoL1FYlnme4PoiN5sEXZw',
    appId: '1:14870803551:ios:3c2eb052e29e7854a797ea',
    messagingSenderId: '14870803551',
    projectId: 'optiway-d6ee4',
    storageBucket: 'optiway-d6ee4.firebasestorage.app',
    iosBundleId: 'com.example.gehraneela',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDfyDN1okFt9tnoL1FYlnme4PoiN5sEXZw',
    appId: '1:14870803551:ios:3c2eb052e29e7854a797ea',
    messagingSenderId: '14870803551',
    projectId: 'optiway-d6ee4',
    storageBucket: 'optiway-d6ee4.firebasestorage.app',
    iosBundleId: 'com.example.gehraneela',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC5ZSuw4l5wL4MZasI1fQwV_lr2sxodKCU',
    appId: '1:14870803551:web:0e7b9a324c03fefda797ea',
    messagingSenderId: '14870803551',
    projectId: 'optiway-d6ee4',
    authDomain: 'optiway-d6ee4.firebaseapp.com',
    storageBucket: 'optiway-d6ee4.firebasestorage.app',
    measurementId: 'G-LWV58K247Y',
  );
}