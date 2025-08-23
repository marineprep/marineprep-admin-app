import 'package:flutter/foundation.dart';
import 'package:marine_prep_admin/core/constants/supabase_constants.dart';

class AppConstants {
  // App Information
  static const String appName = 'Marine Prep Admin';
  static const String appVersion = '1.0.0';

  // API Constants
  static const String supabaseUrl = kDebugMode
      ? supabaseUrlForDebug
      : String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = kDebugMode
      ? supabaseAnonKeyForDebug
      : String.fromEnvironment('SUPABASE_ANON_KEY');

  // Storage Buckets
  static const String videosBucket = 'videos';
  static const String notesBucket = 'notes';
  static const String imagesBucket = 'images';

  // Exam Categories
  static const List<String> examCategories = ['IMUCET', 'DECK', 'ENGINE'];

  // File Upload Limits
  static const int maxFileSize = 100 * 1024 * 1024; // 100MB
  static const List<String> allowedVideoFormats = ['.mp4', '.mov', '.avi'];
  static const List<String> allowedDocumentFormats = ['.pdf', '.doc', '.docx'];
  static const List<String> allowedImageFormats = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
  ];
}
