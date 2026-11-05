import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pr_watch/app_theme.dart';
import 'package:pr_watch/models/app_state.dart';
import 'package:pr_watch/models/repository.dart';

// Dropdown of team repositories with a checkbox for each one. Bot PRs only
// show on the Watch page from checked repositories.
class RepoFilterMenu extends StatefulWidget {
  const RepoFilterMenu({super.key, required this.appState});
  final AppState appState;

  @override
  State<RepoFilterMenu> createState() => _RepoFilterMenuState();
}

class _RepoFilterMenuState extends State<RepoFilterMenu> {
  final _storage = const FlutterSecureStorage();
  String _repoFilter = '';

  Future<void> _setReposWatched(
      Iterable<Repository> repos, bool watching) async {
    setState(() {
      for (var repo in repos) {
        widget.appState.isBotRepoWatched[repo.id] = watching;
      }
    });
    await _storage.write(
        key: 'BOT_REPOS',
        value: widget.appState.isBotRepoWatched.entries
            .where((element) => element.value)
            .map((x) => x.key)
            .join(','));
  }

  void _onClose() {
    if (!mounted) return;
    setState(() {
      _repoFilter = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final repos = widget.appState.repositories;
    final watchedCount = repos
        .where((repo) => widget.appState.isBotRepoWatched[repo.id] == true)
        .length;
    final shownRepos = repos
        .where((repo) =>
            repo.name.toLowerCase().contains(_repoFilter.toLowerCase()))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return MenuAnchor(
      onClose: _onClose,
      menuChildren: [
        SizedBox(
          width: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Filter repos',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) => setState(() => _repoFilter = value),
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _setReposWatched(shownRepos, true),
                    child: const Text('Select all'),
                  ),
                  TextButton(
                    onPressed: () => _setReposWatched(shownRepos, false),
                    child: const Text('Clear all'),
                  ),
                ],
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  primary: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var repo in shownRepos)
                        CheckboxMenuButton(
                          value:
                              widget.appState.isBotRepoWatched[repo.id] == true,
                          closeOnActivate: false,
                          onChanged: (value) =>
                              _setReposWatched([repo], value ?? false),
                          child: Text(repo.name),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      builder: (context, controller, child) => OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.text,
          minimumSize: const Size(0, 56),
        ),
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        icon: const Icon(Icons.filter_list),
        label: Text('Repos ($watchedCount of ${repos.length})'),
      ),
    );
  }
}
