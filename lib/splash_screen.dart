import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SSU logo on top (smaller), Valper logo below (bigger)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/ssu_logo.png', // SSU logo
                    height: 60, // 2x2 size approx
                    width: 60,
                  ),
                  const SizedBox(height: 12), // spacing between logos
                  Image.asset(
                    'assets/valper_logo.png', // Valper logo
                    height: 240, // 4x4 size approx
                    width: 240,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Welcome text with Poppins font and italic style
              const Text(
                'Welcome to VALPER!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // Subtitle text with Poppins font but normal style
              const Text(
                'Making Samar State \nUniversity more smart to \nparking management',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.black54,
                  fontStyle: FontStyle.normal,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  textStyle: const TextStyle(fontSize: 20),  // Button text size 11.5
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6), // Rounded corners radius 6
                  ),
                  elevation: 5,
                ),
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
