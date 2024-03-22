import 'package:flutter/material.dart';
import 'package:pr_watch/models/user.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  const Profile({super.key, required this.user});
  final User user;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.user.avatarUrl),
            radius: 50,
          ),
          const SizedBox(height: 20),
          Text(
            widget.user.name ?? widget.user.login,
            style: Theme.of(context).textTheme.headline5,
          ),
          const SizedBox(height: 20),
          Text(
            widget.user.bio ?? 'No bio available',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => launchUrl(Uri.parse(widget.user.htmlUrl)),
            child: const Text('View Profile'),
          ),
        ],
      ),
    );
  }
}
