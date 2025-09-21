// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
  id: json['id'] as String,
  questionText: json['question_text'] as String?,
  questionContent: _deltaFromJson(json['question_content']),
  questionImageUrl: json['question_image_url'] as String?,
  subjectId: json['subject_id'] as String,
  topicId: json['topic_id'] as String?,
  sectionType: json['section_type'] as String,
  answerChoices: (json['answer_choices'] as List<dynamic>)
      .map((e) => AnswerChoice.fromJson(e as Map<String, dynamic>))
      .toList(),
  correctAnswer: json['correct_answer'] as String,
  explanationText: json['explanation_text'] as String?,
  explanationContent: _deltaFromJson(json['explanation_content']),
  explanationImageUrl: json['explanation_image_url'] as String?,
  difficultyLevel: (json['difficulty_level'] as num).toInt(),
  isActive: json['is_active'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
  'id': instance.id,
  'question_text': instance.questionText,
  'question_content': _deltaToJson(instance.questionContent),
  'question_image_url': instance.questionImageUrl,
  'subject_id': instance.subjectId,
  'topic_id': instance.topicId,
  'section_type': instance.sectionType,
  'answer_choices': instance.answerChoices,
  'correct_answer': instance.correctAnswer,
  'explanation_text': instance.explanationText,
  'explanation_content': _deltaToJson(instance.explanationContent),
  'explanation_image_url': instance.explanationImageUrl,
  'difficulty_level': instance.difficultyLevel,
  'is_active': instance.isActive,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

AnswerChoice _$AnswerChoiceFromJson(Map<String, dynamic> json) => AnswerChoice(
  label: json['label'] as String,
  text: json['text'] as String,
  content: _deltaFromJson(json['content']),
  imageUrl: json['image_url'] as String?,
);

Map<String, dynamic> _$AnswerChoiceToJson(AnswerChoice instance) =>
    <String, dynamic>{
      'label': instance.label,
      'text': instance.text,
      'content': _deltaToJson(instance.content),
      'image_url': instance.imageUrl,
    };
