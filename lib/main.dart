import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/template_editor_screen.dart';
import 'screens/sql_generation_screen.dart';
import 'screens/history_screen.dart';
import 'screens/login_screen.dart';
import 'providers/schema_provider.dart';
import 'providers/sql_provider.dart';
import 'providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SchemaProvider()),
        ChangeNotifierProvider(create: (_) => SqlProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configurar la clave de API en SqlProvider
    final sqlProvider = Provider.of<SqlProvider>(context, listen: false);
    sqlProvider.apiKey = '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';

    return MaterialApp(
      title: 'SQL Sketcher Studio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            shadowColor: MaterialStateProperty.all(Colors.transparent),
            elevation: MaterialStateProperty.all(0),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            textStyle: MaterialStateProperty.all(const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFF2256A3), width: 2),
            )),
          ),
        ),
      ),
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/template-editor': (context) => const TemplateEditorScreen(),
        '/sql-generation': (context) => const SqlGenerationScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}

// El resto del archivo (MyHomePage) puede eliminarse si no se usará, pero se deja para referencia.
