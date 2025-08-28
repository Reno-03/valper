// lib/screens/about_app_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About VALPER App',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF004A8F),
        iconTheme: const IconThemeData(color: Colors.white), // Set back button color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/valper_logo.png', // Make sure you have this logo in your assets
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'VALPER',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF004A8F),
                ),
              ),
            ),
            Center(
              child: Text(
                'Version 1.0.0', // You can dynamically get this from pubspec.yaml
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'What is VALPER?',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF004A8F),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'VALPER ( A VEHICLE AI-BASED LICENSE PLATE AND DRIVER RECOGNITION SYSTEM FOR PARKING ACCESS MANAGEMENT AT SAMAR STATE UNIVERSITY) is a comprehensive mobile application designed to streamline vehicle management and parking services within a university campus environment. It aims to provide a seamless experience for both students and faculty in registering their vehicles, locating available parking slots, and managing their parking records.',
              style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            Text(
              'Key Features:',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF004A8F),
              ),
            ),
            const SizedBox(height: 10),
            _buildFeatureBullet('Easy Vehicle Registration for Students and Faculty.'),
            _buildFeatureBullet('Real-time Parking Slot Availability on an interactive map.'),
            _buildFeatureBullet('Digital Parking Records for easy tracking.'),
            _buildFeatureBullet('Dedicated Support System for user assistance.'),
            _buildFeatureBullet('Secure and User-Friendly Interface.'),
            const SizedBox(height: 20),
            Text(
              'Our Mission:',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF004A8F),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'To enhance campus mobility and security by providing an efficient and accessible platform for vehicle management and parking, fostering a more organized and convenient environment for the university community.',
              style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Developed by Valper', 
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ),
            Center(
              child: Text(
                '© 2025 All rights reserved.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 20, color: Colors.green[700]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}