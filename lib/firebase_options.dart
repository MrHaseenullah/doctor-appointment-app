// File generated by FlutterFire CLI.
// This file should be replaced with the actual Firebase configuration
// generated by the FlutterFire CLI.

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

  // Firebase configuration for appointmentapp-91254 project
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCRbizR50IgXNmL8J6LBE5J2kQMAxmUOlU',
    appId: '1:673201620072:web:0168826386a1d7e05c27dd',
    messagingSenderId: '673201620072',
    projectId: 'appointmentapp-91254',
    authDomain: 'appointmentapp-91254.firebaseapp.com',
    storageBucket: 'appointmentapp-91254.firebasestorage.app',
    measurementId: 'G-HJQ3795C9P',
    databaseURL: 'https://appointmentapp-91254-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey:
        'AIzaSyCRbizR50IgXNmL8J6LBE5J2kQMAxmUOlU', // Using web API key for now
    appId:
        '1:673201620072:android:xxxxxxxxxxxxxxxx', // Replace with actual Android App ID
    messagingSenderId: '673201620072',
    projectId: 'appointmentapp-91254',
    storageBucket: 'appointmentapp-91254.firebasestorage.app',
    databaseURL: 'https://appointmentapp-91254-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey:
        'AIzaSyCRbizR50IgXNmL8J6LBE5J2kQMAxmUOlU', // Using web API key for now
    appId:
        '1:673201620072:ios:xxxxxxxxxxxxxxxx', // Replace with actual iOS App ID
    messagingSenderId: '673201620072',
    projectId: 'appointmentapp-91254',
    storageBucket: 'appointmentapp-91254.firebasestorage.app',
    databaseURL: 'https://appointmentapp-91254-default-rtdb.firebaseio.com',
    iosClientId:
        'xxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com', // Replace with actual iOS Client ID
    iosBundleId: 'com.example.doctorAppointmentApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey:
        'AIzaSyCRbizR50IgXNmL8J6LBE5J2kQMAxmUOlU', // Using web API key for now
    appId:
        '1:673201620072:ios:xxxxxxxxxxxxxxxx', // Replace with actual macOS App ID
    messagingSenderId: '673201620072',
    projectId: 'appointmentapp-91254',
    storageBucket: 'appointmentapp-91254.firebasestorage.app',
    databaseURL: 'https://appointmentapp-91254-default-rtdb.firebaseio.com',
    iosClientId:
        'xxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com', // Replace with actual macOS Client ID
    iosBundleId: 'com.example.doctorAppointmentApp',
  );
}
