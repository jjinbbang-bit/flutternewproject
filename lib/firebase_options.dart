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
    apiKey: 'AIzaSyDFwFDkFSvaptIYqbjUjZqS5zrBjbeXbWc',
    appId: '1:553508340478:web:f9446457a796c0c3685baf',
    messagingSenderId: '553508340478',
    projectId: 'mygptrainer',
    authDomain: 'mygptrainer.firebaseapp.com',
    storageBucket: 'mygptrainer.appspot.com',
  );
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyALgy2i2i0604-hmftpsC52o_LRoj4N9Nk',
    appId: '1:553508340478:android:2facf95b3d122bf6685baf',
    messagingSenderId: '553508340478',
    projectId: 'mygptrainer',
    storageBucket: 'mygptrainer.appspot.com',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyABfbN-gspo6Lt66bb-OP1w4XQpLokGvhY',
    appId: '1:553508340478:ios:cf02734545c19a33685baf',
    messagingSenderId: '553508340478',
    projectId: 'mygptrainer',
    storageBucket: 'mygptrainer.appspot.com',
    androidClientId: '553508340478-mjdf4pfh8oee10kml65i9qmb7c6r4grk.apps.googleusercontent.com',
    iosClientId: '553508340478-vm1c0p5s7v8u24aiq3b8gmpip5p963ki.apps.googleusercontent.com',
    iosBundleId: 'com.example.mygptrainer',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyABfbN-gspo6Lt66bb-OP1w4XQpLokGvhY',
    appId: '1:553508340478:ios:cf02734545c19a33685baf',
    messagingSenderId: '553508340478',
    projectId: 'mygptrainer',
    storageBucket: 'mygptrainer.appspot.com',
    androidClientId: '553508340478-mjdf4pfh8oee10kml65i9qmb7c6r4grk.apps.googleusercontent.com',
    iosClientId: '553508340478-vm1c0p5s7v8u24aiq3b8gmpip5p963ki.apps.googleusercontent.com',
    iosBundleId: 'com.example.mygptrainer',
  );
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDFwFDkFSvaptIYqbjUjZqS5zrBjbeXbWc',
    appId: '1:553508340478:web:fd0fa9812df30f2e685baf',
    messagingSenderId: '553508340478',
    projectId: 'mygptrainer',
    authDomain: 'mygptrainer.firebaseapp.com',
    storageBucket: 'mygptrainer.appspot.com',
  );
}