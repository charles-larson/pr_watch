import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pr_watch/app_theme.dart';
import 'package:pr_watch/models/app_state.dart';
import 'package:pr_watch/services/github_service.dart';
import 'package:pr_watch/services/snackbar_service.dart';

class LoadState extends StatefulWidget {
  const LoadState({super.key, required this.onLoaded});
  final void Function(AppState) onLoaded;

  @override
  State<LoadState> createState() => _LoadStateState();
}

class _LoadStateState extends State<LoadState> {
  final storage = const FlutterSecureStorage();

  void _loadAppState() async {
    final token = await storage.read(key: 'GITHUB_TOKEN');
    if (token != null) {
      try {
        GithubService.instance.setToken(token);
        var user = await GithubService.instance.fetchCurrentUser();
        widget.onLoaded(AppState(currentUser: user));
        return;
      } catch (e) {
        await storage.delete(key: 'GITHUB_TOKEN');
        if(!mounted) return;
        SnackbarService.show(context, e.toString());
      }
    }
    widget.onLoaded(AppState());
  }

  @override
  void initState() {
    super.initState();
    _loadAppState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text('Loading...',
              style: TextStyle(color: AppColors.of(context).text)),
        ],
      ),
    );
  }
}
