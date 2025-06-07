import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';

class PhotoService {
  static const String _photoPathPrefix = 'delivery_photo_';
  
  /// Save a photo for a specific delivery ID
  Future<String?> saveDeliveryPhoto(String deliveryId, XFile photo) async {
    try {
      // Get the app documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String photosDir = '${appDocDir.path}/delivery_photos';
      
      // Create photos directory if it doesn't exist
      final Directory photoDirectory = Directory(photosDir);
      if (!await photoDirectory.exists()) {
        await photoDirectory.create(recursive: true);
      }
      
      // Generate unique filename with timestamp
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = 'delivery_${deliveryId}_$timestamp.jpg';
      final String filePath = '$photosDir/$fileName';
      
      // Copy the photo to the app directory
      final File savedPhoto = await File(photo.path).copy(filePath);
      
      // Store the photo path in SharedPreferences for persistence
      await _savePhotoPathToPreferences(deliveryId, savedPhoto.path);
      
      return savedPhoto.path;
    } catch (e) {
      print('Error saving photo: $e');
      return null;
    }
  }
  
  /// Get the photo path for a specific delivery ID
  Future<String?> getDeliveryPhotoPath(String deliveryId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_photoPathPrefix$deliveryId');
    } catch (e) {
      print('Error getting photo path: $e');
      return null;
    }
  }
  
  /// Check if a photo exists for a delivery
  Future<bool> hasDeliveryPhoto(String deliveryId) async {
    final String? photoPath = await getDeliveryPhotoPath(deliveryId);
    if (photoPath == null) return false;
    
    final File photoFile = File(photoPath);
    return await photoFile.exists();
  }
  
  /// Delete a photo for a specific delivery ID
  Future<bool> deleteDeliveryPhoto(String deliveryId) async {
    try {
      final String? photoPath = await getDeliveryPhotoPath(deliveryId);
      if (photoPath == null) return false;
      
      final File photoFile = File(photoPath);
      if (await photoFile.exists()) {
        await photoFile.delete();
      }
      
      // Remove from SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_photoPathPrefix$deliveryId');
      
      return true;
    } catch (e) {
      print('Error deleting photo: $e');
      return false;
    }
  }
  
  /// Get all delivery photos
  Future<Map<String, String>> getAllDeliveryPhotos() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Map<String, String> photos = {};
      
      for (String key in prefs.getKeys()) {
        if (key.startsWith(_photoPathPrefix)) {
          final String deliveryId = key.substring(_photoPathPrefix.length);
          final String? photoPath = prefs.getString(key);
          if (photoPath != null) {
            // Verify file still exists
            final File photoFile = File(photoPath);
            if (await photoFile.exists()) {
              photos[deliveryId] = photoPath;
            } else {
              // Clean up orphaned preference
              await prefs.remove(key);
            }
          }
        }
      }
      
      return photos;
    } catch (e) {
      print('Error getting all photos: $e');
      return {};
    }
  }
  
  /// Private method to save photo path to SharedPreferences
  Future<void> _savePhotoPathToPreferences(String deliveryId, String photoPath) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_photoPathPrefix$deliveryId', photoPath);
  }
  
  /// Clean up orphaned photos (photos without corresponding preferences)
  Future<void> cleanupOrphanedPhotos() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String photosDir = '${appDocDir.path}/delivery_photos';
      final Directory photoDirectory = Directory(photosDir);
      
      if (!await photoDirectory.exists()) return;
      
      final Map<String, String> validPhotos = await getAllDeliveryPhotos();
      final Set<String> validPaths = validPhotos.values.toSet();
      
      await for (FileSystemEntity entity in photoDirectory.list()) {
        if (entity is File && entity.path.endsWith('.jpg')) {
          if (!validPaths.contains(entity.path)) {
            await entity.delete();
            print('Deleted orphaned photo: ${entity.path}');
          }
        }
      }
    } catch (e) {
      print('Error cleaning up orphaned photos: $e');
    }
  }
}
