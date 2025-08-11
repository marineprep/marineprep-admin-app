// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
  id: json['id'] as String,
  questionText: json['questionText'] as String,
  questionImageUrl: json['questionImageUrl'] as String?,
  subjectId: json['subjectId'] as String,
  sectionType: json['sectionType'] as String?,
  answerChoices: (json['answerChoices'] as List<dynamic>)
      .map((e) => AnswerChoice.fromJson(e as Map<String, dynamic>))
      .toList(),
  correctAnswer: json['correctAnswer'] as String,
  explanationText: json['explanationText'] as String,
  explanationImageUrl: json['explanationImageUrl'] as String?,
  difficultyLevel: (json['difficultyLevel'] as num).toInt(),
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
  'id': instance.id,
  'questionText': instance.questionText,
  'questionImageUrl': instance.questionImageUrl,
  'subjectId': instance.subjectId,
  'sectionType': instance.sectionType,
  'answerChoices': instance.answerChoices,
  'correctAnswer': instance.correctAnswer,
  'explanationText': instance.explanationText,
  'explanationImageUrl': instance.explanationImageUrl,
  'difficultyLevel': instance.difficultyLevel,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

AnswerChoice _$AnswerChoiceFromJson(Map<String, dynamic> json) => AnswerChoice(
  label: json['label'] as String,
  text: json['text'] as String,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$AnswerChoiceToJson(AnswerChoice instance) =>
    <String, dynamic>{
      'label': instance.label,
      'text': instance.text,
      'imageUrl': instance.imageUrl,
    };
