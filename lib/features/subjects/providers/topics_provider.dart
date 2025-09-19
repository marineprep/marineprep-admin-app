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
final topicsProvider =
    StateNotifierProvider.family<
      TopicsNotifier,
      AsyncValue<List<Topic>>,
      String
    >((ref, subjectId) {
      return TopicsNotifier(ref.read(topicsServiceProvider), subjectId);
    });

// Individual topic provider
final topicProvider = FutureProvider.family<Topic?, String>((
  ref,
  topicId,
) async {
  final service = ref.read(topicsServiceProvider);
  return await service.getTopicById(topicId);
});

class TopicsNotifier extends StateNotifier<AsyncValue<List<Topic>>> {
  final TopicsService _service;
  final String _subjectId;

  TopicsNotifier(this._service, this._subjectId)
    : super(const AsyncValue.loading()) {
    log('Initializing TopicsNotifier for subject ID: $_subjectId');
    loadTopics();
  }

  Future<void> loadTopics() async {
    try {
      log('Loading topics for subject ID: $_subjectId');
      state = const AsyncValue.loading();
      final topics = await _service.getTopics(_subjectId);
      state = AsyncValue.data(topics);
      log(
        'Successfully loaded ${topics.length} topics for subject ID: $_subjectId',
      );
    } catch (error, stackTrace) {
      log('Error loading topics for subject ID $_subjectId: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addTopic({
    required String name,
    required String description,
    required List<VideoFile> videos,
    String? notesUrl,
    String? notesFileName,
    required bool isActive,
  }) async {
    try {
      log('Adding topic: $name for subject ID: $_subjectId');

      // Get the next available order index automatically
      final orderIndex = await _service.getNextOrderIndex(_subjectId);
      log('Auto-assigned order index: $orderIndex');

      await _service.createTopic(
        name: name,
        description: description,
        subjectId: _subjectId,
        orderIndex: orderIndex,
        videos: videos.map((video) => video.toJson()).toList(),
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
    required List<VideoFile> videos,
    String? notesUrl,
    String? notesFileName,
    required bool isActive,
  }) async {
    try {
      log('Updating topic: $name with ID: $id');

      // Get current topic to check if order index changed
      final currentTopic = await _service.getTopicById(id);
      if (currentTopic == null) {
        throw Exception('Topic not found');
      }

      final currentOrderIndex = currentTopic.orderIndex;
      final orderIndexChanged = currentOrderIndex != orderIndex;

      // Update the topic with new data
      await _service.updateTopic(
        id: id,
        name: name,
        description: description,
        orderIndex: orderIndex,
        videos: videos.map((video) => video.toJson()).toList(),
        notesUrl: notesUrl,
        notesFileName: notesFileName,
        isActive: isActive,
      );

      // If order index changed, move the topic to the new position
      if (orderIndexChanged) {
        log(
          'Order index changed from $currentOrderIndex to $orderIndex, moving topic to new position',
        );
        await moveTopicToPosition(id, orderIndex);
      } else {
        // Only reorder if order index didn't change (for other updates)
        await _service.reorderTopics(_subjectId);
        // Reload topics list
        await loadTopics();
      }

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

      // Reorder topics to ensure sequential order after deletion
      await _service.reorderTopics(_subjectId);

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

  // Move topic to a specific position
  Future<void> moveTopicToPosition(String topicId, int newPosition) async {
    try {
      log('Moving topic $topicId to position $newPosition');

      await _service.moveTopicToPosition(topicId, newPosition, _subjectId);

      // Add a small delay to ensure database operations complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Reload to update the UI with the new order
      await loadTopics();
      log('Successfully moved topic to position $newPosition');
    } catch (error) {
      log('Error moving topic: $error');
      rethrow;
    }
  }

  // Move topic up by one position
  Future<void> moveTopicUp(String topicId) async {
    try {
      log('Moving topic $topicId up');

      await _service.moveTopicUp(topicId, _subjectId);

      // Reload to update the UI with the new order
      await loadTopics();
      log('Successfully moved topic up');
    } catch (error) {
      log('Error moving topic up: $error');
      rethrow;
    }
  }

  // Move topic down by one position
  Future<void> moveTopicDown(String topicId) async {
    try {
      log('Moving topic $topicId down');

      await _service.moveTopicDown(topicId, _subjectId);

      // Reload to update the UI with the new order
      await loadTopics();
      log('Successfully moved topic down');
    } catch (error) {
      log('Error moving topic down: $error');
      rethrow;
    }
  }
}
