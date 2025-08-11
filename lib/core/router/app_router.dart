import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/pages/dashboard_page.dart';
import '../../features/subjects/pages/subjects_page.dart';
import '../../features/subjects/pages/subject_detail_page.dart';
import '../../features/questions/pages/question_bank_page.dart';
import '../../features/questions/pages/practice_test_page.dart';
import '../../features/roadmap/pages/roadmap_page.dart';

class AppRouter {
  static GoRouter get router => _router;

  static final _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/subjects',
        name: 'subjects',
        builder: (context, state) => const SubjectsPage(),
        routes: [
          GoRoute(
            path: '/:subjectId',
            name: 'subject-detail',
            builder: (context, state) {
              final subjectId = state.pathParameters['subjectId']!;
              return SubjectDetailPage(subjectId: subjectId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/question-bank',
        name: 'question-bank',
        builder: (context, state) => const QuestionBankPage(),
      ),
      GoRoute(
        path: '/practice-test',
        name: 'practice-test',
        builder: (context, state) => const PracticeTestPage(),
      ),
      GoRoute(
        path: '/roadmap',
        name: 'roadmap',
        builder: (context, state) => const RoadmapPage(),
      ),
    ],
  );
}
