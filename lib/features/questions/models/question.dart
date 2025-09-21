import 'package:flutter_quill/quill_delta.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';

part 'question.g.dart';

@JsonSerializable()
class Question {
  final String id;

  // Legacy text field - for backwards compatibility
  @JsonKey(name: 'question_text')
  final String? questionText;

  // New rich text field stored as Quill delta JSON
  @JsonKey(
    name: 'question_content',
    fromJson: _deltaFromJson,
    toJson: _deltaToJson,
  )
  final Delta? questionContent;

  @JsonKey(name: 'question_image_url')
  final String? questionImageUrl;
  @JsonKey(name: 'subject_id')
  final String subjectId;
  @JsonKey(name: 'topic_id')
  final String? topicId;
  @JsonKey(name: 'section_type')
  final String sectionType; // 'question_bank' or 'practice_test'
  @JsonKey(name: 'answer_choices')
  final List<AnswerChoice> answerChoices;
  @JsonKey(name: 'correct_answer')
  final String correctAnswer; // 'A', 'B', 'C', 'D'

  // Legacy explanation text field - for backwards compatibility
  @JsonKey(name: 'explanation_text')
  final String? explanationText;

  // New rich text explanation field stored as Quill delta JSON
  @JsonKey(
    name: 'explanation_content',
    fromJson: _deltaFromJson,
    toJson: _deltaToJson,
  )
  final Delta? explanationContent;

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
    this.questionText,
    this.questionContent,
    this.questionImageUrl,
    required this.subjectId,
    this.topicId,
    required this.sectionType,
    required this.answerChoices,
    required this.correctAnswer,
    this.explanationText,
    this.explanationContent,
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
    Delta? questionContent,
    String? questionImageUrl,
    String? subjectId,
    String? topicId,
    String? sectionType,
    List<AnswerChoice>? answerChoices,
    String? correctAnswer,
    String? explanationText,
    Delta? explanationContent,
    String? explanationImageUrl,
    int? difficultyLevel,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Question(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      questionContent: questionContent ?? this.questionContent,
      questionImageUrl: questionImageUrl ?? this.questionImageUrl,
      subjectId: subjectId ?? this.subjectId,
      topicId: topicId ?? this.topicId,
      sectionType: sectionType ?? this.sectionType,
      answerChoices: answerChoices ?? this.answerChoices,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanationText: explanationText ?? this.explanationText,
      explanationContent: explanationContent ?? this.explanationContent,
      explanationImageUrl: explanationImageUrl ?? this.explanationImageUrl,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods for getting the right content
  String getQuestionText() {
    if (questionContent != null) {
      return Document.fromDelta(questionContent!).toPlainText();
    }
    return questionText ?? '';
  }

  String getExplanationText() {
    if (explanationContent != null) {
      return Document.fromDelta(explanationContent!).toPlainText();
    }
    return explanationText ?? '';
  }

  Delta getQuestionDelta() {
    if (questionContent != null) {
      return questionContent!;
    }
    // Convert plain text to Delta for legacy data
    return Delta()..insert(questionText ?? '');
  }

  Delta getExplanationDelta() {
    if (explanationContent != null) {
      return explanationContent!;
    }
    // Convert plain text to Delta for legacy data
    return Delta()..insert(explanationText ?? '');
  }
}

// Helper functions for JSON serialization/deserialization of Delta
Delta? _deltaFromJson(dynamic json) {
  if (json == null) return null;
  if (json is String) {
    try {
      final decoded = jsonDecode(json);
      return Delta.fromJson(decoded as List);
    } catch (e) {
      return null;
    }
  }
  if (json is Map<String, dynamic>) {
    try {
      return Delta.fromJson(json['ops'] as List? ?? []);
    } catch (e) {
      return null;
    }
  }
  return null;
}

dynamic _deltaToJson(Delta? delta) {
  if (delta == null) return null;
  return jsonEncode(delta.toJson());
}

@JsonSerializable()
class AnswerChoice {
  final String label; // 'A', 'B', 'C', 'D'

  // Legacy text field - for backwards compatibility
  final String text;

  // New rich text field stored as Quill delta JSON
  @JsonKey(name: 'content', fromJson: _deltaFromJson, toJson: _deltaToJson)
  final Delta? content;

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  const AnswerChoice({
    required this.label,
    required this.text,
    this.content,
    this.imageUrl,
  });

  factory AnswerChoice.fromJson(Map<String, dynamic> json) =>
      _$AnswerChoiceFromJson(json);

  Map<String, dynamic> toJson() => _$AnswerChoiceToJson(this);

  AnswerChoice copyWith({
    String? label,
    String? text,
    Delta? content,
    String? imageUrl,
  }) {
    return AnswerChoice(
      label: label ?? this.label,
      text: text ?? this.text,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // Helper methods for getting the right content
  String getText() {
    if (content != null) {
      return Document.fromDelta(content!).toPlainText();
    }
    return text;
  }

  Delta getDelta() {
    if (content != null) {
      return content!;
    }
    // Convert plain text to Delta for legacy data
    return Delta()..insert(text);
  }
}
