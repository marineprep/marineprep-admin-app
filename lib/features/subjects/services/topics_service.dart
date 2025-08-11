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
      
      final response = await _supabase
          .from('topics')
          .select()
          .eq('subject_id', subjectId)
          .eq('is_active', true)
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
      
      final response = await _supabase
          .from('topics')
          .insert({
            'name': name,
            'description': description,
            'subject_id': subjectId,
            'order_index': orderIndex,
            'videos': videos,
            'notes_url': notesUrl,
            'notes_file_name': notesFileName,
            'is_active': isActive,
          })
          .select()
          .single();

      final topic = Topic.fromJson(response);
      log('Created topic: ${topic.name} with ID: ${topic.id}');
      
      return topic;
    } catch (e) {
      log('Error creating topic $name: $e');
      throw Exception('Failed to create topic: $e');
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
      
      final response = await _supabase
          .from('topics')
          .update({
            'name': name,
            'description': description,
            'order_index': orderIndex,
            'videos': videos,
            'notes_url': notesUrl,
            'notes_file_name': notesFileName,
            'is_active': isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      final topic = Topic.fromJson(response);
      log('Updated topic: ${topic.name}');
      
      return topic;
    } catch (e) {
      log('Error updating topic $name with ID $id: $e');
      throw Exception('Failed to update topic: $e');
    }
  }

  // Delete topic
  Future<void> deleteTopic(String id) async {
    try {
      log('Deleting topic with ID: $id');
      
      await _supabase
          .from('topics')
          .delete()
          .eq('id', id);
      
      log('Deleted topic with ID: $id');
    } catch (e) {
      log('Error deleting topic with ID $id: $e');
      throw Exception('Failed to delete topic: $e');
    }
  }

  // Upload file to Supabase Storage
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List fileBytes,
    String? contentType,
  }) async {
    try {
      log('Uploading file to bucket: $bucket, path: $path');
      
      final response = await _supabase.storage
          .from(bucket)
          .uploadBinary(path, fileBytes, fileOptions: FileOptions(
            contentType: contentType,
          ));

      final url = _supabase.storage.from(bucket).getPublicUrl(path);
      log('Successfully uploaded file to: $url');
      
      return url;
    } catch (e) {
      log('Error uploading file to bucket $bucket, path $path: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  // Delete file from Supabase Storage
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      log('Deleting file from bucket: $bucket, path: $path');
      
      await _supabase.storage
          .from(bucket)
          .remove([path]);
      
      log('Successfully deleted file from bucket: $bucket, path: $path');
    } catch (e) {
      log('Error deleting file from bucket $bucket, path $path: $e');
      throw Exception('Failed to delete file: $e');
    }
  }
}
