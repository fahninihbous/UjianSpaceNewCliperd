import 'package:flutter/material.dart';
import 'routes/app_routing.dart';
import 'theme/space_theme.dart';

void main() {
  runApp(const SpaceNewsApp());
}

class SpaceNewsApp extends StatelessWidget {
  const SpaceNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpaceNews Clipper',
      debugShowCheckedModeBanner: false,
      theme: SpaceTheme.darkTheme,
      darkTheme: SpaceTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: AppRouting.splash,
      onGenerateRoute: AppRouting.generateRoute,
    );
  }
}