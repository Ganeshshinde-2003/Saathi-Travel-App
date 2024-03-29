// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAMyiGMj6L72zCRddNR6pzcsC_NEbQERfU',
    appId: '1:659497682147:web:d655129c815ab1b9c7f1d6',
    messagingSenderId: '659497682147',
    projectId: 'travelapp-fa791',
    authDomain: 'travelapp-fa791.firebaseapp.com',
    storageBucket: 'travelapp-fa791.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDDD9zzgUdhQfaaPlkS_idzEP5Zzon68mc',
    appId: '1:659497682147:android:8cefa0e55d971e58c7f1d6',
    messagingSenderId: '659497682147',
    projectId: 'travelapp-fa791',
    storageBucket: 'travelapp-fa791.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDyb1EFOfwoCgWzNDKLGQQp_oVxiDsEDz8',
    appId: '1:659497682147:ios:68bb3b7c3da6e92fc7f1d6',
    messagingSenderId: '659497682147',
    projectId: 'travelapp-fa791',
    storageBucket: 'travelapp-fa791.appspot.com',
    iosBundleId: 'com.example.myapp',
  );
}
