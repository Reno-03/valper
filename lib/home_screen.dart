import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/bottom_nav_bar.dart';
import 'register_steps_screen.dart';

// Import screens from separate files
import 'screens/records_screen.dart';
import 'screens/parking_screen.dart';
import 'screens/support_screen.dart';
import 'screens/about_app_screen.dart';
import 'screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.add(_buildHomeContent());
    _pages.add(const RecordsScreen());
    _pages.add(const ParkingScreen());
    _pages.add(const SupportScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004A8F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.person,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ),
            );
          },
        ),
        title: Text(
          'VALPER',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: _pages[_currentIndex],
    );
  }

  Widget _buildHomeContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/valper_logo.png', height: 240),
          const SizedBox(height: 20),
          Text(
            'Welcome to VALPER!',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () async {
              final bool? isStudent = await showDialog<bool>(
                context: context,
                barrierDismissible: true,
                barrierColor: Colors.black.withValues(alpha: 0.8),
                builder: (context) {
                  String? selectedRole;

                  return StatefulBuilder(
                    builder: (context, setState) {
                      return BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Dialog(
                          backgroundColor: const Color(0xFF004A8F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Select Role',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildRoleOption(
                                  label: 'Student',
                                  selected: selectedRole == 'Student',
                                  onTap: () => setState(() {
                                    selectedRole = 'Student';
                                  }),
                                ),
                                const SizedBox(height: 16),
                                _buildRoleOption(
                                  label: 'Faculty / Staff',
                                  selected: selectedRole == 'Faculty',
                                  onTap: () => setState(() {
                                    selectedRole = 'Faculty';
                                  }),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: selectedRole != null
                                      ? () => Navigator.of(context).pop(selectedRole == 'Student')
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.blue[900],
                                  ),
                                  child: Text(
                                    'Confirm',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );

              if (isStudent != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RegisterStepsScreen(isStudent: isStudent),
                  ),
                );
              }
            },
            icon: Image.asset(
              'assets/register.png',
              height: 24,
              width: 24,
            ),
            label: Text(
              'Register Now',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AboutAppScreen(),
                ),
              );
            },
            icon: Image.asset(
              'assets/information.png',
              height: 24,
              width: 24,
            ),
            label: Text(
              'About App',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/camera_test');
            },
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            label: Text(
              'Test Camera',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final Color borderColor = selected ? Colors.green : Colors.white;
    final Color fillColor = selected ? Colors.green : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fillColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
