import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _isNotifOn = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentTheme();
  }

  void _loadCurrentTheme() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    setState(() {
      _isDarkMode = savedThemeMode == AdaptiveThemeMode.dark;
    });
  }

  void _toggleTheme(bool isDark) {
    if (isDark) {
      AdaptiveTheme.of(context).setDark();
    } else {
      AdaptiveTheme.of(context).setLight();
    }
    setState(() {
      _isDarkMode = isDark;
    });
  }

  void _toggleNotifications(bool isNotifOn) {
    setState(() {
      _isNotifOn = isNotifOn;
    });
  }

  String _selectedLanguage = 'English';

  void _changeLanguage(String? language) {
    setState(() {
      _selectedLanguage = language!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: SwitchListTile(
              value: _isDarkMode,
              onChanged: (value) {
                _toggleTheme(value);
              },
              title: const Text(
                'Dark mode',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: SwitchListTile(
              value: _isNotifOn,
              onChanged: (value) {
                _toggleNotifications(value);
              },
              title: const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: ListTile(
              leading: const Text(
                "Language",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                onChanged: _changeLanguage,
                items: ['English', 'French'].map((String language) {
                  return DropdownMenuItem<String>(
                    value: language,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Text(language),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
