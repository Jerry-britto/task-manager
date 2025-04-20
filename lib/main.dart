import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:interassignment1/firebase_options.dart';
import 'package:interassignment1/screens/login_screen.dart';
import 'package:interassignment1/screens/task_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TaskListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
