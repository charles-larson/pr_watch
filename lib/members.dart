import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pr_watch/app_theme.dart';
import 'package:pr_watch/models/app_state.dart';
import 'package:pr_watch/models/member.dart';
import 'package:pr_watch/repo_filter_menu.dart';
import 'package:pr_watch/services/github_service.dart';
import 'package:pr_watch/services/snackbar_service.dart';

class Members extends StatefulWidget {
  const Members({super.key, required this.appState});
  final AppState appState;

  @override
  State<Members> createState() => _MembersState();
}

class _MembersState extends State<Members> {
  final _storage = const FlutterSecureStorage();
  var _sortedMembers = <Member>[];
  var _sortedWatched = <bool>[];
  var _sortedAdminReviewer = <bool>[];
  var _sortedLevels = <int>[];
  final _botLoginController = TextEditingController();
  bool _addingBot = false;

  Future<void> _setWatching(int index, bool watching) async {
    widget.appState.isMemberWatched[_sortedMembers[index].id] = watching;
    _sortMembers();
    setState(() {});
    await _saveWatched();
  }

  Future<void> _saveWatched() async {
    await _storage.write(
        key: 'WATCHED_MEMBERS',
        value: widget.appState.isMemberWatched.entries
            .where((element) => element.value)
            .map((x) => x.key)
            .join(','));
  }

  Future<void> _saveBots() async {
    await _storage.write(
        key: 'BOTS',
        value: widget.appState.bots.map((bot) => bot.login).join(','));
  }

