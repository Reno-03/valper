import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'utils/permission_handler.dart';

class CameraTestScreen extends StatefulWidget {
  const CameraTestScreen({super.key});

  @override
  State<CameraTestScreen> createState() => _CameraTestScreenState();
}

class _CameraTestScreenState extends State<CameraTestScreen> {
  List<CameraDescription> cameras = [];
  bool isLoading = true;
  String statusMessage = 'Initializing...';
  CameraController? _controller;
  bool _isCameraActive = false;

  @override
  void initState() {
    super.initState();
    _testCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _testCamera() async {
    try {
      setState(() {
        statusMessage = 'Requesting permissions...';
      });

      // Test permissions
      bool hasCameraPermission = await PermissionUtils.requestCameraPermission(context);
      bool hasStoragePermission = await PermissionUtils.requestStoragePermission(context);

      setState(() {
        statusMessage = 'Camera permission: $hasCameraPermission\nStorage permission: $hasStoragePermission';
      });

      if (!hasCameraPermission) {
        setState(() {
          statusMessage = 'Camera permission denied!';
          isLoading = false;
        });
        return;
      }

      setState(() {
        statusMessage = 'Getting available cameras...';
      });

      // Get cameras
      cameras = await availableCameras();

      setState(() {
        statusMessage = 'Found ${cameras.length} camera(s)';
        isLoading = false;
      });

      if (cameras.isNotEmpty) {
        for (int i = 0; i < cameras.length; i++) {
          debugPrint('Camera $i: ${cameras[i].name} - ${cameras[i].lensDirection}');
        }
      }

    } catch (e) {
      setState(() {
        statusMessage = 'Error: $e';
        isLoading = false;
      });
      debugPrint('Camera test error: $e');
    }
  }

  Future<void> _testCameraPreview() async {
    if (cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No cameras available')),
      );
      return;
    }

    try {
      setState(() {
        statusMessage = 'Testing camera preview...';
        _isCameraActive = true;
      });

      _controller = CameraController(cameras.first, ResolutionPreset.medium);
      await _controller!.initialize();
      
      setState(() {
        statusMessage = 'Camera preview working!';
      });

    } catch (e) {
      setState(() {
        statusMessage = 'Camera preview failed: $e';
        _isCameraActive = false;
      });
      debugPrint('Camera preview error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Test'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Camera Status:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      statusMessage,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (cameras.isNotEmpty) ...[
              const Text(
                'Available Cameras:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...cameras.asMap().entries.map((entry) {
                int index = entry.key;
                CameraDescription camera = entry.value;
                return Card(
                  child: ListTile(
                    title: Text('Camera $index'),
                    subtitle: Text('${camera.name} - ${camera.lensDirection}'),
                    trailing: const Icon(Icons.camera_alt),
                  ),
                );
              }),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testCamera,
                    child: const Text('Retest Camera'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testCameraPreview,
                    child: const Text('Test Preview'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isCameraActive && _controller != null) ...[
              const Text(
                'Camera Preview:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CameraPreview(_controller!),
                ),
              ),
            ],
            const SizedBox(height: 20), // Extra padding at bottom
          ],
        ),
      ),
    );
  }
} 