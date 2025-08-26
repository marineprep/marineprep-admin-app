import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../subjects/services/subjects_service.dart';
import '../../questions/services/questions_service.dart';

// Dashboard stats provider
final dashboardStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final subjectsService = SubjectsService();
  final questionsService = QuestionsService();

  try {
    // Fetch all counts in parallel
    final results = await Future.wait([
      subjectsService.getTotalSubjectsCount(),
      subjectsService.getTotalTopicsCount(),
      questionsService.getTotalQuestionsCount(),
      questionsService.getTotalPracticeTestsCount(),
    ]);

    return {
      'subjects': results[0],
      'topics': results[1],
      'questions': results[2],
      'practiceTests': results[3],
    };
  } catch (e) {
    // Return default values if there's an error
    return {'subjects': 0, 'topics': 0, 'questions': 0, 'practiceTests': 0};
  }
});
