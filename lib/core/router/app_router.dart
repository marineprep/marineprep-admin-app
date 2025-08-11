import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/pages/dashboard_page.dart';
import '../../features/subjects/pages/subjects_page.dart';
import '../../features/subjects/pages/subject_detail_page.dart';
import '../../features/questions/pages/question_bank_page.dart';
import '../../features/questions/pages/practice_test_page.dart';
import '../../features/roadmap/pages/roadmap_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/signup_page.dart';
import '../../features/auth/widgets/auth_wrapper.dart';

class AppRouter {
  static GoRouter get router => _router;

  static final _router = GoRouter(
    initialLocation: '/auth/login',
    routes: [
      // Auth routes (public)
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/signup',
        name: 'signup',
        builder: (context, state) => const SignupPage(),
      ),
      
      // Protected routes (require authentication)
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (context, state) => const AuthWrapper(
          child: DashboardPage(),
        ),
      ),
      GoRoute(
        path: '/subjects',
        name: 'subjects',
        builder: (context, state) => const AuthWrapper(
          child: SubjectsPage(),
        ),
        routes: [
          GoRoute(
            path: '/:subjectId',
            name: 'subject-detail',
            builder: (context, state) {
              final subjectId = state.pathParameters['subjectId']!;
              return AuthWrapper(
                child: SubjectDetailPage(subjectId: subjectId),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/question-bank',
        name: 'question-bank',
        builder: (context, state) => const AuthWrapper(
          child: QuestionBankPage(),
        ),
      ),
      GoRoute(
        path: '/practice-test',
        name: 'practice-test',
        builder: (context, state) => const AuthWrapper(
          child: PracticeTestPage(),
        ),
      ),
      GoRoute(
        path: '/roadmap',
        name: 'roadmap',
        builder: (context, state) => const AuthWrapper(
          child: RoadmapPage(),
        ),
      ),
    ],
  );
}
