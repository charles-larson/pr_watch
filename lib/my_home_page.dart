import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pr_watch/configure_state.dart';
import 'package:pr_watch/empty_state.dart';
import 'package:pr_watch/load_state.dart';
import 'package:pr_watch/members.dart';
import 'package:pr_watch/models/app_state.dart';
import 'package:pr_watch/profile.dart';
import 'package:pr_watch/repos.dart';
import 'package:pr_watch/settings_page.dart';
import 'package:pr_watch/watch.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AppState _appState = AppState();
  final storage = const FlutterSecureStorage();
  late Widget _currentWidget;
  int _selectedIndex = 0;

  void setToken(String token) async {
    await storage.write(key: 'GITHUB_TOKEN', value: token);
    setState(() {
      _currentWidget = LoadState(onLoaded: loadState);
    });
  }

  void loadState(AppState state) {
    setState(() {
      _appState = state;
      if (_appState.currentUser == null) {
        _currentWidget = EmptyState(onTokenSet: setToken);
      } else if (!_appState.configured) {
        _currentWidget =
            ConfigureState(appState: _appState, onLoaded: loadState);
      } else {
        _currentWidget = Watch(appState: _appState);
        _selectedIndex = 0;
      }
    });
  }

  void _logout() async {
    await storage.deleteAll();
    setState(() {
      _appState = AppState();
      _currentWidget = EmptyState(onTokenSet: setToken);
    });
  }

  @override
  void initState() {
    super.initState();
    _currentWidget = LoadState(onLoaded: loadState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceDim,
      drawer: _appState.configured
          ? Drawer(
              child: ListView(padding: EdgeInsets.zero, children: [
              ListTile(
                title: const Text('Watch'),
                selected: _selectedIndex == 0,
                onTap: () {
                  setState(() {
                    _selectedIndex = 0;
                    _currentWidget = Watch(appState: _appState);
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Repos'),
                selected: _selectedIndex == 1,
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                    _currentWidget = Repos(appState: _appState);
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Members'),
                selected: _selectedIndex == 2,
                onTap: () {
                  setState(() {
                    _selectedIndex = 2;
                    _currentWidget = Members(appState: _appState);
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Settings'),
                selected: _selectedIndex == 3,
                onTap: () {
                  setState(() {
                    _selectedIndex = 3;
                    _currentWidget = SettingsPage(appState: _appState);
                  });
                  Navigator.pop(context);
                },
              ),
            ]))
          : null,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Text(
              widget.title,
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const Spacer(),
            if (_appState.currentUser != null) ...[
              Text(
                _appState.currentUser!.name ?? _appState.currentUser!.login,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              PopupMenuButton(
                tooltip: 'User Menu',
                position: PopupMenuPosition.under,
                onSelected: (value) {
                  if (value == 'logout') {
                    _logout();
                  }
                  if (value == 'profile') {
                    setState(() {
                      _currentWidget = Profile(user: _appState.currentUser!);
                      _selectedIndex = -1;
                    });
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: ListTile(
                      title: Text('Profile'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      title: Text('Logout'),
                    ),
                  ),
                ],
                child: CircleAvatar(
                  backgroundImage:
                      NetworkImage(_appState.currentUser!.avatarUrl),
                ),
              ),
            ]
          ],
        ),
      ),
      body: SizedBox(width: double.infinity, child: _currentWidget),
    );
  }
}
