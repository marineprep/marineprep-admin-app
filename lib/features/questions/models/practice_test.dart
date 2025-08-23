import 'package:json_annotation/json_annotation.dart';

part 'practice_test.g.dart';

@JsonSerializable()
class PracticeTest {
  final String id;
  final String name;
  final String description;
  @JsonKey(name: 'exam_category_id')
  final String examCategoryId;
  @JsonKey(name: 'total_questions')
  final int totalQuestions;
  @JsonKey(name: 'time_limit_minutes')
  final int? timeLimitMinutes;
  @JsonKey(name: 'passing_score')
  final double? passingScore;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const PracticeTest({
    required this.id,
    required this.name,
    required this.description,
    required this.examCategoryId,
    required this.totalQuestions,
    this.timeLimitMinutes,
    this.passingScore,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PracticeTest.fromJson(Map<String, dynamic> json) =>
      _$PracticeTestFromJson(json);

  Map<String, dynamic> toJson() => _$PracticeTestToJson(this);

  PracticeTest copyWith({
    String? id,
    String? name,
    String? description,
    String? examCategoryId,
    int? totalQuestions,
    int? timeLimitMinutes,
    double? passingScore,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PracticeTest(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      examCategoryId: examCategoryId ?? this.examCategoryId,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      passingScore: passingScore ?? this.passingScore,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class PracticeTestSubject {
  final String id;
  @JsonKey(name: 'practice_test_id')
  final String practiceTestId;
  @JsonKey(name: 'subject_id')
  final String subjectId;
  @JsonKey(name: 'question_count')
  final int questionCount;
  @JsonKey(name: 'order_index')
  final int orderIndex;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const PracticeTestSubject({
    required this.id,
    required this.practiceTestId,
    required this.subjectId,
    required this.questionCount,
    required this.orderIndex,
    required this.createdAt,
  });

  factory PracticeTestSubject.fromJson(Map<String, dynamic> json) =>
      _$PracticeTestSubjectFromJson(json);

  Map<String, dynamic> toJson() => _$PracticeTestSubjectToJson(this);
}
