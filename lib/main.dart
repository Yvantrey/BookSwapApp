import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options/firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BookSwapApp());
}

class BookSwapApp extends StatelessWidget {
  const BookSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
      ],
      child: MaterialApp(
        title: 'BookSwap',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0D1232),
          primaryColor: const Color(0xFFF9C73D),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFF9C73D),
            secondary: Color(0xFFFFC94A),
            surface: Color(0xFF0F163A),
            onPrimary: Color(0xFF0D1232),
            onSecondary: Color(0xFF0D1232),
            onSurface: Color(0xFFFFFFFF),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F163A),
            foregroundColor: Color(0xFFFFFFFF),
            elevation: 0,
          ),
          cardTheme: const CardThemeData(
            color: Color(0xFF0F163A),
            elevation: 4,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF9C73D),
              foregroundColor: const Color(0xFF0D1232),
              elevation: 2,
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFF9C73D),
            foregroundColor: Color(0xFF0D1232),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF0F163A),
            selectedItemColor: Color(0xFFF9C73D),
            unselectedItemColor: Color(0xFFFFFFFF),
            type: BottomNavigationBarType.fixed,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Color(0xFF0F163A),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFF9C73D)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFF9C73D)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFF9C73D), width: 2),
            ),
            labelStyle: TextStyle(color: Color(0xFFFFFFFF)),
            hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
            bodyMedium: TextStyle(color: Color(0xFFFFFFFF)),
            titleLarge: TextStyle(color: Color(0xFFFFFFFF)),
            titleMedium: TextStyle(color: Color(0xFFFFFFFF)),
            headlineSmall: TextStyle(color: Color(0xFFFFFFFF)),
          ),
          iconTheme: const IconThemeData(
            color: Color(0xFFFFFFFF),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: FutureBuilder(
          future: Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('Error: ${snapshot.error}'),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  if (auth.isAuthenticated) {
                    return const HomeScreen();
                  }
                  return const AuthScreen();
                },
              );
            }
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }
}
