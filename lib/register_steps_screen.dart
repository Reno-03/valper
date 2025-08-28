import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'register_details_form.dart';
import 'register_license_plate_screen.dart';
import 'register_face_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'utils/permission_handler.dart';

class RegisterStepsScreen extends StatefulWidget {
  final bool isStudent; // <-- Added this

  const RegisterStepsScreen({super.key, required this.isStudent}); // <-- Added required

  @override
  State<RegisterStepsScreen> createState() => _RegisterStepsScreenState();
}

class _RegisterStepsScreenState extends State<RegisterStepsScreen> {
  bool isDetailsComplete = false;
  bool isLicensePlateRegistered = false;
  bool isFaceRegistered = false;

  int _selectedIndex = 0;
  List<CameraDescription> _cameras = [];

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  Future<void> _initCameras() async {
    try {
      debugPrint('=== Starting camera initialization ===');
      
      // Request camera permission first (only camera, not all permissions)
      debugPrint('Requesting camera permission...');
      bool hasCameraPermission = await PermissionUtils.requestCameraOnly(context);
      debugPrint('Camera permission granted: $hasCameraPermission');
      
      if (!hasCameraPermission) {
        debugPrint('Camera permission denied, showing snackbar');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required for registration'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get available cameras
      debugPrint('Getting available cameras...');
      _cameras = await availableCameras();
      debugPrint('Available cameras count: ${_cameras.length}');
      
      if (_cameras.isNotEmpty) {
        for (int i = 0; i < _cameras.length; i++) {
          debugPrint('Camera $i: ${_cameras[i].name} - ${_cameras[i].lensDirection}');
        }
      }
      
      if (_cameras.isEmpty) {
        debugPrint('No cameras found, showing snackbar');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No cameras found on this device. Please check if your device has a camera.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {});
      debugPrint('Camera initialization completed successfully');
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found ${_cameras.length} camera(s)'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Camera initialization failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _checkRegistrationComplete() {
    if (isDetailsComplete && isLicensePlateRegistered && isFaceRegistered) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registration Complete'),
          content: const Text('You are registered!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _openLicensePlateScreen() async {
    if (_cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No cameras available')),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterLicensePlateScreen(cameras: _cameras),
      ),
    );

    if (result == true) {
      setState(() {
        isLicensePlateRegistered = true;
      });
      _checkRegistrationComplete();
    }
  }

  Future<void> _openFaceRegistration() async {
    if (_cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No cameras available')),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterFaceScreen(cameras: _cameras),
      ),
    );

    if (result == true) {
      setState(() {
        isFaceRegistered = true;
      });
      _checkRegistrationComplete();
    }
  }

  Future<void> _openDetailsForm() async {
    // Remove dialog here because isStudent is already passed in constructor

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterDetailsForm(isStudent: widget.isStudent),
      ),
    );
    if (result == true) {
      setState(() {
        isDetailsComplete = true;
      });
      _checkRegistrationComplete();
    }
  }

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/records');
        break;
      case 2:
        Navigator.pushNamed(context, '/parking');
        break;
      case 3:
        Navigator.pushNamed(context, '/support');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTap,
      ),
      appBar: AppBar(
        title: Text(
          'Vehicle Registration',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              debugPrint('Manual camera refresh requested');
              _initCameras();
            },
            tooltip: 'Refresh Cameras',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Image.asset('assets/valper_logo.png', height: 160),
            const SizedBox(height: 20),
            Text(
              'Complete the details below to Register Vehicle Access!',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_cameras.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Column(
                  children: [
                    Text(
                      '⚠️ Camera not initialized',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the refresh button in the app bar to initialize cameras',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            buildStepButton(
              title: 'Complete Details',
              icon: isDetailsComplete ? Icons.check_circle : Icons.info,
              color: isDetailsComplete ? Colors.green : Colors.blue[800]!,
              onTap: _openDetailsForm,
            ),
            const SizedBox(height: 12),
            buildStepButton(
              title: 'Register License Plate',
              icon: isLicensePlateRegistered ? Icons.check_circle : Icons.warning,
              color: isLicensePlateRegistered ? Colors.green : Colors.red,
              onTap: isDetailsComplete
                  ? _openLicensePlateScreen
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please complete your details first.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
            ),
            const SizedBox(height: 12),
            buildStepButton(
              title: 'Register Face',
              icon: isFaceRegistered ? Icons.check_circle : Icons.warning,
              color: isFaceRegistered ? Colors.green : Colors.red,
              onTap: isLicensePlateRegistered
                  ? _openFaceRegistration
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please register your license plate first.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStepButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }
}
