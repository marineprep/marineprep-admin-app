class AppConstants {
  // App Information
  static const String appName = 'Marine Prep Admin';
  static const String appVersion = '1.0.0';

  // API Constants
  // static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  // static const String supabaseAnonKey = String.fromEnvironment(
  //   'SUPABASE_ANON_KEY',
  // );

  static const String supabaseUrl = 'https://cumvlrzfokzypalymeqd.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN1bXZscnpmb2t6eXBhbHltZXFkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MjYyMzcsImV4cCI6MjA3MDAwMjIzN30.1_n_vvlnhEQGXyCFoEhcnJ19VIfelIJZ4a1w8lbiayQ';

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
