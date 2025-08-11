// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamCategory _$ExamCategoryFromJson(Map<String, dynamic> json) => ExamCategory(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  isActive: json['is_active'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ExamCategoryToJson(ExamCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
