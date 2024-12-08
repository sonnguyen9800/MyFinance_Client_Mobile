import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class EnvironmentConfig {
  static const String serverCode = String.fromEnvironment(
    'SERVER_CODE',
    defaultValue: 'MF_SERVER_2024DEC_0.0.1',
  );
}
