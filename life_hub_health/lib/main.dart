import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'shared/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final container = ProviderContainer();
  await container.read(localStorageServiceProvider).init();
  
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const App(),
    ),
  );
}
