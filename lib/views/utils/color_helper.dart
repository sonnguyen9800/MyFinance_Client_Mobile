import 'dart:ui';

class ColorHelper {
  static Color? getColor(String hexString) {
    return Color(int.parse(hexString.substring(1), radix: 16));
  }
}
