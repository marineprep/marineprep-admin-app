// Test script to verify storage configuration
// Run this in your Flutter app to test storage access

import 'dart:developer';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/core/config/supabase_config.dart';

Future<void> testStorageConfiguration() async {
  try {
    log('=== Storage Configuration Test ===');
    
    // Test authentication
    final user = SupabaseConfig.client.auth.currentUser;
    log('Current user: ${user?.email}');
    log('Is authenticated: ${user != null}');
    
    if (user == null) {
      log('❌ User is not authenticated');
      return;
    }
    
    // Test each bucket
    final buckets = ['videos', 'notes', 'images'];
    
    for (final bucket in buckets) {
      log('\n--- Testing bucket: $bucket ---');
      
      try {
        // Test bucket access
        final files = await SupabaseConfig.client.storage.from(bucket).list();
        log('✅ Bucket access successful: ${files.length} files found');
        
        // Test bucket info
        final bucketInfo = await SupabaseConfig.client.storage.getBucket(bucket);
        log('✅ Bucket info: ${bucketInfo.name}, Public: ${bucketInfo.public}');
        
      } catch (e) {
        log('❌ Bucket access failed: $e');
      }
    }
    
    // Test file upload (small test file)
    log('\n--- Testing file upload ---');
    try {
      final testData = 'Hello, this is a test file for storage configuration.';
      final testBytes = Uint8List.fromList(testData.codeUnits);
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final testPath = 'test_${timestamp}.txt';
      
      log('Attempting to upload test file: $testPath');
      
      final response = await SupabaseConfig.client.storage
          .from('notes')
          .uploadBinary(testPath, testBytes, fileOptions: FileOptions(
            contentType: 'text/plain',
            upsert: false,
          ));
      
      log('✅ Test upload successful: $response');
      
      // Clean up test file
      await SupabaseConfig.client.storage.from('notes').remove([testPath]);
      log('✅ Test file cleaned up');
      
    } catch (e) {
      log('❌ Test upload failed: $e');
    }
    
    log('\n=== Test Complete ===');
    
  } catch (e) {
    log('❌ Test failed: $e');
  }
}

// Add this to your main.dart or call it from a button
// testStorageConfiguration();
