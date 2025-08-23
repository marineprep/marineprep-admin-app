import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/subject.dart';
import '../services/subjects_service.dart';

// Service provider
final subjectsServiceProvider = Provider<SubjectsService>((ref) {
  return SubjectsService();
});

// Subjects list provider
final subjectsProvider =
    StateNotifierProvider.family<
      SubjectsNotifier,
      AsyncValue<List<Map<String, dynamic>>>,
      String
    >((ref, examCategoryName) {
      return SubjectsNotifier(
        ref.read(subjectsServiceProvider),
        examCategoryName,
      );
    });

// Individual subject provider
final subjectProvider = FutureProvider.family<Subject?, String>((
  ref,
  subjectId,
) async {
  final service = ref.read(subjectsServiceProvider);
  return await service.getSubjectById(subjectId);
});

class SubjectsNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final SubjectsService _service;
  final String _examCategoryName;
  String? _examCategoryId;

  SubjectsNotifier(this._service, this._examCategoryName)
    : super(const AsyncValue.loading()) {
    _initializeAndLoadSubjects();
  }

  Future<void> _initializeAndLoadSubjects() async {
    try {
      log(
        'Initializing SubjectsNotifier for exam category: $_examCategoryName',
      );

      // Get the exam category ID from the name
      _examCategoryId = await _service.getExamCategoryIdByName(
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

      // Load subjects with the resolved UUID
      await loadSubjects();
    } catch (error, stackTrace) {
      log('Error initializing SubjectsNotifier: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadSubjects() async {
    try {
      if (_examCategoryId == null) {
        log('Error: examCategoryId is null, cannot load subjects');
        state = AsyncValue.error(
          'Exam category ID not resolved',
          StackTrace.current,
        );
        return;
      }

      log('Loading subjects for exam category ID: $_examCategoryId');
      state = const AsyncValue.loading();
      final subjects = await _service.getSubjectsWithTopicsCount(
        _examCategoryId!,
      );
      state = AsyncValue.data(subjects);
      log('Successfully loaded ${subjects.length} subjects');
    } catch (error, stackTrace) {
      log('Error loading subjects: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addSubject({
    required String name,
    required String description,
    required bool isActive,
  }) async {
    try {
      if (_examCategoryId == null) {
        throw Exception('Exam category ID not resolved');
      }

      log('Adding subject: $name for exam category ID: $_examCategoryId');

      // Get the next available order index automatically
      final orderIndex = await _service.getNextOrderIndex(_examCategoryId!);
      log('Auto-assigned order index: $orderIndex');

      await _service.createSubject(
        name: name,
        description: description,
        examCategoryId: _examCategoryId!,
        orderIndex: orderIndex,
        isActive: isActive,
      );

      // Reload subjects list
      await loadSubjects();
      log('Successfully added subject: $name');
    } catch (error, stackTrace) {
      log('Error adding subject: $error');
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateSubject({
    required String id,
    required String name,
    required String description,
    required int orderIndex,
    required bool isActive,
  }) async {
    try {
      log('Updating subject: $name with ID: $id');

      // Get current subject to check if order index changed
      final currentSubject = await _service.getSubjectById(id);
      if (currentSubject == null) {
        throw Exception('Subject not found');
      }

      final currentOrderIndex = currentSubject.orderIndex;
      final orderIndexChanged = currentOrderIndex != orderIndex;

      // Update the subject with new data
      await _service.updateSubject(
        id: id,
        name: name,
        description: description,
        orderIndex: orderIndex,
        isActive: isActive,
      );

      // If order index changed, move the subject to the new position
      if (orderIndexChanged) {
        log(
          'Order index changed from $currentOrderIndex to $orderIndex, moving subject to new position',
        );
        await moveSubjectToPosition(id, orderIndex);
      } else {
        // Only reorder if order index didn't change (for other updates)
        await _service.reorderSubjects(_examCategoryId!);
        // Reload subjects list
        await loadSubjects();
      }

      log('Successfully updated subject: $name');
    } catch (error, stackTrace) {
      log('Error updating subject: $error');
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      log('Deleting subject with ID: $id');

      await _service.deleteSubject(id);

      // Reorder subjects to ensure sequential order after deletion
      await _service.reorderSubjects(_examCategoryId!);

      // Reload subjects list
      await loadSubjects();
      log('Successfully deleted subject with ID: $id');
    } catch (error, stackTrace) {
      log('Error deleting subject: $error');
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  void refresh() {
    log('Refreshing subjects');
    loadSubjects();
  }

  // Move subject to a specific position
  Future<void> moveSubjectToPosition(String subjectId, int newPosition) async {
    try {
      if (_examCategoryId == null) {
        throw Exception('Exam category ID not resolved');
      }

      log('Moving subject $subjectId to position $newPosition');

      await _service.moveSubjectToPosition(
        subjectId,
        newPosition,
        _examCategoryId!,
      );

      // Add a small delay to ensure database operations complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Reload to update the UI with the new order
      await loadSubjects();
      log('Successfully moved subject to position $newPosition');
    } catch (error) {
      log('Error moving subject: $error');
      rethrow;
    }
  }
}
