import 'dart:developer';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../models/topic.dart';

class TopicsService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Get all topics for a subject
  Future<List<Topic>> getTopics(String subjectId) async {
    try {
      log('Getting topics for subject ID: $subjectId');

      // First, test if we can access the topics table
      try {
        final testResponse = await _supabase
            .from('topics')
            .select('id')
            .limit(1);
        log('Topics table access test successful: ${testResponse.length} rows');
      } catch (e) {
        log('Topics table access test failed: $e');
        throw Exception('Cannot access topics table: $e');
      }

      final response = await _supabase
          .from('topics')
          .select()
          .eq('subject_id', subjectId)
          .order('order_index');

      final topics = (response as List)
          .map((json) => Topic.fromJson(json))
          .toList();

      log('Fetched ${topics.length} topics for subject ID: $subjectId');

      return topics;
    } catch (e) {
      log('Error fetching topics for subject ID $subjectId: $e');
      throw Exception('Failed to fetch topics: $e');
    }
  }

  // Get topic by ID
  Future<Topic?> getTopicById(String topicId) async {
    try {
      log('Getting topic by ID: $topicId');

      final response = await _supabase
          .from('topics')
          .select()
          .eq('id', topicId)
          .single();

      final topic = Topic.fromJson(response);
      log('Fetched topic: ${topic.name}');

      return topic;
    } catch (e) {
      log('Error getting topic by ID $topicId: $e');
      return null;
    }
  }

  // Create new topic
  Future<Topic> createTopic({
    required String name,
    required String description,
    required String subjectId,
    required int orderIndex,
    required List<Map<String, dynamic>> videos,
    String? notesUrl,
    String? notesFileName,
    required bool isActive,
  }) async {
    try {
      log('Creating topic: $name for subject ID: $subjectId');

      // Validate required fields
      if (name.isEmpty) throw Exception('Topic name cannot be empty');
      if (description.isEmpty)
        throw Exception('Topic description cannot be empty');
      if (subjectId.isEmpty) throw Exception('Subject ID cannot be empty');
      if (orderIndex < 0) throw Exception('Order index must be non-negative');

      // Log the data being sent to the database
      final insertData = {
        'name': name,
        'description': description,
        'subject_id': subjectId,
        'order_index': orderIndex,
        'videos': videos,
        'notes_url': notesUrl,
        'notes_file_name': notesFileName,
        'is_active': isActive,
      };

      log('Insert data: $insertData');
      log('Videos data type: ${videos.runtimeType}, count: ${videos.length}');
      if (videos.isNotEmpty) {
        log('First video data: ${videos.first}');
      }

      final response = await _supabase
          .from('topics')
          .insert(insertData)
          .select()
          .single();

      final topic = Topic.fromJson(response);
      log('Created topic: ${topic.name} with ID: ${topic.id}');

      return topic;
    } catch (e) {
      log('Error creating topic $name: $e');

      // Provide more specific error messages for common issues
      if (e.toString().contains('null')) {
        throw Exception(
          'Database error: One or more required fields are null. Check the data being sent.',
        );
      } else if (e.toString().contains('violates')) {
        throw Exception('Database constraint violation: $e');
      } else {
        throw Exception('Failed to create topic: $e');
      }
    }
  }

  // Update existing topic
  Future<Topic> updateTopic({
    required String id,
    required String name,
    required String description,
    required int orderIndex,
    required List<Map<String, dynamic>> videos,
    String? notesUrl,
    String? notesFileName,
    required bool isActive,
  }) async {
    try {
      log('Updating topic: $name with ID: $id');

      // Validate required fields
      if (id.isEmpty) throw Exception('Topic ID cannot be empty');
      if (name.isEmpty) throw Exception('Topic name cannot be empty');
      if (description.isEmpty)
        throw Exception('Topic description cannot be empty');
      if (orderIndex < 0) throw Exception('Order index must be non-negative');

      // Log the data being sent to the database
      final updateData = {
        'name': name,
        'description': description,
        'order_index': orderIndex,
        'videos': videos,
        'notes_url': notesUrl,
        'notes_file_name': notesFileName,
        'is_active': isActive,
        'updated_at': DateTime.now().toIso8601String(),
      };

      log('Update data: $updateData');
      log('Videos data type: ${videos.runtimeType}, count: ${videos.length}');
      if (videos.isNotEmpty) {
        log('First video data: ${videos.first}');
      }

      final response = await _supabase
          .from('topics')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      final topic = Topic.fromJson(response);
      log('Updated topic: ${topic.name}');

      return topic;
    } catch (e) {
      log('Error updating topic $name with ID $id: $e');

      // Provide more specific error messages for common issues
      if (e.toString().contains('null')) {
        throw Exception(
          'Database error: One or more required fields are null. Check the data being sent.',
        );
      } else if (e.toString().contains('violates')) {
        throw Exception('Database constraint violation: $e');
      } else {
        throw Exception('Failed to update topic: $e');
      }
    }
  }

  // Delete topic
  Future<void> deleteTopic(String id) async {
    try {
      log('Deleting topic with ID: $id');

      await _supabase.from('topics').delete().eq('id', id);

      log('Deleted topic with ID: $id');
    } catch (e) {
      log('Error deleting topic with ID $id: $e');
      throw Exception('Failed to delete topic: $e');
    }
  }

  // Upload file to Supabase Storage with improved authentication and error handling
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List fileBytes,
    String? contentType,
  }) async {
    try {
      // Check if user is authenticated
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to upload files');
      }

      log(
        'Uploading file to bucket: $bucket, path: $path, user: ${user.email}',
      );
      log('File size: ${fileBytes.length} bytes');
      log('Content type: $contentType');

      // Test bucket access first
      try {
        final bucketTest = await _supabase.storage.from(bucket).list();
        log(
          'Bucket access test successful for $bucket: ${bucketTest.length} files',
        );
      } catch (e) {
        log('Bucket access test failed for $bucket: $e');
        throw Exception(
          'Cannot access bucket "$bucket". Please check bucket configuration and policies.',
        );
      }

      // Generate a unique filename to avoid conflicts
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniquePath = '${timestamp}_$path';
      log('Generated unique path: $uniquePath');

      // Upload the file
      log('Starting file upload...');
      final response = await _supabase.storage
          .from(bucket)
          .uploadBinary(
            uniquePath,
            fileBytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: false, // Don't overwrite existing files
            ),
          );
      log('Upload response: $response');

      // Get the public URL
      final url = _supabase.storage.from(bucket).getPublicUrl(uniquePath);
      log('Successfully uploaded file to: $url');

      return url;
    } catch (e) {
      log('Error uploading file to bucket $bucket, path $path: $e');
      log('Error type: ${e.runtimeType}');
      log('Error details: ${e.toString()}');

      // Provide more specific error messages
      if (e.toString().contains('new row violates row-level security policy')) {
        throw Exception(
          'Storage RLS policy violation. Please check storage bucket policies for "$bucket". Run the storage setup script or configure policies manually.',
        );
      } else if (e.toString().contains('bucket not found')) {
        throw Exception(
          'Storage bucket "$bucket" not found. Please check your Supabase configuration.',
        );
      } else if (e.toString().contains('file size limit')) {
        throw Exception(
          'File size exceeds the allowed limit for bucket "$bucket".',
        );
      } else if (e.toString().contains('Unauthorized')) {
        throw Exception(
          'Unauthorized access to storage. Please ensure you are authenticated and have proper permissions for bucket "$bucket".',
        );
      } else {
        throw Exception('Failed to upload file: $e');
      }
    }
  }

  // Delete file from Supabase Storage
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      log('Deleting file from bucket: $bucket, path: $path');

      await _supabase.storage.from(bucket).remove([path]);

      log('Successfully deleted file from bucket: $bucket, path: $path');
    } catch (e) {
      log('Error deleting file from bucket $bucket, path $path: $e');
      throw Exception('Failed to delete file: $e');
    }
  }

  // Get the next available order index for a new topic
  Future<int> getNextOrderIndex(String subjectId) async {
    try {
      log('Getting next order index for subject ID: $subjectId');

      final response = await _supabase
          .from('topics')
          .select('order_index')
          .eq('subject_id', subjectId)
          .order('order_index', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        log('No existing topics found, starting with order index 1');
        return 1;
      }

      final maxOrderIndex = response.first['order_index'] as int;
      final nextOrderIndex = maxOrderIndex + 1;
      log(
        'Next order index: $nextOrderIndex (max: $maxOrderIndex) - will appear first in UI',
      );

      return nextOrderIndex;
    } catch (e) {
      log('Error getting next order index: $e');
      return 1; // Fallback to 1 if there's an error
    }
  }

  // Reorder topics after deletion or order change
  Future<void> reorderTopics(String subjectId) async {
    try {
      log('Reordering topics for subject ID: $subjectId');

      // Get all topics ordered by current order_index
      final topics = await getTopics(subjectId);

      // Update order_index to be sequential (1, 2, 3, ...)
      for (int i = 0; i < topics.length; i++) {
        final topic = topics[i];
        final newOrderIndex = i + 1;

        if (topic.orderIndex != newOrderIndex) {
          log(
            'Updating topic ${topic.name} order from ${topic.orderIndex} to $newOrderIndex',
          );

          await _supabase
              .from('topics')
              .update({'order_index': newOrderIndex})
              .eq('id', topic.id);
        }
      }

      log('Successfully reordered ${topics.length} topics');
    } catch (e) {
      log('Error reordering topics: $e');
      throw Exception('Failed to reorder topics: $e');
    }
  }

  // Move topic to a specific position and reorder others
  Future<void> moveTopicToPosition(
    String topicId,
    int newPosition,
    String subjectId,
  ) async {
    try {
      log('Moving topic $topicId to position $newPosition');

      // Get current topic
      final currentTopic = await getTopicById(topicId);
      if (currentTopic == null) {
        throw Exception('Topic not found');
      }

      // Get all topics
      final topics = await getTopics(subjectId);

      if (newPosition < 1 || newPosition > topics.length) {
        throw Exception(
          'Invalid position: $newPosition. Must be between 1 and ${topics.length}',
        );
      }

      final currentPosition = currentTopic.orderIndex;

      if (currentPosition == newPosition) {
        log('Topic is already at position $newPosition');
        return;
      }

      log(
        'Moving topic from position $currentPosition to position $newPosition',
      );

      // Create a new list with the topic moved to the new position
      final updatedTopics = <Map<String, dynamic>>[];

      // Add topics before the new position
      for (int i = 1; i < newPosition; i++) {
        final topic = topics.firstWhere((t) => t.orderIndex == i);
        updatedTopics.add({'id': topic.id, 'order_index': i});
      }

      // Add the moved topic at the new position
      updatedTopics.add({'id': topicId, 'order_index': newPosition});

      // Add topics after the new position, shifting their order
      for (int i = newPosition + 1; i <= topics.length; i++) {
        final topic = topics.firstWhere((t) => t.orderIndex == i - 1);
        updatedTopics.add({'id': topic.id, 'order_index': i});
      }

      // Update all topics in a single transaction
      for (final update in updatedTopics) {
        await _supabase
            .from('topics')
            .update({'order_index': update['order_index']})
            .eq('id', update['id']);
      }

      log('Successfully moved topic to position $newPosition');
    } catch (e) {
      log('Error moving topic to position: $e');
      throw Exception('Failed to move topic to position: $e');
    }
  }
}
