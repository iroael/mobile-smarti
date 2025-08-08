import 'dart:io';

class Environment {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:4000';
    } else {
      return 'http://localhost:4000';
    }
  }
}
