import 'package:flutter/material.dart';
import 'presentation/screens/components_preview_screen.dart';

void main() {
  runApp(const MedSyncApp());
}

class MedSyncApp extends StatelessWidget {
  const MedSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedSync',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const ComponentsPreviewScreen(),
      },
    );
  }
}
