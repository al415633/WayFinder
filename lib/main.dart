import 'package:WayFinder/viewModel/adapters/FirestoreAdapterUserApp.dart';
import 'package:flutter/material.dart';
import 'package:WayFinder/view/login.dart'; // Importa el archivo de login
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:WayFinder/APIs/apiConection.dart';
import 'themes/app_theme.dart';

late UserAppController userAppController;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await firebaseConnection();
  await initializeControllers();
  runApp(MiApp());
}

Future<void> initializeControllers() async {
  final repository = FirestoreAdapterUserApp(collectionName: "production");
  userAppController = UserAppController.getInstance(repository);
}

class MiApp extends StatelessWidget {

  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "WayFinder",
      theme: AppTheme.lightTheme,
      home: const LoginPage(), 
      debugShowCheckedModeBanner: false,
    );
  }
}