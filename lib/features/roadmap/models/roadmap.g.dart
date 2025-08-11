// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roadmap.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoadmapStep _$RoadmapStepFromJson(Map<String, dynamic> json) => RoadmapStep(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  examCategoryId: json['examCategoryId'] as String,
  stepType: json['stepType'] as String,
  resourceId: json['resourceId'] as String?,
  orderIndex: (json['orderIndex'] as num).toInt(),
  isRequired: json['isRequired'] as bool,
  estimatedMinutes: (json['estimatedMinutes'] as num).toInt(),
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$RoadmapStepToJson(RoadmapStep instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'examCategoryId': instance.examCategoryId,
      'stepType': instance.stepType,
      'resourceId': instance.resourceId,
      'orderIndex': instance.orderIndex,
      'isRequired': instance.isRequired,
      'estimatedMinutes': instance.estimatedMinutes,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

UserRoadmapProgress _$UserRoadmapProgressFromJson(Map<String, dynamic> json) =>
    UserRoadmapProgress(
      id: json['id'] as String,
      userId: json['userId'] as String,
      roadmapStepId: json['roadmapStepId'] as String,
      isCompleted: json['isCompleted'] as bool,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserRoadmapProgressToJson(
  UserRoadmapProgress instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'roadmapStepId': instance.roadmapStepId,
  'isCompleted': instance.isCompleted,
  'completedAt': instance.completedAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
