import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

class SupabaseConfig {
  static late Supabase _instance;
  
  static Supabase get instance => _instance;
  static SupabaseClient get client => _instance.client;

  static Future<void> initialize() async {
    _instance = await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  }

  // Storage bucket references
  static SupabaseStorageClient get storage => client.storage;
  
  static String getPublicUrl(String bucket, String path) {
    return storage.from(bucket).getPublicUrl(path);
  }
}
