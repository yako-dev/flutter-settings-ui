import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

/// Demonstrates Material 3 theme integration.
///
/// Colors are derived from the active [ColorScheme], so the settings list
/// automatically adapts to light/dark mode and custom seed colors.
class Material3DemoScreen extends StatefulWidget {
  const Material3DemoScreen({super.key});

  @override
  State<Material3DemoScreen> createState() => _Material3DemoScreenState();
}

class _Material3DemoScreenState extends State<Material3DemoScreen> {
  bool _notifications = true;
  bool _locationAccess = false;
  bool _darkMode = false;
  final String _selectedLanguage = 'English';

  static const _seedColors = <String, Color>{
    'Default': Colors.blue,
    'Purple': Colors.deepPurple,
    'Green': Colors.green,
    'Orange': Colors.orange,
    'Red': Colors.red,
  };

  String _selectedSeed = 'Default';

  @override
  Widget build(BuildContext context) {
    final seedColor = _seedColors[_selectedSeed]!;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: _darkMode ? Brightness.dark : Brightness.light,
    );

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        brightness: _darkMode ? Brightness.dark : Brightness.light,
      ),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Material 3 Demo'),
            backgroundColor: colorScheme.surface,
          ),
          body: SettingsList(
            brightness: _darkMode ? Brightness.dark : Brightness.light,
            sections: [
              SettingsSection(
                title: const Text('Seed color'),
                tiles: [
                  for (final entry in _seedColors.entries)
                    SettingsTile(
                      title: Text(entry.key),
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundColor: entry.value,
                      ),
                      trailing: _selectedSeed == entry.key
                          ? const Icon(Icons.check)
                          : null,
                      onPressed: (_) =>
                          setState(() => _selectedSeed = entry.key),
                    ),
                ],
              ),
              SettingsSection(
                title: const Text('Appearance'),
                tiles: [
                  SettingsTile.switchTile(
                    initialValue: _darkMode,
                    onToggle: (v) => setState(() => _darkMode = v),
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Dark mode'),
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('Account'),
                tiles: [
                  SettingsTile.navigation(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    value: Text(_selectedLanguage),
                    onPressed: (_) {},
                  ),
                  SettingsTile.switchTile(
                    initialValue: _notifications,
                    onToggle: (v) => setState(() => _notifications = v),
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notifications'),
                    description: const Text('Alerts, sounds, badges'),
                  ),
                  SettingsTile.switchTile(
                    initialValue: _locationAccess,
                    onToggle: (v) => setState(() => _locationAccess = v),
                    leading: const Icon(Icons.location_on),
                    title: const Text('Location access'),
                    enabled: false,
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('Compact tiles'),
                tiles: [
                  SettingsTile(
                    compact: true,
                    leading: const Icon(Icons.compress),
                    title: const Text('Compact tile'),
                    description: const Text('Half vertical padding'),
                  ),
                  SettingsTile(
                    compact: true,
                    leading: const Icon(Icons.compress),
                    title: const Text('Another compact tile'),
                  ),
                  SettingsTile(
                    leading: const Icon(Icons.expand),
                    title: const Text('Normal tile (for comparison)'),
                  ),
                ],
              ),
              CustomSettingsSection(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Colors automatically adapt to the selected ColorScheme seed. '
                    'Try switching seeds or toggling dark mode above.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
