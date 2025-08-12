import 'package:json_annotation/json_annotation.dart';

part 'question.g.dart';

@JsonSerializable()
class Question {
  final String id;
  @JsonKey(name: 'question_text')
  final String questionText;
  @JsonKey(name: 'question_image_url')
  final String? questionImageUrl;
  @JsonKey(name: 'subject_id')
  final String subjectId;
  @JsonKey(name: 'section_type')
  final String sectionType; // 'question_bank' or 'practice_test'
  @JsonKey(name: 'answer_choices')
  final List<AnswerChoice> answerChoices;
  @JsonKey(name: 'correct_answer')
  final String correctAnswer; // 'A', 'B', 'C', 'D'
  @JsonKey(name: 'explanation_text')
  final String explanationText;
  @JsonKey(name: 'explanation_image_url')
  final String? explanationImageUrl;
  @JsonKey(name: 'difficulty_level')
  final int difficultyLevel; // 1-5
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Question({
    required this.id,
    required this.questionText,
    this.questionImageUrl,
    required this.subjectId,
    required this.sectionType,
    required this.answerChoices,
    required this.correctAnswer,
    required this.explanationText,
    this.explanationImageUrl,
    required this.difficultyLevel,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  Question copyWith({
    String? id,
    String? questionText,
    String? questionImageUrl,
    String? subjectId,
    String? sectionType,
    List<AnswerChoice>? answerChoices,
    String? correctAnswer,
    String? explanationText,
    String? explanationImageUrl,
    int? difficultyLevel,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Question(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      questionImageUrl: questionImageUrl ?? this.questionImageUrl,
      subjectId: subjectId ?? this.subjectId,
      sectionType: sectionType ?? this.sectionType,
      answerChoices: answerChoices ?? this.answerChoices,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanationText: explanationText ?? this.explanationText,
      explanationImageUrl: explanationImageUrl ?? this.explanationImageUrl,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class AnswerChoice {
  final String label; // 'A', 'B', 'C', 'D'
  final String text;
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  const AnswerChoice({
    required this.label,
    required this.text,
    this.imageUrl,
  });

  factory AnswerChoice.fromJson(Map<String, dynamic> json) =>
      _$AnswerChoiceFromJson(json);

  Map<String, dynamic> toJson() => _$AnswerChoiceToJson(this);

  AnswerChoice copyWith({
    String? label,
    String? text,
    String? imageUrl,
  }) {
    return AnswerChoice(
      label: label ?? this.label,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
