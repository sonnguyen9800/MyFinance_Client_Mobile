import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'
show SharedPreferences;

class SettingsController extends GetxController {
  final _prefs = SharedPreferences.getInstance();
  final RxString language = 'en'.obs;
  final RxBool isDarkMode = false.obs;
  final RxDouble fontSize = 14.0.obs;
  final RxString currency = 'VND'.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await _prefs;
    language.value = prefs.getString('language') ?? 'en';
    isDarkMode.value = prefs.getBool('isDarkMode') ?? false;
    fontSize.value = prefs.getDouble('fontSize') ?? 14.0;
    currency.value = prefs.getString('currency') ?? 'VND';
  }

  Future<void> saveSettings() async {
    final prefs = await _prefs;
    await prefs.setString('language', language.value);
    await prefs.setBool('isDarkMode', isDarkMode.value);
    await prefs.setDouble('fontSize', fontSize.value);
    await prefs.setString('currency', currency.value);
  }
}

class SettingsView extends StatelessWidget {
  SettingsView({super.key});

  final SettingsController _settingsController = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildLanguageSection(),
          const Divider(),
          _buildThemeSection(),
          const Divider(),
          _buildFontSizeSection(),
          const Divider(),
          _buildCurrencySection(),
        ],
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Obx(() => ListTile(
          title: const Text('Language'),
          subtitle: Text(_settingsController.language.value == 'en'
              ? 'English'
              : 'Tiếng Việt'),
          trailing: DropdownButton<String>(
            value: _settingsController.language.value,
            items: const [
              DropdownMenuItem(
                value: 'en',
                child: Text('English'),
              ),
              DropdownMenuItem(
                value: 'vi',
                child: Text('Tiếng Việt'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                _settingsController.language.value = value;
                _settingsController.saveSettings();
              }
            },
          ),
        ));
  }

  Widget _buildThemeSection() {
    return Obx(() => SwitchListTile(
          title: const Text('Dark Mode'),
          subtitle: Text(_settingsController.isDarkMode.value
              ? 'Dark theme enabled'
              : 'Light theme enabled'),
          value: _settingsController.isDarkMode.value,
          onChanged: (value) {
            _settingsController.isDarkMode.value = value;
            _settingsController.saveSettings();
            // TODO: Implement theme switching
          },
        ));
  }

  Widget _buildFontSizeSection() {
    return Obx(() => ListTile(
          title: const Text('Font Size'),
          subtitle: Text('${_settingsController.fontSize.value.toInt()}'),
          trailing: SizedBox(
            width: 200,
            child: Slider(
              value: _settingsController.fontSize.value,
              min: 12,
              max: 24,
              divisions: 6,
              label: _settingsController.fontSize.value.toInt().toString(),
              onChanged: (value) {
                _settingsController.fontSize.value = value;
                _settingsController.saveSettings();
              },
            ),
          ),
        ));
  }

  Widget _buildCurrencySection() {
    return Obx(() => ListTile(
          title: const Text('Currency'),
          subtitle: Text(_settingsController.currency.value),
          trailing: DropdownButton<String>(
            value: _settingsController.currency.value,
            items: const [
              DropdownMenuItem(
                value: 'VND',
                child: Text('VND (₫)'),
              ),
              DropdownMenuItem(
                value: 'USD',
                child: Text('USD (\$)'),
              ),
              DropdownMenuItem(
                value: 'EUR',
                child: Text('EUR (€)'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                _settingsController.currency.value = value;
                _settingsController.saveSettings();
              }
            },
          ),
        ));
  }
}
