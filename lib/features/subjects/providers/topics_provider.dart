import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/topic.dart';
import '../services/topics_service.dart';

// Service provider
final topicsServiceProvider = Provider<TopicsService>((ref) {
  return TopicsService();
});

// Topics list provider
final topicsProvider = StateNotifierProvider.family<TopicsNotifier, AsyncValue<List<Topic>>, String>(
  (ref, subjectId) {
    return TopicsNotifier(
      ref.read(topicsServiceProvider),
      subjectId,
    );
  },
);

// Individual topic provider
final topicProvider = FutureProvider.family<Topic?, String>((ref, topicId) async {
  final service = ref.read(topicsServiceProvider);
  return await service.getTopicById(topicId);
});

class TopicsNotifier extends StateNotifier<AsyncValue<List<Topic>>> {
  final TopicsService _service;
  final String _subjectId;

  TopicsNotifier(this._service, this._subjectId) : super(const AsyncValue.loading()) {
    log('Initializing TopicsNotifier for subject ID: $_subjectId');
    loadTopics();
  }

  Future<void> loadTopics() async {
    try {
      log('Loading topics for subject ID: $_subjectId');
      state = const AsyncValue.loading();
      final topics = await _service.getTopics(_subjectId);
      state = AsyncValue.data(topics);
      log('Successfully loaded ${topics.length} topics for subject ID: $_subjectId');
    } catch (error, stackTrace) {
      log('Error loading topics for subject ID $_subjectId: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addTopic({
    required String name,
    required String description,
    required int orderIndex,
    required List<Map<String, dynamic>> videos,
    String? notesUrl,
    String? notesFileName,
    required bool isActive,
  }) async {
    try {
      log('Adding topic: $name for subject ID: $_subjectId');
      
      await _service.createTopic(
        name: name,
        description: description,
        subjectId: _subjectId,
        orderIndex: orderIndex,
        videos: videos,
        notesUrl: notesUrl,
        notesFileName: notesFileName,
        isActive: isActive,
      );
      
      // Reload topics list
      await loadTopics();
      log('Successfully added topic: $name');
    } catch (error, stackTrace) {
      log('Error adding topic: $error');
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateTopic({
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
      
      await _service.updateTopic(
        id: id,
        name: name,
        description: description,
        orderIndex: orderIndex,
        videos: videos,
        notesUrl: notesUrl,
        notesFileName: notesFileName,
        isActive: isActive,
      );
      
      // Reload topics list
      await loadTopics();
      log('Successfully updated topic: $name');
    } catch (error, stackTrace) {
      log('Error updating topic: $error');
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteTopic(String id) async {
    try {
      log('Deleting topic with ID: $id');
      
      await _service.deleteTopic(id);
      
      // Reload topics list
      await loadTopics();
      log('Successfully deleted topic with ID: $id');
    } catch (error, stackTrace) {
      log('Error deleting topic: $error');
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  void refresh() {
    log('Refreshing topics for subject ID: $_subjectId');
    loadTopics();
  }
}
