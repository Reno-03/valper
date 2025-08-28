import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'register_steps_screen.dart';
import 'screens/records_screen.dart';
import 'screens/parking_screen.dart';
import 'screens/support_screen.dart';
import 'camera_test_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://uvpnrcjlrklcppwyekbi.supabase.co',       
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV2cG5yY2pscmtsY3Bwd3lla2JpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAwODI3MTcsImV4cCI6MjA2NTY1ODcxN30.HajiDbkFWnRDg7ZJ-joymvVbQRM-4C78BRn3dqrg9Kw',                           // Replace with your Supabase anon key
  );

  runApp(const ValperApp());
} // hi

class ValperApp extends StatelessWidget {
  const ValperApp({super.key});

  Future<Widget> _getInitialScreen() async {
    // SAVE CURRENT STATE
    // final prefs = await SharedPreferences.getInstance();
    // final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // return isLoggedIn ? const HomeScreen() : const SplashScreen();

    
    // Always start with splash screen for fresh experience
    return const SplashScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VALPER',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const RegisterStepsScreen(isStudent: true),
        '/records': (context) => const RecordsScreen(),
        '/parking': (context) => const ParkingScreen(),
        '/support': (context) => const SupportScreen(),
        '/camera_test': (context) => const CameraTestScreen(),
      },
      home: FutureBuilder(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else {
            return snapshot.data as Widget;
          }
        },
      ),
    );
  }
}
