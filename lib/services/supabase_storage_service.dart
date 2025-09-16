import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../config/supabase_config.dart';

class SupabaseStorageService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Upload file to storage bucket
  static Future<String> uploadFile({
    required File file,
    required String bucketName,
    required String fileName,
    String? folder,
  }) async {
    try {
      final fileBytes = await file.readAsBytes();
      final filePath = folder != null ? '$folder/$fileName' : fileName;

      await _client.storage
          .from(bucketName)
          .uploadBinary(filePath, fileBytes);

      // Get public URL
      final publicUrl = _client.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('File upload failed: $e');
    }
  }

  /// Upload tutor video
  static Future<String> uploadTutorVideo({
    required File videoFile,
    required String tutorId,
    required String fileName,
  }) async {
    return await uploadFile(
      file: videoFile,
      bucketName: SupabaseConfig.tutorVideosBucket,
      fileName: fileName,
      folder: tutorId,
    );
  }

  /// Upload document
  static Future<String> uploadDocument({
    required File documentFile,
    required String tutorId,
    required String documentType,
    required String fileName,
  }) async {
    return await uploadFile(
      file: documentFile,
      bucketName: SupabaseConfig.documentsBucket,
      fileName: fileName,
      folder: '$tutorId/$documentType',
    );
  }

  /// Upload profile picture
  static Future<String> uploadProfilePicture({
    required File imageFile,
    required String userId,
    required String fileName,
  }) async {
    return await uploadFile(
      file: imageFile,
      bucketName: SupabaseConfig.profilePicsBucket,
      fileName: fileName,
      folder: userId,
    );
  }

  /// Delete file from storage
  static Future<void> deleteFile({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      await _client.storage
          .from(bucketName)
          .remove([filePath]);
    } catch (e) {
      throw Exception('File deletion failed: $e');
    }
  }

  /// Get file URL
  static String getFileUrl({
    required String bucketName,
    required String filePath,
  }) {
    return _client.storage
        .from(bucketName)
        .getPublicUrl(filePath);
  }

  /// List files in bucket
  static Future<List<FileObject>> listFiles({
    required String bucketName,
    String? folder,
  }) async {
    try {
      final response = await _client.storage
          .from(bucketName)
          .list(path: folder ?? '');
      return response;
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }
}
