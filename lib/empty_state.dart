import 'package:flutter/material.dart';
import 'package:pr_watch/app_theme.dart';
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
    final colors = AppColors.of(context);
    return Center(
      child: IntrinsicWidth(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Please enter a github token from',
                style: TextStyle(
                  fontSize: 20,
                  color: colors.text,
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
                    decoration: InputDecoration(
                      labelText: 'GITHUB_TOKEN',
                      labelStyle: TextStyle(color: colors.text),
                      border: const OutlineInputBorder(),
                      constraints: const BoxConstraints(minWidth: 200),
                    ),
                    style: TextStyle(color: colors.text),
                    onSubmitted: setToken,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.save, color: colors.text),
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
