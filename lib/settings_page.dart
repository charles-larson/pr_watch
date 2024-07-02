import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pr_watch/models/app_state.dart';
import 'package:pr_watch/models/settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.appState});
  final AppState appState;

  @override
  State<SettingsPage> createState() => _MembersState();
}

class _MembersState extends State<SettingsPage> {
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
  }

  void _sortChanged(SortMode? mode) async {
    setState(() {
      widget.appState.settings.sortMode = mode ?? SortMode.alphabetical;
    });
    await _storage.write(
        key: 'SETTINGS', value: widget.appState.settings.toString());
  }

  void _showYourDraftsChanged(bool value) async {
    setState(() {
      widget.appState.settings.showYourDrafts = value;
    });
    await _storage.write(
        key: 'SETTINGS', value: widget.appState.settings.toString());
  }

  void _showReviewedChanged(bool value) async {
    setState(() {
      widget.appState.settings.showReviewed = value;
    });
    await _storage.write(
        key: 'SETTINGS', value: widget.appState.settings.toString());
  }

  String _sortModeToString(SortMode mode) {
    switch (mode) {
      case SortMode.alphabetical:
        return 'Alphabetical';
      case SortMode.mostRecent:
        return 'Newest';
      case SortMode.leastRecent:
        return 'Oldest';
      case SortMode.bogo:
        return 'Bogo';
      default:
        return 'Unknown ($mode)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Settings',
            style: TextStyle(fontSize: 24, color: Colors.white)),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sort by:',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              DropdownButton<SortMode>(
                  value: widget.appState.settings.sortMode,
                  items: SortMode.values
                      .map((mode) => DropdownMenuItem<SortMode>(
                          value: mode,
                          child: Text(
                            _sortModeToString(mode),
                            style: const TextStyle(color: Colors.white),
                          )))
                      .toList(),
                  onChanged: _sortChanged),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Show your draft PRs:',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              Switch(
                  value: widget.appState.settings.showYourDrafts,
                  onChanged: _showYourDraftsChanged),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Show reviewed PRs:',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              Switch(
                  value: widget.appState.settings.showReviewed,
                  onChanged: _showReviewedChanged),
            ],
          ),
        ),
      ],
    );
  }
}
