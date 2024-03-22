import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmptyState extends StatefulWidget {
  const EmptyState({super.key, required this.onTokenSet});
  final void Function(String) onTokenSet;

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> {
  final controller = TextEditingController();

  void setToken(String token) {
    widget.onTokenSet(token);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IntrinsicWidth(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Please enter a github token from',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                )),
            InkWell(
              onTap: () =>
                  launchUrl(Uri.parse('https://github.com/settings/tokens')),
              child: const Text('https://github.com/settings/tokens',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: 20,
                  )),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'GITHUB_TOKEN',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      constraints: BoxConstraints(minWidth: 200),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: setToken,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.save, color: Colors.white),
                  onPressed: () => setToken(controller.text),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
