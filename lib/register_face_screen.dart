import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/permission_handler.dart';

class RegisterFaceScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const RegisterFaceScreen({super.key, required this.cameras});

  @override
  State<RegisterFaceScreen> createState() => _RegisterFaceScreenState();
}

class _RegisterFaceScreenState extends State<RegisterFaceScreen> with SingleTickerProviderStateMixin {
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;
  XFile? _recordedVideo;
  bool _isCameraActive = true;
  bool _isChecked = false;
  bool _isRecording = false;

  late AnimationController _checkAnimController;
  late Animation<Color?> _checkColorAnim;

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
    try {
      debugPrint('=== Starting face camera initialization ===');
      
      // Request camera permission first
      debugPrint('Requesting camera permission...');
      bool hasPermission = await PermissionUtils.requestCameraPermission(context);
      debugPrint('Camera permission granted: $hasPermission');
      
      if (!hasPermission) {
        debugPrint('Camera permission denied!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to use this feature'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
        return;
      }

      // Request storage permission for saving videos
      debugPrint('Requesting storage permission...');
      await PermissionUtils.requestStoragePermission(context);
      debugPrint('Storage permission requested');

      // Request microphone permission for video recording
      debugPrint('Requesting microphone permission...');
      await PermissionUtils.requestMicrophonePermission(context);
      debugPrint('Microphone permission requested');

      if (widget.cameras.isEmpty) {
        debugPrint('No cameras passed to face registration widget!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No cameras available on this device'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
        return;
      }

      debugPrint('Available cameras in face widget: ${widget.cameras.length}');
      for (int i = 0; i < widget.cameras.length; i++) {
        debugPrint('Camera $i: ${widget.cameras[i].name} - ${widget.cameras[i].lensDirection}');
      }

      // Find front camera
      final frontCamera = widget.cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => widget.cameras.first, // Fallback to first camera if no front camera
      );
      
      debugPrint('Creating face camera controller with front camera...');
      _controller = CameraController(frontCamera, ResolutionPreset.medium, enableAudio: true);
      debugPrint('Face camera controller created');
      
      debugPrint('Initializing face camera controller...');
      _initializeControllerFuture = _controller.initialize();
      debugPrint('Face camera controller initialization started');
      
      // Wait for initialization to complete
      debugPrint('Waiting for face camera initialization to complete...');
      await _initializeControllerFuture;
      debugPrint('Face camera controller initialization completed successfully');
      
      if (mounted) {
        debugPrint('Face widget is still mounted, updating state...');
        setState(() {});
        debugPrint('Face state updated successfully');
      } else {
        debugPrint('Face widget is no longer mounted');
      }
      
      debugPrint('=== Face camera initialization completed successfully ===');
    } catch (e) {
      debugPrint('=== Face camera initialization error: $e ===');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to initialize face camera: $e'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _checkAnimController.dispose();
    super.dispose();
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

  Future<void> _startRecording() async {
    try {
      if (_initializeControllerFuture != null) {
        await _initializeControllerFuture!;
      }

      setState(() {
        _isRecording = true;
      });

      // Start recording
      await _controller.startVideoRecording();
      
      // Stop recording after 4 seconds
      await Future.delayed(const Duration(seconds: 4));
      
      final video = await _controller.stopVideoRecording();
      
      setState(() {
        _recordedVideo = video;
        _isCameraActive = false;
        _isChecked = false;
        _isRecording = false;
      });

      _startCheckAnim();
    } catch (e) {
      debugPrint('Error recording video: $e');
      setState(() {
        _isRecording = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to record video: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _recapture() {
    setState(() {
      _recordedVideo = null;
      _isCameraActive = true;
      _isChecked = false;
    });
    _stopCheckAnim();
  }

  void _checkFacePosition() {
    setState(() {
      _isChecked = true;
    });
    _stopCheckAnim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Image.asset(
          'assets/valper_logo.png',
          height: 80,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Register Face',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
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
                    'Align your face within the frame',
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
                                            child: FittedBox(
                                              fit: BoxFit.cover,
                                              child: SizedBox(
                                                width: MediaQuery.of(context).size.width,
                                                child: CameraPreview(_controller),
                                              ),
                                            ),
                                          ),
                                          // Semi-transparent overlay
                                          Container(
                                            color: Colors.black.withOpacity(0.5),
                                          ),
                                          // Center frame for face
                                          Center(
                                            child: Container(
                                              width: 200, // Square frame
                                              height: 200, // Square frame
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                                color: Colors.transparent,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  _isRecording 
                                                      ? 'Rotate your face\nslowly clockwise\nfor 4 seconds'
                                                      : 'Position face here',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Recording indicator
                                          if (_isRecording)
                                            Positioned(
                                              top: 16,
                                              right: 16,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration: const BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'REC',
                                                      style: GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
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
                          : _recordedVideo != null
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.videocam,
                                        color: Colors.white,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Video Recorded Successfully!',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '4-second face recording completed',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : const Center(
                                  child: Text(
                                    'No Video Recorded',
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
                        icon: Icon(_isRecording ? Icons.stop : Icons.videocam, size: 18),
                        label: Text(_isRecording ? 'Recording...' : 'Record', style: const TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRecording ? Colors.red : Colors.white,
                          foregroundColor: _isRecording ? Colors.white : Colors.blue[800],
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(80, 36),
                        ),
                        onPressed: _isCameraActive && !_isRecording ? _startRecording : null,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.replay, size: 18),
                        label: const Text('Rerecord', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue[800],
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(80, 36),
                        ),
                        onPressed: !_isCameraActive ? _recapture : null,
                      ),
                      AnimatedBuilder(
                        animation: _checkAnimController,
                        builder: (context, child) {
                          Color iconColor;
                          if (!_isCameraActive && !_isChecked) {
                            iconColor = _checkColorAnim.value ?? Colors.white;
                          } else if (!_isCameraActive && _isChecked) {
                            iconColor = Colors.lightGreenAccent;
                          } else {
                            iconColor = Colors.grey;
                          }
                          return IconButton(
                            onPressed: !_isCameraActive
                                ? _checkFacePosition
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
                  backgroundColor: _isChecked ? Colors.green[600] : Colors.grey[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _isChecked
                    ? () {
                        Navigator.pop(context, true);
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
    );
  }
}
