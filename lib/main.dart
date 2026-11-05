import 'package:flutter/material.dart';
import 'package:pr_watch/app_theme.dart';
import 'package:pr_watch/my_home_page.dart';
import 'package:pr_watch/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.instance.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance,
      builder: (context, themeMode, _) => MaterialApp(
        title: 'Flutter Demo',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeMode,
        home: const MyHomePage(title: 'PR Watch'),
      ),
    );
  }
}
