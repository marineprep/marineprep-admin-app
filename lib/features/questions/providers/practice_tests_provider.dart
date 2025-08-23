import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/practice_test.dart';
import '../services/practice_tests_service.dart';
import '../../shared/services/exam_categories_service.dart';
import '../../../core/config/supabase_config.dart';

final practiceTestsServiceProvider = Provider<PracticeTestsService>((ref) {
  return PracticeTestsService(SupabaseConfig.client);
});

final examCategoriesServiceProvider = Provider<ExamCategoriesService>((ref) {
  return ExamCategoriesService();
});

// StateNotifierProvider for managing practice tests state
final practiceTestsNotifierProvider =
    StateNotifierProvider.family<
      PracticeTestsNotifier,
      AsyncValue<List<PracticeTest>>,
      String
    >((ref, examCategoryName) {
      final service = ref.watch(practiceTestsServiceProvider);
      final examCategoriesService = ref.watch(examCategoriesServiceProvider);
      return PracticeTestsNotifier(
        service,
        examCategoriesService,
        examCategoryName,
      );
    });

// FutureProvider that depends on the StateNotifierProvider for instant updates
final practiceTestsProvider = FutureProvider.family<List<PracticeTest>, String>(
  (ref, examCategoryName) async {
    // Watch the notifier provider to get instant updates
    final notifierState = ref.watch(
      practiceTestsNotifierProvider(examCategoryName),
    );

    return notifierState.when(
      data: (tests) => tests,
      loading: () => throw Exception('Loading...'),
      error: (error, stack) => throw error,
    );
  },
);

final practiceTestProvider = FutureProvider.family<PracticeTest?, String>((
  ref,
  testId,
) async {
  final service = ref.watch(practiceTestsServiceProvider);
  return service.getPracticeTest(testId);
});

final practiceTestSubjectsProvider =
    FutureProvider.family<List<PracticeTestSubject>, String>((
      ref,
      testId,
    ) async {
      final service = ref.watch(practiceTestsServiceProvider);
      return service.getTestSubjects(testId);
    });

class PracticeTestsNotifier
    extends StateNotifier<AsyncValue<List<PracticeTest>>> {
  final PracticeTestsService _service;
  final ExamCategoriesService _examCategoriesService;
  final String _examCategoryName;
  String? _examCategoryId;

  PracticeTestsNotifier(
    this._service,
    this._examCategoriesService,
    this._examCategoryName,
  ) : super(const AsyncValue.loading()) {
    _initializeAndLoadTests();
  }

  Future<void> _initializeAndLoadTests() async {
    try {
      log(
        'Initializing PracticeTestsNotifier for exam category: $_examCategoryName',
      );

      // Get the exam category ID from the name
      _examCategoryId = await _examCategoriesService.getExamCategoryIdByName(
        _examCategoryName,
      );

      if (_examCategoryId == null) {
        log(
          'Error: Could not find exam category ID for name: $_examCategoryName',
        );
        state = AsyncValue.error(
          'Exam category "$_examCategoryName" not found',
          StackTrace.current,
        );
        return;
      }

      log(
        'Found exam category ID: $_examCategoryId for name: $_examCategoryName',
      );

      // Load tests with the resolved UUID
      await _loadTests();
    } catch (error, stackTrace) {
      log('Error initializing PracticeTestsNotifier: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> _loadTests() async {
    try {
      if (_examCategoryId == null) {
        log('Error: examCategoryId is null, cannot load tests');
        state = AsyncValue.error(
          'Exam category ID not resolved',
          StackTrace.current,
        );
        return;
      }

      log('Loading practice tests for exam category ID: $_examCategoryId');
      state = const AsyncValue.loading();
      final tests = await _service.getPracticeTests(_examCategoryId!);
      state = AsyncValue.data(tests);
      log('Successfully loaded ${tests.length} practice tests');
    } catch (error, stackTrace) {
      log('Error loading practice tests: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createTest({
    required String name,
    required String description,
    required int totalQuestions,
    int? timeLimitMinutes,
    double? passingScore,
  }) async {
    try {
      if (_examCategoryId == null) {
        throw Exception('Exam category ID not resolved');
      }

      log('Creating practice test: $name');
      final newTest = await _service.createPracticeTest(
        name: name,
        description: description,
        examCategoryId: _examCategoryId!,
        totalQuestions: totalQuestions,
        timeLimitMinutes: timeLimitMinutes,
        passingScore: passingScore,
      );

      log('Practice test created successfully: ${newTest.id}');

      // Update state immediately with the new test
      state.whenData((tests) {
        state = AsyncValue.data([newTest, ...tests]);
      });
    } catch (error, stackTrace) {
      log('Error creating practice test: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTest({
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
      final updatedTest = await _service.updatePracticeTest(
        testId: testId,
        name: name,
        description: description,
        totalQuestions: totalQuestions,
        timeLimitMinutes: timeLimitMinutes,
        passingScore: passingScore,
        isActive: isActive,
      );

      log('Practice test updated successfully: ${updatedTest.id}');

      // Update state immediately with the updated test
      state.whenData((tests) {
        final updatedTests = tests.map((test) {
          return test.id == testId ? updatedTest : test;
        }).toList();
        state = AsyncValue.data(updatedTests);
      });
    } catch (error, stackTrace) {
      log('Error updating practice test: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTest(String testId) async {
    try {
      log('Deleting practice test: $testId');
      await _service.deletePracticeTest(testId);

      log('Practice test deleted successfully: $testId');

      // Update state immediately by removing the deleted test
      state.whenData((tests) {
        final updatedTests = tests.where((test) => test.id != testId).toList();
        state = AsyncValue.data(updatedTests);
      });
    } catch (error, stackTrace) {
      log('Error deleting practice test: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    log('Refreshing practice tests');
    await _loadTests();
  }
}
