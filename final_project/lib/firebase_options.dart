// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'dart:io';

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

Future<File> get _localFile async {
  return File('../api.txt');
}

Future<String> readAPI(int timeout) async {
  if (timeout == 0) return "";
  try {
    final file = await _localFile;

    // Read the file
    final contents = await file.readAsString();

    return contents;
  } catch (e) {
    // If encountering an error, return 0
    return readAPI(timeout-1);
  }
}
var api = readAPI(10).toString();
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
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

  static FirebaseOptions web = FirebaseOptions(
    apiKey: api,
    appId: '1:398220662642:web:c35f6dd48725bc3f082feb',
    messagingSenderId: '398220662642',
    projectId: 'iot-training-final-project',
    authDomain: 'iot-training-final-project.firebaseapp.com',
    databaseURL: 'https://iot-training-final-project-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'iot-training-final-project.appspot.com',
  );

  static FirebaseOptions android = FirebaseOptions(
    apiKey: api,
    appId: '1:398220662642:android:aa1153b92f5aa303082feb',
    messagingSenderId: '398220662642',
    projectId: 'iot-training-final-project',
    databaseURL: 'https://iot-training-final-project-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'iot-training-final-project.appspot.com',
  );
}
