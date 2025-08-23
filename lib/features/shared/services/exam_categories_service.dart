import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../models/exam_category.dart';

class ExamCategoriesService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Get exam category ID by name
  Future<String?> getExamCategoryIdByName(String name) async {
    try {
      log('Getting exam category ID for name: $name');

      final response = await _supabase
          .from('exam_categories')
          .select('id')
          .eq('name', name)
          .single();

      log('Raw response from exam_categories: $response');

      final categoryId = response['id'] as String;
      log('Found exam category ID: $categoryId for name: $name');

      return categoryId;
    } catch (e) {
      log('Error getting exam category ID for name $name: $e');
      log('Error type: ${e.runtimeType}');
      if (e is PostgrestException) {
        log('PostgrestException details: ${e.message}');
        log('PostgrestException code: ${e.code}');
        log('PostgrestException details: ${e.details}');
        log('PostgrestException hint: ${e.hint}');
      }
      return null;
    }
  }

  // Get all exam categories
  Future<List<ExamCategory>> getExamCategories() async {
    try {
      log('Fetching all exam categories');

      final response = await _supabase
          .from('exam_categories')
          .select()
          .order('name');

      final categories = (response as List)
          .map((json) => ExamCategory.fromJson(json))
          .toList();

      log('Fetched ${categories.length} exam categories');

      return categories;
    } catch (e) {
      log('Error fetching exam categories: $e');
      throw Exception('Failed to fetch exam categories: $e');
    }
  }

  // Get exam category by ID
  Future<ExamCategory?> getExamCategoryById(String id) async {
    try {
      log('Getting exam category by ID: $id');

      final response = await _supabase
          .from('exam_categories')
          .select()
          .eq('id', id)
          .single();

      return ExamCategory.fromJson(response);
    } catch (e) {
      log('Error getting exam category by ID $id: $e');
      return null;
    }
  }
}
