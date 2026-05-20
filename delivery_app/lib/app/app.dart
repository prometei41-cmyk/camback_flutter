import 'package:flutter/material.dart';
import 'package:delivery_app/app/router.dart';
import 'package:delivery_app/core/theme/app_theme.dart';
import 'push_initializer.dart';

class App extends StatelessWidget {
  final String startRoute;

  const App({super.key, required this.startRoute});

  @override
  Widget build(BuildContext context) {
    return PushInitializer(
      child: MaterialApp(
        title: 'Delivery App',
        theme: AppTheme.light,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: startRoute,
      ),
    );
  }
}
