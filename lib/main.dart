import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interassignment1/firebase_options.dart';
import 'package:interassignment1/providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/task_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return MaterialApp(
      home: authState.when(
        data: (user) => user != null ? const TaskListScreen() : const LoginScreen(),
        loading: () => const CircularProgressIndicator(), // Or a splash screen
        error: (error, stack) => Text('Authentication Error: $error'),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
