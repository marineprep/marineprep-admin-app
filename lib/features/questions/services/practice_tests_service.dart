import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/practice_test.dart';

class PracticeTestsService {
  final SupabaseClient _supabase;

  PracticeTestsService(this._supabase);

  /// Get all practice tests for an exam category
  Future<List<PracticeTest>> getPracticeTests(String examCategoryId) async {
    try {
      log('Getting practice tests for exam category: $examCategoryId');

      final query = _supabase
          .from('practice_tests')
          .select()
          .eq('exam_category_id', examCategoryId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      log('Executing query: ${query.toString()}');

      final response = await query;

      log('Raw database response: $response');
      log('Response type: ${response.runtimeType}');
      log(
        'Response length: ${response is List ? response.length : 'Not a list'}',
      );

      final tests = (response as List)
          .map((json) => PracticeTest.fromJson(json))
          .toList();

      log('Found ${tests.length} practice tests');
      return tests;
    } catch (e) {
      log('Error getting practice tests: $e');
      log('Error type: ${e.runtimeType}');
      if (e is PostgrestException) {
        log('PostgrestException details: ${e.message}');
        log('PostgrestException code: ${e.code}');
        log('PostgrestException details: ${e.details}');
        log('PostgrestException hint: ${e.hint}');
      }
      throw Exception('Failed to get practice tests: $e');
    }
  }

  /// Get a single practice test by ID
  Future<PracticeTest?> getPracticeTest(String testId) async {
    try {
      log('Getting practice test: $testId');

      final response = await _supabase
          .from('practice_tests')
          .select()
          .eq('id', testId)
          .single();

      // response will never be null from single() method

      return PracticeTest.fromJson(response);
    } catch (e) {
      log('Error getting practice test $testId: $e');
      throw Exception('Failed to get practice test: $e');
    }
  }

  /// Create a new practice test
  Future<PracticeTest> createPracticeTest({
    required String name,
    required String description,
    required String examCategoryId,
    required int totalQuestions,
    int? timeLimitMinutes,
    double? passingScore,
  }) async {
    try {
      log('Creating practice test: $name');
      log('Exam category ID: $examCategoryId');
      log('Total questions: $totalQuestions');
      log('Time limit: $timeLimitMinutes');
      log('Passing score: $passingScore');

      final insertData = {
        'name': name,
        'description': description,
        'exam_category_id': examCategoryId,
        'total_questions': totalQuestions,
        'time_limit_minutes': timeLimitMinutes,
        'passing_score': passingScore,
        'is_active': true,
      };

      log('Insert data: $insertData');

      final response = await _supabase
          .from('practice_tests')
          .insert(insertData)
          .select()
          .single();

      log('Database response: $response');

      final test = PracticeTest.fromJson(response);
      log('Created practice test: ${test.id}');
      return test;
    } catch (e) {
      log('Error creating practice test: $e');
      log('Error type: ${e.runtimeType}');
      if (e is PostgrestException) {
        log('PostgrestException details: ${e.message}');
        log('PostgrestException code: ${e.code}');
        log('PostgrestException details: ${e.details}');
        log('PostgrestException hint: ${e.hint}');
      }
      throw Exception('Failed to create practice test: $e');
    }
  }

  /// Update a practice test
  Future<PracticeTest> updatePracticeTest({
    required String testId,
    String? name,
    String? description,
    int? totalQuestions,
    int? timeLimitMinutes,
    double? passingScore,
    bool? isActive,
  }) async {
    try {
      log('Updating practice test: $testId');

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (totalQuestions != null)
        updateData['total_questions'] = totalQuestions;
      if (timeLimitMinutes != null)
        updateData['time_limit_minutes'] = timeLimitMinutes;
      if (passingScore != null) updateData['passing_score'] = passingScore;
      if (isActive != null) updateData['is_active'] = isActive;

      final response = await _supabase
          .from('practice_tests')
          .update(updateData)
          .eq('id', testId)
          .select()
          .single();

      final test = PracticeTest.fromJson(response);
      log('Updated practice test: ${test.id}');
      return test;
    } catch (e) {
      log('Error updating practice test $testId: $e');
      throw Exception('Failed to update practice test: $e');
    }
  }

  /// Delete a practice test
  Future<void> deletePracticeTest(String testId) async {
    try {
      log('Deleting practice test: $testId');

      await _supabase.from('practice_tests').delete().eq('id', testId);

      log('Deleted practice test: $testId');
    } catch (e) {
      log('Error deleting practice test $testId: $e');
      throw Exception('Failed to delete practice test: $e');
    }
  }

  /// Get subjects for a practice test
  Future<List<PracticeTestSubject>> getTestSubjects(String testId) async {
    try {
      log('Getting subjects for practice test: $testId');

      final response = await _supabase
          .from('practice_test_subjects')
          .select()
          .eq('practice_test_id', testId)
          .order('order_index');

      final subjects = (response as List)
          .map((json) => PracticeTestSubject.fromJson(json))
          .toList();

      log('Found ${subjects.length} subjects for test $testId');
      return subjects;
    } catch (e) {
      log('Error getting test subjects: $e');
      throw Exception('Failed to get test subjects: $e');
    }
  }

  /// Add a subject to a practice test
  Future<PracticeTestSubject> addSubjectToTest({
    required String testId,
    required String subjectId,
    required int questionCount,
    int orderIndex = 0,
  }) async {
    try {
      log('Adding subject $subjectId to test $testId');

      final response = await _supabase
          .from('practice_test_subjects')
          .insert({
            'practice_test_id': testId,
            'subject_id': subjectId,
            'question_count': questionCount,
            'order_index': orderIndex,
          })
          .select()
          .single();

      final testSubject = PracticeTestSubject.fromJson(response);
      log('Added subject to test: ${testSubject.id}');
      return testSubject;
    } catch (e) {
      log('Error adding subject to test: $e');
      throw Exception('Failed to add subject to test: $e');
    }
  }

  /// Remove a subject from a practice test
  Future<void> removeSubjectFromTest(String testSubjectId) async {
    try {
      log('Removing subject from test: $testSubjectId');

      await _supabase
          .from('practice_test_subjects')
          .delete()
          .eq('id', testSubjectId);

      log('Removed subject from test: $testSubjectId');
    } catch (e) {
      log('Error removing subject from test: $e');
      throw Exception('Failed to remove subject from test: $e');
    }
  }

  /// Update a test subject (e.g., change question count)
  Future<PracticeTestSubject> updateTestSubject({
    required String testSubjectId,
    int? questionCount,
    int? orderIndex,
  }) async {
    try {
      log('Updating test subject: $testSubjectId');

      final updateData = <String, dynamic>{};
      if (questionCount != null) updateData['question_count'] = questionCount;
      if (orderIndex != null) updateData['order_index'] = orderIndex;

      final response = await _supabase
          .from('practice_test_subjects')
          .update(updateData)
          .eq('id', testSubjectId)
          .select()
          .single();

      final testSubject = PracticeTestSubject.fromJson(response);
      log('Updated test subject: ${testSubject.id}');
      return testSubject;
    } catch (e) {
      log('Error updating test subject $testSubjectId: $e');
      throw Exception('Failed to update test subject: $e');
    }
  }

  /// Debug method to check database connection and table structure
  Future<Map<String, dynamic>> debugDatabaseConnection() async {
    try {
      log('Debugging database connection...');

      // Check if practice_tests table exists
      final tableCheck = await _supabase
          .from('practice_tests')
          .select('id')
          .limit(1);

      log('Table check response: $tableCheck');

      // Check exam_categories table
      final examCategories = await _supabase
          .from('exam_categories')
          .select('id, name')
          .eq('name', 'IMUCET');

      log('Exam categories response: $examCategories');

      // Check RLS policies
      final policies = await _supabase.rpc(
        'get_policies',
        params: {'table_name': 'practice_tests'},
      );

      log('RLS policies response: $policies');

      return {
        'table_exists': tableCheck.isNotEmpty,
        'exam_categories': examCategories,
        'policies': policies,
        'status': 'success',
      };
    } catch (e) {
      log('Debug error: $e');
      return {'error': e.toString(), 'status': 'error'};
    }
  }
}
