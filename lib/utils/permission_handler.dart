import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionUtils {
  static Future<bool> requestCameraPermission(BuildContext context) async {
    PermissionStatus status = await Permission.camera.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      status = await Permission.camera.request();
      if (status.isGranted) {
        return true;
      }
    }
    
    if (status.isPermanentlyDenied) {
      _showPermissionDialog(
        context,
        'Camera Permission Required',
        'Camera permission is required to capture license plates and face registration. Please enable it in Settings.',
        Permission.camera,
      );
    }
    
    return false;
  }
  
  static Future<bool> requestStoragePermission(BuildContext context) async {
    PermissionStatus status = await Permission.storage.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }
    }
    
    if (status.isPermanentlyDenied) {
      _showPermissionDialog(
        context,
        'Storage Permission Required',
        'Storage permission is required to save captured images. Please enable it in Settings.',
        Permission.storage,
      );
    }
    
    return false;
  }
  
  static Future<bool> requestMicrophonePermission(BuildContext context) async {
    PermissionStatus status = await Permission.microphone.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      status = await Permission.microphone.request();
      if (status.isGranted) {
        return true;
      }
    }
    
    if (status.isPermanentlyDenied) {
      _showPermissionDialog(
        context,
        'Microphone Permission Required',
        'Microphone permission is required for video recording during face registration. Please enable it in Settings.',
        Permission.microphone,
      );
    }
    
    return false;
  }
  
  static void _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
    Permission permission,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }
  
  static Future<bool> requestAllPermissions(BuildContext context) async {
    bool cameraGranted = await requestCameraPermission(context);
    bool storageGranted = await requestStoragePermission(context);
    bool microphoneGranted = await requestMicrophonePermission(context);
    
    // Only require camera permission for basic functionality
    // Storage and microphone are optional but recommended
    if (!cameraGranted) {
      debugPrint('Camera permission is required but not granted');
      return false;
    }
    
    if (!storageGranted) {
      debugPrint('Storage permission not granted - images may not be saved');
    }
    
    if (!microphoneGranted) {
      debugPrint('Microphone permission not granted - video recording may not work');
    }
    
    return true; // Return true if camera permission is granted
  }
  
  static Future<bool> requestCameraOnly(BuildContext context) async {
    return await requestCameraPermission(context);
  }
} 