import 'dart:developer';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../models/question.dart';

class QuestionsService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Get all questions for a specific subject and section type
  Future<List<Question>> getQuestions(
    String subjectId, {
    String? topicId,
    String? sectionType,
  }) async {
    try {
      log(
        'Getting questions for subject ID: $subjectId, topic ID: $topicId, section: $sectionType',
      );

      var queryBuilder = _supabase
          .from('questions')
          .select()
          .eq('subject_id', subjectId);

      if (topicId != null) {
        queryBuilder = queryBuilder.eq('topic_id', topicId);
      }

      if (sectionType != null) {
        queryBuilder = queryBuilder.eq('section_type', sectionType);
      }

      final response = await queryBuilder.order('created_at', ascending: false);

      log('Response type: ${response.runtimeType}');
      log('Response length: ${(response as List).length}');
      log(
        'Raw response from Supabase: ${response.toString().length > 200 ? response.toString().substring(0, 200) + "..." : response.toString()}',
      );

      final questions = (response as List).map((json) {
        try {
          return Question.fromJson(json);
        } catch (e) {
          log('Error parsing question JSON: $e');
          log('Problematic JSON: $json');
          rethrow;
        }
      }).toList();

      log(
        'Fetched ${questions.length} questions for subject ID: $subjectId, topic ID: $topicId, section: $sectionType',
      );

      return questions;
    } catch (e) {
      log('Error fetching questions for subject ID $subjectId: $e');
      throw Exception('Failed to fetch questions: $e');
    }
  }

  // Get question by ID
  Future<Question?> getQuestionById(String questionId) async {
    try {
      log('Getting question by ID: $questionId');

      final response = await _supabase
          .from('questions')
          .select()
          .eq('id', questionId)
          .single();

      final question = Question.fromJson(response);
      log('Fetched question: ${question.questionText.substring(0, 50)}...');

      return question;
    } catch (e) {
      log('Error getting question by ID $questionId: $e');
      return null;
    }
  }

  // Upload image to Supabase Storage
  Future<String?> uploadImage(
    Uint8List fileBytes,
    String fileName,
    String bucket,
  ) async {
    try {
      log('Uploading image: $fileName to bucket: $bucket');

      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';

      await _supabase.storage
          .from(bucket)
          .uploadBinary(uniqueFileName, fileBytes);

      log('Image uploaded successfully: $uniqueFileName');

      // Get the public URL
      final publicUrl = _supabase.storage
          .from(bucket)
          .getPublicUrl(uniqueFileName);

      log('Public URL generated: $publicUrl');
      return publicUrl;
    } catch (e) {
      log('Error uploading image $fileName: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // Create new question
  Future<Question> createQuestion({
    required String questionText,
    String? questionImageUrl,
    required String subjectId,
    String? topicId,
    required String sectionType,
    required List<AnswerChoice> answerChoices,
    required String correctAnswer,
    required String explanationText,
    String? explanationImageUrl,
    required int difficultyLevel,
    required bool isActive,
  }) async {
    try {
      log('Creating question for subject ID: $subjectId');

      // Convert answer choices to JSON format for database
      final answerChoicesJson = answerChoices
          .map((choice) => choice.toJson())
          .toList();

      final response = await _supabase
          .from('questions')
          .insert({
            'question_text': questionText,
            'question_image_url': questionImageUrl,
            'subject_id': subjectId,
            'topic_id': topicId,
            'section_type': sectionType,
            'answer_choices': answerChoicesJson,
            'correct_answer': correctAnswer,
            'explanation_text': explanationText,
            'explanation_image_url': explanationImageUrl,
            'difficulty_level': difficultyLevel,
            'is_active': isActive,
          })
          .select()
          .single();

      final question = Question.fromJson(response);
      log('Created question with ID: ${question.id}');

      return question;
    } catch (e) {
      log('Error creating question: $e');
      throw Exception('Failed to create question: $e');
    }
  }

  // Update existing question
  Future<Question> updateQuestion({
    required String id,
    required String questionText,
    String? questionImageUrl,
    required String subjectId,
    String? topicId,
    required String sectionType,
    required List<AnswerChoice> answerChoices,
    required String correctAnswer,
    required String explanationText,
    String? explanationImageUrl,
    required int difficultyLevel,
    required bool isActive,
  }) async {
    try {
      log('Updating question with ID: $id');

      // Convert answer choices to JSON format for database
      final answerChoicesJson = answerChoices
          .map((choice) => choice.toJson())
          .toList();

      final response = await _supabase
          .from('questions')
          .update({
            'question_text': questionText,
            'question_image_url': questionImageUrl,
            'subject_id': subjectId,
            'topic_id': topicId,
            'section_type': sectionType,
            'answer_choices': answerChoicesJson,
            'correct_answer': correctAnswer,
            'explanation_text': explanationText,
            'explanation_image_url': explanationImageUrl,
            'difficulty_level': difficultyLevel,
            'is_active': isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      final question = Question.fromJson(response);
      log('Updated question with ID: ${question.id}');

      return question;
    } catch (e) {
      log('Error updating question with ID $id: $e');
      throw Exception('Failed to update question: $e');
    }
  }

  // Delete question
  Future<void> deleteQuestion(String id) async {
    try {
      log('Deleting question with ID: $id');

      await _supabase.from('questions').delete().eq('id', id);

      log('Deleted question with ID: $id');
    } catch (e) {
      log('Error deleting question with ID $id: $e');
      throw Exception('Failed to delete question: $e');
    }
  }

  // Get questions count for a subject
  Future<int> getQuestionsCount(String subjectId, {String? sectionType}) async {
    try {
      log(
        'Getting questions count for subject ID: $subjectId, section: $sectionType',
      );

      var query = _supabase
          .from('questions')
          .select('id')
          .eq('subject_id', subjectId)
          .eq('is_active', true);

      if (sectionType != null) {
        query = query.eq('section_type', sectionType);
      }

      final response = await query;

      final count = (response as List).length;
      log('Found $count questions for subject ID: $subjectId');

      return count;
    } catch (e) {
      log('Error getting questions count for subject ID $subjectId: $e');
      return 0;
    }
  }

  // Get questions statistics for a subject
  Future<Map<String, int>> getQuestionsStats(
    String subjectId, {
    String? topicId,
    String? sectionType,
  }) async {
    try {
      log(
        'Getting questions statistics for subject ID: $subjectId, topic ID: $topicId, section: $sectionType',
      );

      var query = _supabase
          .from('questions')
          .select('difficulty_level')
          .eq('subject_id', subjectId)
          .eq('is_active', true);

      if (topicId != null) {
        query = query.eq('topic_id', topicId);
      }

      if (sectionType != null) {
        query = query.eq('section_type', sectionType);
      }

      final response = await query;
      final questions = response as List;

      final stats = {
        'total': questions.length,
        'easy': questions.where((q) => q['difficulty_level'] <= 2).length,
        'medium': questions.where((q) => q['difficulty_level'] == 3).length,
        'hard': questions.where((q) => q['difficulty_level'] >= 4).length,
      };

      log('Questions stats for subject ID $subjectId: $stats');

      return stats;
    } catch (e) {
      log('Error getting questions stats for subject ID $subjectId: $e');
      return {'total': 0, 'easy': 0, 'medium': 0, 'hard': 0};
    }
  }

  // Get random questions for practice test
  Future<List<Question>> getRandomQuestions(
    String subjectId,
    int count, {
    int? difficultyLevel,
  }) async {
    try {
      log(
        'Getting $count random questions for subject ID: $subjectId, difficulty: $difficultyLevel',
      );

      var query = _supabase
          .from('questions')
          .select()
          .eq('subject_id', subjectId)
          .eq('section_type', 'practice_test')
          .eq('is_active', true);

      if (difficultyLevel != null) {
        query = query.eq('difficulty_level', difficultyLevel);
      }

      final response = await query;
      final allQuestions = (response as List)
          .map((json) => Question.fromJson(json))
          .toList();

      // Shuffle and take the requested count
      allQuestions.shuffle();
      final selectedQuestions = allQuestions.take(count).toList();

      log('Selected ${selectedQuestions.length} random questions');

      return selectedQuestions;
    } catch (e) {
      log('Error getting random questions for subject ID $subjectId: $e');
      throw Exception('Failed to get random questions: $e');
    }
  }

  // Delete image from Supabase Storage
  Future<void> deleteImage(String imageUrl, String bucket) async {
    try {
      log('Deleting image from bucket: $bucket, URL: $imageUrl');

      // Extract filename from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final fileName = pathSegments.last;

      await _supabase.storage.from(bucket).remove([fileName]);

      log('Successfully deleted image: $fileName from bucket: $bucket');
    } catch (e) {
      log('Error deleting image from bucket $bucket: $e');
      throw Exception('Failed to delete image: $e');
    }
  }

  // Get total questions count across all subjects
  Future<int> getTotalQuestionsCount() async {
    try {
      log('Getting total questions count across all subjects');

      final response = await _supabase
          .from('questions')
          .select('id')
          .eq('is_active', true);

      final count = (response as List).length;
      log('Found $count total active questions');

      return count;
    } catch (e) {
      log('Error getting total questions count: $e');
      return 0;
    }
  }

  // Get total practice tests count across all subjects
  Future<int> getTotalPracticeTestsCount() async {
    try {
      log('Getting total practice tests count across all subjects');

      final response = await _supabase
          .from('practice_tests')
          .select('id')
          .eq('is_active', true);

      final count = (response as List).length;
      log('Found $count total active practice tests');

      return count;
    } catch (e) {
      log('Error getting total practice tests count: $e');
      return 0;
    }
  }
}
