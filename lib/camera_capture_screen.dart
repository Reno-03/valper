import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';

class RegisterLicensePlateScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const RegisterLicensePlateScreen({super.key, required this.cameras});

  @override
  State<RegisterLicensePlateScreen> createState() =>
      _RegisterLicensePlateScreenState();
}

class _RegisterLicensePlateScreenState
    extends State<RegisterLicensePlateScreen> {
  XFile? _capturedImage;
  final TextEditingController _plateController = TextEditingController();
  bool _submitted = false;

  Future<void> _openCamera() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraCaptureScreen(
          camera: widget.cameras.first,
          onPictureTaken: (XFile image) {
            setState(() {
              _capturedImage = image;
            });
          },
        ),
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Image.asset('assets/valper_icon.png', height: 100),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Register License Plate',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _plateController,
              decoration: InputDecoration(
                hintText: 'Enter your License Plate Number',
                filled: true,
                fillColor: Colors.blue[800],
                hintStyle: GoogleFonts.poppins(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: GoogleFonts.poppins(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[800],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Capture clearly your License Plate Number',
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: Colors.black,
                      height: 180,
                      child: _capturedImage != null
                          ? Image.file(File(_capturedImage!.path),
                              fit: BoxFit.cover)
                          : const Center(
                              child: Text(
                                'No Image Captured',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt,
                              color: Colors.blue),
                          onPressed: _openCamera,
                        ),
                      ),
                      const SizedBox(width: 20),
                      CircleAvatar(
                        backgroundColor: _submitted
                            ? Colors.green
                            : Colors.white.withAlpha(77),
                        child: Icon(
                          _submitted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                setState(() {
                  _submitted = true;
                });
                Navigator.pop(context, true);
              },
              child: Text(
                'Submit',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books), label: 'Records'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_parking), label: 'Parking Slot'),
          BottomNavigationBarItem(icon: Icon(Icons.support), label: 'Support'),
        ],
      ),
    );
  }
}

// ✅ CameraCaptureScreen from your code with small modification
class CameraCaptureScreen extends StatefulWidget {
  final CameraDescription camera;
  final Function(XFile) onPictureTaken;

  const CameraCaptureScreen({
    super.key,
    required this.camera,
    required this.onPictureTaken,
  });

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    await _initializeControllerFuture;
    final image = await _controller.takePicture();
    widget.onPictureTaken(image);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: const Icon(Icons.camera),
      ),
    );
  }
}
