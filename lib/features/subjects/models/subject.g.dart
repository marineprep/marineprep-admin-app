// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subject _$SubjectFromJson(Map<String, dynamic> json) => Subject(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  examCategoryId: json['exam_category_id'] as String,
  orderIndex: (json['order_index'] as num).toInt(),
  isActive: json['is_active'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'exam_category_id': instance.examCategoryId,
  'order_index': instance.orderIndex,
  'is_active': instance.isActive,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
