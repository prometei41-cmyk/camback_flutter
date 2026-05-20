import 'package:flutter/material.dart';
import '../services/push_service.dart';

class PushInitializer extends StatefulWidget {
  final Widget child;

  const PushInitializer({super.key, required this.child});

  @override
  State<PushInitializer> createState() => _PushInitializerState();
}

class _PushInitializerState extends State<PushInitializer> {
  @override
  void initState() {
    super.initState();

    // ИНИЦИАЛИЗАЦИЯ ПОСЛЕ ПОСТРОЕНИЯ WIDGET TREE
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PushService.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
