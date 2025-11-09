import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class PermissionService {
  static Future<bool> requestCameraPermission() async {
    if (kIsWeb) return true; // Web doesn't need explicit camera permission
    
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  static Future<bool> requestStoragePermission() async {
    if (kIsWeb) return true; // Web doesn't need explicit storage permission
    
    // Check if already granted
    if (await Permission.photos.isGranted || await Permission.storage.isGranted) {
      return true;
    }
    
    // For Android 13+ (API 33+), request photos permission
    if (Platform.isAndroid) {
      final photosStatus = await Permission.photos.request();
      if (photosStatus == PermissionStatus.granted) {
        return true;
      }
      
      // Fallback to storage permission for older versions
      final storageStatus = await Permission.storage.request();
      return storageStatus == PermissionStatus.granted;
    }
    
    // For iOS, request photos permission
    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status == PermissionStatus.granted;
    }
    
    return false;
  }

  static Future<bool> checkCameraPermission() async {
    if (kIsWeb) return true;
    return await Permission.camera.isGranted;
  }

  static Future<bool> checkStoragePermission() async {
    if (kIsWeb) return true;
    return await Permission.photos.isGranted || await Permission.storage.isGranted;
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}