import 'package:eventgate_flutter/utils/auth_provider.dart';
import 'package:eventgate_flutter/view/complete_profile_screen.dart';
import 'package:eventgate_flutter/view/landing_screen.dart';
import 'package:eventgate_flutter/view/auth_screen.dart';
import 'package:eventgate_flutter/view/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => AuthProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Gate',
      theme: _buildTheme(Brightness.light),
      home: FutureBuilder(
        future: Provider.of<AuthProvider>(context, listen: false)
            .checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const LandingScreen();
          } else {
            return Consumer<AuthProvider>(
              builder: (context, value, child) {
                return value.isAuthenticated
                    ? const MainScreen()
                    : const LandingScreen();
              },
            );
          }
        },
      ),
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/complete-profile': (context) => const CompleteProfileScreen(),
      },
      // theme: ThemeData(
      //  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      //  useMaterial3: true,
      //),
    );
  }
}

ThemeData _buildTheme(brightness) {
  var baseTheme = ThemeData(brightness: brightness);

  return baseTheme.copyWith(
    textTheme: GoogleFonts.latoTextTheme(baseTheme.textTheme),
  );
}

/* class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).checkLoginStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventGate',
      theme: _buildTheme(Brightness.light),
      home: Consumer<AuthProvider>(
        builder: (context, value, child) {
          return value.isAuthenticated
              ? const MainScreen()
              : const LandingScreen();
        },
      ),
      routes: {
        '/auth': (context) => const AuthScreen(),
      },
    );
  }
} */
