import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FeelBetterApp());
}

class FeelBetterApp extends StatelessWidget {
  const FeelBetterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..initialize(),
      child: const FeelBetterAppView(),
    );
  }
}
