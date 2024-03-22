import 'package:flutter/material.dart';
import 'package:pr_watch/models/app_state.dart';
import 'package:pr_watch/models/pull_request.dart';
import 'package:pr_watch/models/repository.dart';
import 'package:pr_watch/services/github_service.dart';
import 'package:url_launcher/url_launcher.dart';

class Repos extends StatefulWidget {
  const Repos({super.key, required this.appState});
  final AppState appState;

  @override
  State<Repos> createState() => _ReposState();
}

class _ReposState extends State<Repos> {
  List<Repository> _filteredRepos = [];

  void _search(String text) {
    if (text.isEmpty) {
      _filteredRepos = widget.appState.repositories;
    } else {
      _filteredRepos = widget.appState.repositories
          .where((repo) => repo.name.toLowerCase().contains(text.toLowerCase()))
          .toList();
    }
    setState(() {});
  }

  @override
  void initState() {
    _filteredRepos = widget.appState.repositories;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                labelStyle: TextStyle(color: Colors.white),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(),
              ),
              onChanged: _search,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: _filteredRepos.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  _filteredRepos[index].name,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                subtitle: Text(_filteredRepos[index].description ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white60)),
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage(_filteredRepos[index].owner.avatarUrl!),
                ),
                trailing: TextButton(
                  onPressed: () =>
                      launchUrl(Uri.parse(_filteredRepos[index].htmlUrl)),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'View',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
