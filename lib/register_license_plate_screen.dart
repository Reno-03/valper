import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterLicensePlateScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const RegisterLicensePlateScreen({super.key, required this.cameras});

  @override
  State<RegisterLicensePlateScreen> createState() =>
      _RegisterLicensePlateScreenState();
}

class _RegisterLicensePlateScreenState
    extends State<RegisterLicensePlateScreen> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  XFile? _capturedImage;
  Uint8List? _webImageBytes;
  bool _isCameraActive = true;
  bool isChecked = false;
  final TextEditingController _plateController = TextEditingController();
  bool _isInitialized = false;
  FlashMode _flashMode = FlashMode.off;
  int _flashModeIndex = 0;
  final List<FlashMode> _flashModes = [FlashMode.off, FlashMode.torch, FlashMode.always];

  late AnimationController _checkAnimController;
  late Animation<Color?> _checkColorAnim;

  final FocusNode _plateFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _checkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _checkColorAnim = ColorTween(
      begin: Colors.white,
      end: Colors.green,
    ).animate(CurvedAnimation(
      parent: _checkAnimController,
      curve: Curves.easeInOut,
    ));
    _checkAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkAnimController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _checkAnimController.forward();
      }
    });
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;
      await _controller!.setFlashMode(FlashMode.off);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _plateController.dispose();
    _checkAnimController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      if (_initializeControllerFuture != null) {
        await _initializeControllerFuture!;
      }

      // Add longer delay for auto flash to prevent overexposure
      if (_flashMode == FlashMode.always) {
        await Future.delayed(const Duration(milliseconds: 2000));
      } else if (_flashMode == FlashMode.torch) {
        await Future.delayed(const Duration(milliseconds: 800));
      }

      final image = await _controller!.takePicture();

      // Store original flash mode before changing it
      final originalFlashMode = _flashMode;

      // Optimized flash turn-off after capture
      try {
        // For auto flash mode, use optimized approach
        if (_flashMode == FlashMode.always) {
          // Efficient multiple attempts for auto flash
          await _controller!.setFlashMode(FlashMode.off);
          await Future.delayed(const Duration(milliseconds: 250));
          await _controller!.setFlashMode(FlashMode.off);
          await Future.delayed(const Duration(milliseconds: 250));
          await _controller!.setFlashMode(FlashMode.off);
          await Future.delayed(const Duration(milliseconds: 400));
          await _controller!.setFlashMode(FlashMode.off);
        } else {
          // Standard approach for other flash modes (off and torch)
          await _controller!.setFlashMode(FlashMode.off);
          await Future.delayed(const Duration(milliseconds: 150));
          await _controller!.setFlashMode(FlashMode.off);
        }
      } catch (e) {
        debugPrint('Error turning off flash: $e');
      }
      
      setState(() {
        _flashMode = FlashMode.off;
        _flashModeIndex = 0;
        _capturedImage = image;
        _isCameraActive = false;
      });
      _startCheckAnim();

      // Optimized image processing with better error handling
      await _processCapturedImage(image, originalFlashMode);
      
    } catch (e) {
      debugPrint('Error taking picture: $e');
      // Show user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to capture image. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _processCapturedImage(XFile image, FlashMode originalFlashMode) async {
    try {
      // Wait for image file to be fully written
      await Future.delayed(const Duration(milliseconds: 400));

      // Get the image dimensions
      final originalFile = File(image.path);
      
      // Enhanced file validation
      if (!await originalFile.exists()) {
        debugPrint('Image file does not exist');
        return;
      }
      
      final fileSize = await originalFile.length();
      if (fileSize < 1024) { // Less than 1KB is likely corrupted
        debugPrint('Image file too small, likely corrupted');
        return;
      }
      
      final originalBytes = await originalFile.readAsBytes();
      
      // Check if image file is valid
      if (originalBytes.isEmpty) {
        debugPrint('Image file is empty');
        return;
      }
      
      final originalImage = img.decodeImage(originalBytes);
      
      if (originalImage == null) {
        debugPrint('Failed to decode image');
        return;
      }

      // Optimized cropping calculations
      final cropResult = await _calculateAndCropImage(originalImage, originalFile);
      
      if (cropResult) {
        debugPrint('Image processed successfully');
        
        // Force flash off for auto flash mode by resetting camera controller
        // Only for auto flash mode - other modes (off and torch) are safe without reset
        if (originalFlashMode == FlashMode.always) {
          await _forceFlashOffWithCameraReset(originalFlashMode);
        }
      }
      
    } catch (e) {
      debugPrint('Error processing captured image: $e');
    }
  }

  Future<bool> _calculateAndCropImage(img.Image originalImage, File originalFile) async {
    try {
      // Calculate frame dimensions relative to the image
      final frameWidth = MediaQuery.of(context).size.width * 0.75;
      const frameHeight = 100.0;
      
      // Calculate scaling factors with better precision
      final previewWidth = MediaQuery.of(context).size.width;
      final previewHeight = previewWidth * 4/3;
      
      final scaleX = originalImage.width / previewWidth;
      final scaleY = originalImage.height / previewHeight;
      
      // Calculate frame position in image coordinates with bounds checking
      final frameX = ((originalImage.width - (frameWidth * scaleX)) / 2).round();
      final frameY = ((originalImage.height - (frameHeight * scaleY)) / 2).round();
      final cropWidth = (frameWidth * scaleX).round();
      final cropHeight = (frameHeight * scaleY).round();

      // Validate crop bounds
      if (frameX < 0 || frameY < 0 || 
          frameX + cropWidth > originalImage.width || 
          frameY + cropHeight > originalImage.height) {
        debugPrint('Crop bounds out of range');
        return false;
      }

      // Crop the image
      final croppedImage = img.copyCrop(
        originalImage,
        x: frameX,
        y: frameY,
        width: cropWidth,
        height: cropHeight,
      );

      // Save the cropped image with better quality
      final croppedBytes = img.encodeJpg(croppedImage, quality: 95);
      await originalFile.writeAsBytes(croppedBytes);

      return true;
    } catch (e) {
      debugPrint('Error calculating and cropping image: $e');
      return false;
    }
  }

  Future<void> _forceFlashOffWithCameraReset(FlashMode originalFlashMode) async {
    try {
      // Wait a bit before resetting to ensure image processing is complete
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Store current camera state
      final currentCamera = _controller;
      
      // Dispose current camera controller
      await _controller!.dispose();
      
      // Get available cameras and create new controller
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(
          cameras[0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        _initializeControllerFuture = _controller!.initialize();
        await _initializeControllerFuture;
        
        // Ensure flash is off in new controller
        await _controller!.setFlashMode(FlashMode.off);
        
        // Update UI to reflect new controller
        if (mounted) {
          setState(() {
            // Trigger rebuild to show new camera preview
          });
        }
        
        debugPrint('Camera controller reset completed - flash should be off, preview maintained');
      }
    } catch (e) {
      debugPrint('Error resetting camera controller: $e');
    }
  }

  void _recapture() {
    setState(() {
      _capturedImage = null;
      _webImageBytes = null;
      _isCameraActive = true;
      isChecked = false;
    });
    _stopCheckAnim();
  }

  void _startCheckAnim() {
    if (!_checkAnimController.isAnimating) {
      _checkAnimController.forward();
    }
  }

  void _stopCheckAnim() {
    _checkAnimController.stop();
    _checkAnimController.reset();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera); // or .gallery
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter plate and select an image.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 1. Upload image
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.path.split('/').last}';
      final String storagePath = await supabase.storage.from('license-plates').upload(fileName, _imageFile!);
      if (storagePath.isEmpty) {
        throw Exception('Image upload failed');
      }

      final String imageUrl = supabase.storage.from('license-plates').getPublicUrl(fileName);

      // 2. Insert into table
      final insertResponse = await supabase.from('license_plates').insert({
        'user_id': user.id,
        'plate_number': _plateController.text.trim(),
        'image_url': imageUrl,
      });

      if (insertResponse.error != null) {
        throw Exception('Database insert failed: ${insertResponse.error!.message}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('License plate registered!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Image.asset('assets/valper_logo.png', height: 160),
            ),
            const SizedBox(height: 24),
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
              focusNode: _plateFocusNode,
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
                    'Position your license plate within the frame',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: Colors.blue[800],
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width * 4/3, // Typical camera aspect ratio
                      child: _isCameraActive
                          ? (_initializeControllerFuture != null
                              ? FutureBuilder<void>(
                                  future: _initializeControllerFuture!,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done) {
                                      if (snapshot.hasError) {
                                        debugPrint('Camera preview error: ${snapshot.error}');
                                        return const Center(
                                          child: Text(
                                            'Camera Error',
                                            style: TextStyle(color: Colors.white70),
                                          ),
                                        );
                                      }
                                      return Stack(
                                        children: [
                                          // Full camera preview that fills width
                                          Positioned.fill(
                                            child: GestureDetector(
                                              onTapUp: (TapUpDetails details) async {
                                                if (_controller != null && _controller!.value.isInitialized) {
                                                  try {
                                                    final Offset tapPosition = details.localPosition;
                                                    final Size previewSize = MediaQuery.of(context).size;
                                                    
                                                    // Convert tap position to camera coordinates
                                                    final double x = tapPosition.dx / previewSize.width;
                                                    final double y = tapPosition.dy / previewSize.height;
                                                    
                                                    await _controller!.setFocusPoint(Offset(x, y));
                                                    await _controller!.setExposurePoint(Offset(x, y));
                                                  } catch (e) {
                                                    debugPrint('Error setting focus: $e');
                                                  }
                                                }
                                              },
                                              child: FittedBox(
                                                fit: BoxFit.cover,
                                                child: SizedBox(
                                                  width: MediaQuery.of(context).size.width,
                                                  child: CameraPreview(_controller!),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Semi-transparent overlay
                                          Container(
                                            color: Colors.black.withOpacity(0.5),
                                          ),
                                          // Center frame for license plate
                                          Center(
                                            child: Container(
                                              width: MediaQuery.of(context).size.width * 0.75,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                                color: Colors.transparent,
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  'Position license plate here',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(color: Colors.white),
                                      );
                                    }
                                  },
                                )
                              : const Center(
                                  child: Text(
                                    'Initializing Camera...',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ))
                          : _capturedImage != null
                              ? Stack(
                                  children: [
                                    // Full camera preview
                                    Positioned.fill(
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                          width: MediaQuery.of(context).size.width,
                                          child: CameraPreview(_controller!),
                                        ),
                                      ),
                                    ),
                                    // Darkened overlay
                                    Container(
                                      color: Colors.black.withOpacity(0.7),
                                    ),
                                    // Highlighted area (license plate frame)
                                    Center(
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * 0.75,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                          color: Colors.transparent,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: kIsWeb
                                              ? Image.memory(
                                                  _webImageBytes!,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.file(
                                                  File(_capturedImage!.path),
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: const Text('Capture', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue[800],
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(80, 36),
                        ),
                        onPressed: _isCameraActive ? _takePicture : null,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.replay, size: 18),
                        label: const Text('Recapture', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue[800],
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(80, 36),
                        ),
                        onPressed: !_isCameraActive ? _recapture : null,
                      ),
                      IconButton(
                        onPressed: _isCameraActive ? () {
                          setState(() {
                            _flashModeIndex = (_flashModeIndex + 1) % _flashModes.length;
                            _flashMode = _flashModes[_flashModeIndex];
                          });
                          _controller?.setFlashMode(_flashMode);
                        } : null,
                        icon: Icon(
                          _flashMode == FlashMode.off
                              ? Icons.flash_off
                              : _flashMode == FlashMode.torch
                                  ? Icons.flash_on
                                  : Icons.flash_auto,
                          color: _isCameraActive ? Colors.white : Colors.grey,
                          size: 30,
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _checkAnimController,
                        builder: (context, child) {
                          Color iconColor;
                          if (!_isCameraActive && !isChecked) {
                            iconColor = _checkColorAnim.value ?? Colors.white;
                          } else if (!_isCameraActive && isChecked) {
                            iconColor = Colors.lightGreenAccent;
                          } else {
                            iconColor = Colors.grey;
                          }
                          return IconButton(
                            onPressed: !_isCameraActive
                                ? () {
                                    setState(() {
                                      isChecked = true;
                                    });
                                    _stopCheckAnim();
                                  }
                                : null,
                            icon: Icon(
                              Icons.check_circle,
                              color: iconColor,
                              size: 30,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isChecked 
                      ? Colors.green[600] 
                      : Colors.grey[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: isChecked
                    ? () async {
                        if (_plateController.text.trim().isEmpty) {
                          FocusScope.of(context).requestFocus(_plateFocusNode);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter your license plate number.'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        final supabase = Supabase.instance.client;
                        final user = supabase.auth.currentUser;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('User not logged in')),
                          );
                          return;
                        }

                        try {
                          // Insert into license_plates table with only text (no image)
                          await supabase.from('license_plates').insert({
                            'user_id': user.id,
                            'plate_number': _plateController.text.trim(),
                            'image_url': null, // No image URL
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('License plate registered!')),
                          );
                          Navigator.pop(context, true);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    : null,
                child: Text(
                  'Submit',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 40), // Extra padding at bottom
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
