import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pr_watch/models/app_state.dart';
import 'package:pr_watch/models/organization.dart';
import 'package:pr_watch/models/settings.dart';
import 'package:pr_watch/models/team.dart';
import 'package:pr_watch/services/github_service.dart';

class ConfigureState extends StatefulWidget {
  const ConfigureState(
      {super.key, required this.appState, required this.onLoaded});
  final AppState appState;
  final void Function(AppState) onLoaded;

  @override
  State<ConfigureState> createState() => _ConfigureStateState();
}

class _ConfigureStateState extends State<ConfigureState> {
  final storage = const FlutterSecureStorage();
  late AppState _appState = AppState();
  List<Organization> _orgs = [];
  List<Team> _teams = [];
  List<Team> _filteredTeams = [];

  bool _loading = false;
  String _loadingText = '';

  void _configureState() async {
    setState(() {
      _loading = true;
      _loadingText = 'Loading organizations';
    });
    var orgId = await storage.read(key: 'ORG_ID');
    var orgs = await GithubService.instance.fetchOrganizations();
    setState(() {
      _orgs = orgs;
      _loading = false;
      _loadingText = '';
    });
    if (orgId != null) {
      try {
        var convertedOrgId = int.tryParse(orgId);
        var org = _orgs.firstWhere((o) => o.id == convertedOrgId);
        setState(() {
          _appState.currentOrganization = org;
          _loading = true;
          _loadingText = 'Loading teams';
        });
      } catch (e) {
        await storage.delete(key: 'ORG_ID');
        return;
      }

      var teamId = await storage.read(key: 'TEAM_ID');
      var teams = await GithubService.instance
          .fetchTeams(_appState.currentOrganization!.login);
      setState(() {
        _teams = teams;
        _loading = false;
        _loadingText = '';
      });
      if (teamId != null) {
        try {
          var convertedTeamId = int.tryParse(teamId);
          var team = _teams.firstWhere((t) => t.id == convertedTeamId);
          setState(() {
            _appState.currentTeam = team;
            _loading = true;
          });
          _loadMembersAndRepos();
        } catch (e) {
          await storage.delete(key: 'TEAM_ID');
          return;
        }
      }
    }
  }

  Future<void> _loadMembersAndRepos() async {
    setState(() {
      _loading = true;
      _loadingText = 'Loading team members and repositories';
    });
    var repos = await GithubService.instance.fetchRepositories(
        _appState.currentOrganization!.login, _appState.currentTeam!.slug);
    _appState.repositories = repos;
    var members = await GithubService.instance.fetchMembers(
        _appState.currentOrganization!.login, _appState.currentTeam!.slug);
    _appState.members = members;
    setState(() {
      _loading = false;
      _loadingText = '';
    });

    var watchedMembers = await storage.read(key: 'WATCHED_MEMBERS');
    if (watchedMembers != null) {
      var watched = watchedMembers.split(',').map((e) => int.tryParse(e));
      for (var i = 0; i < _appState.members.length; i++) {
        _appState.isMemberWatched[_appState.members[i].id] =
            watched.contains(_appState.members[i].id);
      }
    } else {
      for (var i = 0; i < _appState.members.length; i++) {
        _appState.isMemberWatched[_appState.members[i].id] = true;
      }
      await storage.write(
          key: 'WATCHED_MEMBERS',
          value: _appState.members.map((e) => e.id).join(','));
    }

    var memberLevels = await storage.read(key: 'MEMBER_LEVELS');
    if (memberLevels != null) {
      var levels = memberLevels.split(',').map((e) => e.split(':'));
      for (var i = 0; i < _appState.members.length; i++) {
        var level = levels.firstWhere(
            (element) => element[0] == _appState.members[i].id.toString(),
            orElse: () => ['0', '1']);
        _appState.memberLevel[_appState.members[i].id] =
            int.tryParse(level[1]) ?? 1;
      }
    }
    for (var i = 0; i < _appState.members.length; i++) {
      _appState.memberLevel[_appState.members[i].id] ??= 1;
    }
    await storage.write(
        key: 'MEMBER_LEVELS',
        value: _appState.memberLevel.entries
            .map((e) => '${e.key}:${e.value}')
            .join(','));

    var settings = await storage.read(key: 'SETTINGS');
    if (settings != null) {
      var parsedSettings = jsonDecode(settings);
      _appState.settings = Settings.fromJson(parsedSettings);
    }
    widget.onLoaded(_appState);
  }

  void _setOrg(Organization org) async {
    await storage.write(key: 'ORG_ID', value: org.id.toString());
    setState(() {
      _loading = true;
      _loadingText = 'Loading teams';
    });
    var teams = await GithubService.instance.fetchTeams(org.login);
    setState(() {
      _appState.currentOrganization = org;
      _teams = teams;
      _loading = false;
      _loadingText = '';
    });
  }

  void _setTeam(Team team) async {
    await storage.write(key: 'TEAM_ID', value: team.id.toString());
    setState(() {
      _appState.currentTeam = team;
    });
    _loadMembersAndRepos();
  }

  @override
  void initState() {
    super.initState();
    _appState = widget.appState;
    _configureState();
  }

  Widget _buildOrgSelect() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Select an organization',
            style: TextStyle(fontSize: 36, color: Colors.white),
          ),
        ),
        const Divider(
          height: 1,
        ),
        const SizedBox(height: 20),
        if (_orgs.isNotEmpty)
          Expanded(
            child: GridView.builder(
              itemCount: _orgs.length,
              itemBuilder: (ctx, i) {
                return InkWell(
                  onTap: () => _setOrg(_orgs[i]),
                  child: Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(_orgs[i].avatarUrl),
                          radius: 50,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _orgs[i].login,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                );
              },
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5),
            ),
          ),
        if (_orgs.isEmpty)
          const Center(
            child: Text('You are not part of any organizations',
                style: TextStyle(fontSize: 24, color: Colors.white)),
          ),
      ],
    );
  }

  Widget _buildTeamSelect() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Select a team',
            style: TextStyle(fontSize: 36, color: Colors.white),
          ),
        ),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Search',
            labelStyle: TextStyle(color: Colors.white),
            prefixIcon: Icon(Icons.search, color: Colors.white),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              _filteredTeams = _teams
                  .where(
                      (t) => t.name.toLowerCase().contains(value.toLowerCase()))
                  .toList();
            });
          },
        ),
        const Divider(
          height: 1,
        ),
        const SizedBox(height: 20),
        if (_filteredTeams.isNotEmpty)
          Expanded(
            child: GridView.builder(
              itemCount: _filteredTeams.length,
              itemBuilder: (ctx, i) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () => _setTeam(_filteredTeams[i]),
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _filteredTeams[i].name,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            _filteredTeams[i].description ?? 'No description',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5),
            ),
          ),
        if (_filteredTeams.isEmpty)
          const Center(
            child: Text('No teams found',
                style: TextStyle(fontSize: 24, color: Colors.white)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Center(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              Text(
                _loadingText,
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ],
          ))
        : _appState.currentOrganization == null
            ? _buildOrgSelect()
            : _appState.currentTeam == null
                ? _buildTeamSelect()
                : const Center(
                    child: CircularProgressIndicator(),
                  );
  }
}
