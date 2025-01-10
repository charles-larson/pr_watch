import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pr_watch/models/app_state.dart';
import 'package:pr_watch/models/member.dart';

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

  Future<void> _setWatching(int index, bool watching) async {
    widget.appState.isMemberWatched[_sortedMembers[index].id] = watching;
    _sortMembers();
    setState(() {});
    await _storage.write(
        key: 'WATCHED_MEMBERS',
        value: widget.appState.isMemberWatched.entries
            .where((element) => element.value)
            .map((x) => x.key)
            .join(','));
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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.appState.members.length,
        itemBuilder: (context, index) {
          return Container(
            color: index.isEven ? Colors.black26 : Colors.black12,
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              title: Text(
                _sortedMembers[index].login,
                style: const TextStyle(fontSize: 20, color: Colors.white),
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
                                : Colors.white54)
                            : const Color.fromARGB(
                                54, 158, 158, 158), // Grey color for level 1
                      ),
                      onPressed: _sortedLevels[index] == 2
                          ? () => _setAdminReviewer(
                              index, !_sortedAdminReviewer[index])
                          : null,
                      tooltip: _sortedLevels[index] == 2
                          ? (_sortedAdminReviewer[index]
                              ? 'Remove admin reviewer'
                              : 'Set as admin reviewer')
                          : 'Level 1 reviewers cannot be admin reviewers',
                    ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: Icon(_sortedWatched[index]
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        _setWatching(index, !_sortedWatched[index]),
                    color: Colors.white54,
                    tooltip: _sortedWatched[index]
                        ? 'Stop watching ${_sortedMembers[index].login}'
                        : 'Watch ${_sortedMembers[index].login}',
                  ),
                ],
              ),
            ),
          );
        });
  }
}
