import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../../shared/services/exam_categories_service.dart';
import '../models/subject.dart';

class SubjectsService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final ExamCategoriesService _examCategoriesService = ExamCategoriesService();

  // Get all subjects for a specific exam category
  Future<List<Subject>> getSubjects(String examCategoryId) async {
    try {
      log('Getting subjects for exam category ID: $examCategoryId');

      final response = await _supabase
          .from('subjects')
          .select()
          .eq('exam_category_id', examCategoryId)
          .order('order_index');

      final subjects = (response as List)
          .map((json) => Subject.fromJson(json))
          .toList();

      log(
        'Fetched ${subjects.length} subjects for exam category ID: $examCategoryId',
      );

      return subjects;
    } catch (e) {
      log('Error fetching subjects for exam category ID $examCategoryId: $e');
      throw Exception('Failed to fetch subjects: $e');
    }
  }

  // Get subject by ID
  Future<Subject?> getSubjectById(String subjectId) async {
    try {
      log('Getting subject by ID: $subjectId');

      final response = await _supabase
          .from('subjects')
          .select()
          .eq('id', subjectId)
          .single();

      final subject = Subject.fromJson(response);
      log('Fetched subject: ${subject.name}');

      return subject;
    } catch (e) {
      log('Error getting subject by ID $subjectId: $e');
      return null;
    }
  }

  // Create new subject
  Future<Subject> createSubject({
    required String name,
    required String description,
    required String examCategoryId,
    required int orderIndex,
    required bool isActive,
  }) async {
    try {
      log('Creating subject: $name for exam category ID: $examCategoryId');

      final response = await _supabase
          .from('subjects')
          .insert({
            'name': name,
            'description': description,
            'exam_category_id': examCategoryId,
            'order_index': orderIndex,
            'is_active': isActive,
          })
          .select()
          .single();

      final subject = Subject.fromJson(response);
      log('Created subject: ${subject.name} with ID: ${subject.id}');

      return subject;
    } catch (e) {
      log('Error creating subject $name: $e');
      throw Exception('Failed to create subject: $e');
    }
  }

  // Update existing subject
  Future<Subject> updateSubject({
    required String id,
    required String name,
    required String description,
    required int orderIndex,
    required bool isActive,
  }) async {
    try {
      log('Updating subject: $name with ID: $id');

      final response = await _supabase
          .from('subjects')
          .update({
            'name': name,
            'description': description,
            'order_index': orderIndex,
            'is_active': isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      final subject = Subject.fromJson(response);
      log('Updated subject: ${subject.name}');

      return subject;
    } catch (e) {
      log('Error updating subject $name with ID $id: $e');
      throw Exception('Failed to update subject: $e');
    }
  }

  // Delete subject
  Future<void> deleteSubject(String id) async {
    try {
      log('Deleting subject with ID: $id');

      await _supabase.from('subjects').delete().eq('id', id);

      log('Deleted subject with ID: $id');
    } catch (e) {
      log('Error deleting subject with ID $id: $e');
      throw Exception('Failed to delete subject: $e');
    }
  }

  // Get topics count for a subject
  Future<int> getTopicsCount(String subjectId) async {
    try {
      log('Getting topics count for subject ID: $subjectId');

      final response = await _supabase
          .from('topics')
          .select('id')
          .eq('subject_id', subjectId)
          .eq('is_active', true);

      final count = (response as List).length;
      log('Found $count topics for subject ID: $subjectId');

      return count;
    } catch (e) {
      log('Error getting topics count for subject ID $subjectId: $e');
      return 0;
    }
  }

  // Get subjects with topics count
  Future<List<Map<String, dynamic>>> getSubjectsWithTopicsCount(
    String examCategoryId,
  ) async {
    try {
      log(
        'Getting subjects with topics count for exam category ID: $examCategoryId',
      );

      // First get all subjects
      final subjects = await getSubjects(examCategoryId);

      // Then get topics count for each subject
      List<Map<String, dynamic>> result = [];
      for (Subject subject in subjects) {
        final topicsCount = await getTopicsCount(subject.id);
        result.add({'subject': subject, 'topicsCount': topicsCount});
      }

      log(
        'Fetched ${result.length} subjects with topics count for exam category ID: $examCategoryId',
      );

      return result;
    } catch (e) {
      log(
        'Error getting subjects with topics count for exam category ID $examCategoryId: $e',
      );
      throw Exception('Failed to fetch subjects with topics count: $e');
    }
  }

  // Get exam category ID by name (helper method)
  Future<String?> getExamCategoryIdByName(String name) async {
    return await _examCategoriesService.getExamCategoryIdByName(name);
  }

  // Get the next available order index for a new subject
  Future<int> getNextOrderIndex(String examCategoryId) async {
    try {
      log('Getting next order index for exam category ID: $examCategoryId');

      final response = await _supabase
          .from('subjects')
          .select('order_index')
          .eq('exam_category_id', examCategoryId)
          .order('order_index', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        log('No existing subjects found, starting with order index 1');
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

  // Reorder subjects after deletion or order change
  Future<void> reorderSubjects(String examCategoryId) async {
    try {
      log('Reordering subjects for exam category ID: $examCategoryId');

      // Get all subjects ordered by current order_index
      final subjects = await getSubjects(examCategoryId);

      // Update order_index to be sequential (1, 2, 3, ...)
      for (int i = 0; i < subjects.length; i++) {
        final subject = subjects[i];
        final newOrderIndex = i + 1;

        if (subject.orderIndex != newOrderIndex) {
          log(
            'Updating subject ${subject.name} order from ${subject.orderIndex} to $newOrderIndex',
          );

          await _supabase
              .from('subjects')
              .update({'order_index': newOrderIndex})
              .eq('id', subject.id);
        }
      }

      log('Successfully reordered ${subjects.length} subjects');
    } catch (e) {
      log('Error reordering subjects: $e');
      throw Exception('Failed to reorder subjects: $e');
    }
  }

  // Move subject to a specific position and reorder others
  Future<void> moveSubjectToPosition(
    String subjectId,
    int newPosition,
    String examCategoryId,
  ) async {
    try {
      log('Moving subject $subjectId to position $newPosition');

      // Get current subject
      final currentSubject = await getSubjectById(subjectId);
      if (currentSubject == null) {
        throw Exception('Subject not found');
      }

      // Get all subjects
      final subjects = await getSubjects(examCategoryId);

      if (newPosition < 1 || newPosition > subjects.length) {
        throw Exception(
          'Invalid position: $newPosition. Must be between 1 and ${subjects.length}',
        );
      }

      final currentPosition = currentSubject.orderIndex;

      if (currentPosition == newPosition) {
        log('Subject is already at position $newPosition');
        return;
      }

      log(
        'Moving subject from position $currentPosition to position $newPosition',
      );

      // Create a new list with the subject moved to the new position
      final updatedSubjects = <Map<String, dynamic>>[];

      // Add subjects before the new position
      for (int i = 1; i < newPosition; i++) {
        final subject = subjects.firstWhere((s) => s.orderIndex == i);
        updatedSubjects.add({'id': subject.id, 'order_index': i});
      }

      // Add the moved subject at the new position
      updatedSubjects.add({'id': subjectId, 'order_index': newPosition});

      // Add subjects after the new position, shifting their order
      for (int i = newPosition + 1; i <= subjects.length; i++) {
        final subject = subjects.firstWhere((s) => s.orderIndex == i - 1);
        updatedSubjects.add({'id': subject.id, 'order_index': i});
      }

      // Update all subjects in a single transaction
      for (final update in updatedSubjects) {
        await _supabase
            .from('subjects')
            .update({'order_index': update['order_index']})
            .eq('id', update['id']);
      }

      log('Successfully moved subject to position $newPosition');
    } catch (e) {
      log('Error moving subject to position: $e');
      throw Exception('Failed to move subject to position: $e');
    }
  }
}
