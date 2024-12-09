class EnvironmentConfig {
  static const String serverCode = String.fromEnvironment(
    'SERVER_CODE',
    defaultValue: 'MF_SERVER_2024DEC_0.0.1',
  );
}
