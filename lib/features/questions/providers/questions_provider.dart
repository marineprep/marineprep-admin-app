import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../models/question.dart';
import '../services/questions_service.dart';

// Service provider
final questionsServiceProvider = Provider<QuestionsService>((ref) {
  return QuestionsService();
});

// Questions list provider for a specific subject and section type
final questionsProvider =
    StateNotifierProvider.family<
      QuestionsNotifier,
      AsyncValue<List<Question>>,
      QuestionsFilter
    >((ref, filter) {
      return QuestionsNotifier(ref.read(questionsServiceProvider), filter, ref);
    });

// Individual question provider
final questionProvider = FutureProvider.family<Question?, String>((
  ref,
  questionId,
) async {
  final service = ref.read(questionsServiceProvider);
  return await service.getQuestionById(questionId);
});

// Questions statistics provider
final questionsStatsProvider =
    FutureProvider.family<Map<String, int>, QuestionsFilter>((
      ref,
      filter,
    ) async {
      final service = ref.read(questionsServiceProvider);
      return await service.getQuestionsStats(
        filter.subjectId,
        topicId: filter.topicId,
        sectionType: filter.sectionType,
      );
    });

// Filter class for questions
class QuestionsFilter {
  final String subjectId;
  final String? topicId;
  final String? sectionType;

  const QuestionsFilter({
    required this.subjectId,
    this.topicId,
    this.sectionType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionsFilter &&
          runtimeType == other.runtimeType &&
          subjectId == other.subjectId &&
          topicId == other.topicId &&
          sectionType == other.sectionType;

  @override
  int get hashCode =>
      subjectId.hashCode ^ topicId.hashCode ^ sectionType.hashCode;
}

class QuestionsNotifier extends StateNotifier<AsyncValue<List<Question>>> {
  final QuestionsService _service;
  final QuestionsFilter _filter;
  final Ref _ref;

  QuestionsNotifier(this._service, this._filter, this._ref)
    : super(const AsyncValue.loading()) {
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    try {
      log(
        'Loading questions for subject ID: ${_filter.subjectId}, section: ${_filter.sectionType}',
      );
      state = const AsyncValue.loading();
      final questions = await _service.getQuestions(
        _filter.subjectId,
        topicId: _filter.topicId,
        sectionType: _filter.sectionType,
      );
      state = AsyncValue.data(questions);
      log('Successfully loaded ${questions.length} questions');
    } catch (error, stackTrace) {
      log('Error loading questions: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addQuestion({
    required String questionText, // Legacy field
    Delta? questionContent, // New rich content
    String? questionImageUrl,
    required String sectionType,
    String? topicId,
    required List<AnswerChoice> answerChoices,
    required String correctAnswer,
    required String explanationText, // Legacy field
    Delta? explanationContent, // New rich content
    String? explanationImageUrl,
    required int difficultyLevel,
    required bool isActive,
  }) async {
    try {
      log('Adding question for subject ID: ${_filter.subjectId}');

      await _service.createQuestion(
        questionText: questionText,
        questionContent: questionContent,
        questionImageUrl: questionImageUrl,
        subjectId: _filter.subjectId,
        topicId: topicId,
        sectionType: sectionType,
        answerChoices: answerChoices,
        correctAnswer: correctAnswer,
        explanationText: explanationText,
        explanationContent: explanationContent,
        explanationImageUrl: explanationImageUrl,
        difficultyLevel: difficultyLevel,
        isActive: isActive,
      );

      // Reload questions list
      await loadQuestions();

      // Invalidate stats provider to refresh statistics
      _ref.invalidate(questionsStatsProvider(_filter));

      log('Successfully added question');
    } catch (error, stackTrace) {
      log('Error adding question: $error');
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateQuestion({
    required String id,
    required String questionText, // Legacy field
    Delta? questionContent, // New rich content
    String? questionImageUrl,
    required String sectionType,
    String? topicId,
    required List<AnswerChoice> answerChoices,
    required String correctAnswer,
    required String explanationText, // Legacy field
    Delta? explanationContent, // New rich content
    String? explanationImageUrl,
    required int difficultyLevel,
    required bool isActive,
  }) async {
    try {
      log('Updating question with ID: $id');

      await _service.updateQuestion(
        id: id,
        questionText: questionText,
        questionContent: questionContent,
        questionImageUrl: questionImageUrl,
        subjectId: _filter.subjectId,
        topicId: topicId,
        sectionType: sectionType,
        answerChoices: answerChoices,
        correctAnswer: correctAnswer,
        explanationText: explanationText,
        explanationContent: explanationContent,
        explanationImageUrl: explanationImageUrl,
        difficultyLevel: difficultyLevel,
        isActive: isActive,
      );

      // Reload questions list
      await loadQuestions();

      // Invalidate stats provider to refresh statistics
      _ref.invalidate(questionsStatsProvider(_filter));

      log('Successfully updated question with ID: $id');
    } catch (error, stackTrace) {
      log('Error updating question: $error');
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteQuestion(String id) async {
    try {
      log('Deleting question with ID: $id');

      await _service.deleteQuestion(id);

      // Reload questions list
      await loadQuestions();

      // Invalidate stats provider to refresh statistics
      _ref.invalidate(questionsStatsProvider(_filter));

      log('Successfully deleted question with ID: $id');
    } catch (error, stackTrace) {
      log('Error deleting question: $error');
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  void refresh() {
    log('Refreshing questions');
    loadQuestions();
  }

  // Upload image helper
  Future<String?> uploadImage(
    List<int> fileBytes,
    String fileName,
    String bucket,
  ) async {
    try {
      log('Uploading image: $fileName');
      final bytes = Uint8List.fromList(fileBytes);
      return await _service.uploadImage(bytes, fileName, bucket);
    } catch (error) {
      log('Error uploading image: $error');
      rethrow;
    }
  }
}