  Future<void> _addBot() async {
    var login = _botLoginController.text.trim();
    if (login.isEmpty || _addingBot) return;
    // GitHub App accounts always end in [bot].
    if (!login.endsWith('[bot]')) {
      login = '$login[bot]';
    }
    if (widget.appState.bots
        .any((bot) => bot.login.toLowerCase() == login.toLowerCase())) {
      SnackbarService.show(context, '$login is already added.');
      return;
    }
    setState(() {
      _addingBot = true;
    });
    try {
      final bot = await GithubService.instance.fetchMember(login);
      if (!mounted) return;
      if (bot.type != 'Bot') {
        SnackbarService.show(context, '$login is not a bot account.');
        return;
      }
      setState(() {
        widget.appState.bots.add(bot);
        widget.appState.isMemberWatched[bot.id] = true;
        _botLoginController.clear();
      });
      await _saveBots();
      await _saveWatched();
    } on Exception catch (e) {
      if (!mounted) return;
      SnackbarService.show(context, e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _addingBot = false;
        });
      }
    }
  }

  Future<void> _setBotWatching(Member bot, bool watching) async {
    setState(() {
      widget.appState.isMemberWatched[bot.id] = watching;
    });
    await _saveWatched();
  }

  Future<void> _removeBot(Member bot) async {
    setState(() {
      widget.appState.bots.remove(bot);
      widget.appState.isMemberWatched.remove(bot.id);
    });
    await _saveBots();
    await _saveWatched();
  }

  Future<void> _setAdminReviewer(int index, bool isAdminReviewer) async {
    widget.appState.isAdminReviewer[_sortedMembers[index].id] = isAdminReviewer;
    _sortMembers();
    setState(() {});
    await _storage.write(
        key: 'ADMIN_REVIEWER',
        value: widget.appState.isAdminReviewer.entries
            .where((element) => element.value)
            .map((x) => x.key)
            .join(','));
  }

  Future<void> _setLevel(int index, int level) async {
    widget.appState.memberLevel[_sortedMembers[index].id] = level;
    setState(() {
      _sortedLevels[index] = level;
    });
    await _storage.write(
        key: 'MEMBER_LEVELS',
        value: widget.appState.memberLevel.entries
            .map((e) => '${e.key}:${e.value}')
            .join(','));
    if (level == 1) {
      _setAdminReviewer(index, false);
    }
  }

  @override
  void initState() {
    super.initState();
    _sortMembers();
  }

  @override
  void dispose() {
    _botLoginController.dispose();
    super.dispose();
  }

  void _sortMembers() {
    _sortedMembers.clear();
    _sortedWatched.clear();
    _sortedAdminReviewer.clear();
    _sortedLevels.clear();
    for (var i = 0; i < widget.appState.members.length; i++) {
      if (widget.appState.isMemberWatched[widget.appState.members[i].id] ==
          true) {
        _sortedMembers.insert(0, widget.appState.members[i]);
        _sortedLevels.insert(
            0, widget.appState.memberLevel[widget.appState.members[i].id] ?? 1);
        _sortedWatched.insert(0, true);
        _sortedAdminReviewer.insert(
            0,
            widget.appState.isAdminReviewer[widget.appState.members[i].id] ??
                false);
      } else {
        _sortedMembers.add(widget.appState.members[i]);
        _sortedLevels.add(
            widget.appState.memberLevel[widget.appState.members[i].id] ?? 1);
        _sortedWatched.add(false);
        _sortedAdminReviewer.add(
            widget.appState.isAdminReviewer[widget.appState.members[i].id] ??
                false);
      }
    }
    setState(() {
      _sortedMembers = _sortedMembers;
      _sortedWatched = _sortedWatched;
      _sortedLevels = _sortedLevels;
      _sortedAdminReviewer = _sortedAdminReviewer;
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24, color: AppColors.of(context).text),
      ),
    );
  }

  // Row 0 is the Bots header, row 1 the repo picker, then one row per bot,
  // then the add field.
  Widget _buildBotRow(int row) {
    final colors = AppColors.of(context);
    final bots = widget.appState.bots;
    if (row == 0) {
      return _buildSectionHeader('Bots');
    }
    if (row == 1) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Row(
          children: [
            Text(
              'Only show bot PRs from',
              style: TextStyle(fontSize: 20, color: colors.text),
            ),
            const SizedBox(width: 12),
            RepoFilterMenu(appState: widget.appState),
          ],
        ),
      );
    }
    if (row > bots.length + 1) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _botLoginController,
                style: TextStyle(color: colors.text),
                decoration: InputDecoration(
                  labelText: 'Add a bot by name, e.g. dependabot[bot]',
                  labelStyle: TextStyle(color: colors.text),
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addBot(),
              ),
            ),
            const SizedBox(width: 12),
            _addingBot
                ? const SizedBox(
                    height: 32,
                    width: 32,
                    child: CircularProgressIndicator(),
                  )
                : OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.text,
                      minimumSize: const Size(0, 56),
                    ),
                    onPressed: _addBot,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
          ],
        ),
      );
    }
    final bot = bots[row - 2];
    final watching = widget.appState.isMemberWatched[bot.id] == true;
    return Material(
      color: row.isEven ? Colors.black26 : Colors.black12,
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        title: Text(
          bot.login,
          style: TextStyle(fontSize: 20, color: colors.text),
        ),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(bot.avatarUrl!),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                watching ? Icons.visibility : Icons.visibility_off,
                semanticLabel: watching
                    ? 'Stop watching ${bot.login}'
                    : 'Watch ${bot.login}',
              ),
              onPressed: () => _setBotWatching(bot, !watching),
              color: colors.mutedText,
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                semanticLabel: 'Remove ${bot.login}',
              ),
              onPressed: () => _removeBot(bot),
              color: colors.mutedText,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final memberCount = widget.appState.members.length;
    // Rows: Team members header, members, then the Bots section.
    return ListView.builder(
        itemCount: memberCount + widget.appState.bots.length + 4,
        itemBuilder: (context, row) {
          if (row == 0) {
            return _buildSectionHeader('Team members');
          }
          final index = row - 1;
          if (index >= memberCount) {
            return _buildBotRow(index - memberCount);
          }
          return Material(
            color: index.isEven ? Colors.black26 : Colors.black12,
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              title: Text(
                _sortedMembers[index].login,
                style: TextStyle(fontSize: 20, color: colors.text),
              ),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(_sortedMembers[index].avatarUrl!),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ToggleButtons(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      selectedColor: Colors.white,
                      color: Colors.grey,
                      fillColor: Colors.blue,
                      borderColor: Colors.blue,
                      isSelected: _sortedLevels[index] == 1
                          ? [true, false]
                          : [false, true],
                      onPressed: (int i) {
                        _setLevel(index, i + 1);
                      },
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Level 1'),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Level 2'),
                        ),
                      ]),
                  const SizedBox(width: 20),
                  if (widget.appState.settings.useTwoStepLevel2Reviews)
                    IconButton(
                      icon: Icon(
                        _sortedLevels[index] == 2
                            ? (_sortedAdminReviewer[index]
                                ? Icons.star
                                : Icons.star_border)
                            : Icons
                                .star_outline, // Star with a slash for level 1
                        color: _sortedLevels[index] == 2
                            ? (_sortedAdminReviewer[index]
                                ? Colors.yellow
                                : colors.mutedText)
                            : const Color.fromARGB(
                                54, 158, 158, 158), // Grey color for level 1
                        // Labels instead of tooltips: hover tooltips in a list
                        // trip a Flutter Windows accessibility bug
                        // (flutter/flutter#182444).
                        semanticLabel: _sortedLevels[index] == 2
                            ? (_sortedAdminReviewer[index]
                                ? 'Remove admin reviewer'
                                : 'Set as admin reviewer')
                            : 'Level 1 reviewers cannot be admin reviewers',
                      ),
                      onPressed: _sortedLevels[index] == 2
                          ? () => _setAdminReviewer(
                              index, !_sortedAdminReviewer[index])
                          : null,
                    ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: Icon(
                      _sortedWatched[index]
                          ? Icons.visibility
                          : Icons.visibility_off,
                      semanticLabel: _sortedWatched[index]
                          ? 'Stop watching ${_sortedMembers[index].login}'
                          : 'Watch ${_sortedMembers[index].login}',
                    ),
                    onPressed: () =>
                        _setWatching(index, !_sortedWatched[index]),
                    color: colors.mutedText,
                  ),
                ],
              ),
            ),
          );
        });
  }
}
