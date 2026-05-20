
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottom;
  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottom,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.white,

      appBar: appBar,

      body: SafeArea(
        bottom: true,
        top: true,
        child: body,
      ),

      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(
        bottom: true,
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: bottom!,
      ),


    );
  }
}
