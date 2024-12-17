// Helper class to convert string icon names to IconData
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:font_awesome_flutter/name_icon_mapping.dart';

class IconDataHelper {
  static IconData? getIconData(String iconName) {
    // Remove 'fa-' prefix if present
    final icon = FaIcon(faIconNameMapping[iconName]);

    return icon.icon;
  }

  static String getIconName(IconData iconData) {
    final iconName = faIconNameMapping.entries
        .firstWhere((entry) => entry.value == iconData)
        .key;

    return iconName;
  }
}
