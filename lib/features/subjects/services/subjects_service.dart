import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../../shared/services/exam_categories_service.dart';
import '../models/subject.dart';
import '../models/topic.dart';

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
          .eq('is_active', true)
          .order('order_index');

      final subjects = (response as List)
          .map((json) => Subject.fromJson(json))
          .toList();
      
      log('Fetched ${subjects.length} subjects for exam category ID: $examCategoryId');
      
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
      
      await _supabase
          .from('subjects')
          .delete()
          .eq('id', id);
      
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
  Future<List<Map<String, dynamic>>> getSubjectsWithTopicsCount(String examCategoryId) async {
    try {
      log('Getting subjects with topics count for exam category ID: $examCategoryId');
      
      // First get all subjects
      final subjects = await getSubjects(examCategoryId);
      
      // Then get topics count for each subject
      List<Map<String, dynamic>> result = [];
      for (Subject subject in subjects) {
        final topicsCount = await getTopicsCount(subject.id);
        result.add({
          'subject': subject,
          'topicsCount': topicsCount,
        });
      }
      
      log('Fetched ${result.length} subjects with topics count for exam category ID: $examCategoryId');
      
      return result;
    } catch (e) {
      log('Error getting subjects with topics count for exam category ID $examCategoryId: $e');
      throw Exception('Failed to fetch subjects with topics count: $e');
    }
  }

  // Get exam category ID by name (helper method)
  Future<String?> getExamCategoryIdByName(String name) async {
    return await _examCategoriesService.getExamCategoryIdByName(name);
  }
}
