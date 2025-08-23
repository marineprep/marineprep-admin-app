// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_test.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PracticeTest _$PracticeTestFromJson(Map<String, dynamic> json) => PracticeTest(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  examCategoryId: json['exam_category_id'] as String,
  totalQuestions: (json['total_questions'] as num).toInt(),
  timeLimitMinutes: (json['time_limit_minutes'] as num?)?.toInt(),
  passingScore: (json['passing_score'] as num?)?.toDouble(),
  isActive: json['is_active'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$PracticeTestToJson(PracticeTest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'exam_category_id': instance.examCategoryId,
      'total_questions': instance.totalQuestions,
      'time_limit_minutes': instance.timeLimitMinutes,
      'passing_score': instance.passingScore,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

PracticeTestSubject _$PracticeTestSubjectFromJson(Map<String, dynamic> json) =>
    PracticeTestSubject(
      id: json['id'] as String,
      practiceTestId: json['practice_test_id'] as String,
      subjectId: json['subject_id'] as String,
      questionCount: (json['question_count'] as num).toInt(),
      orderIndex: (json['order_index'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PracticeTestSubjectToJson(
  PracticeTestSubject instance,
) => <String, dynamic>{
  'id': instance.id,
  'practice_test_id': instance.practiceTestId,
  'subject_id': instance.subjectId,
  'question_count': instance.questionCount,
  'order_index': instance.orderIndex,
  'created_at': instance.createdAt.toIso8601String(),
};
