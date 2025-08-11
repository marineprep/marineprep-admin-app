import 'package:json_annotation/json_annotation.dart';

part 'roadmap.g.dart';

@JsonSerializable()
class RoadmapStep {
  final String id;
  final String title;
  final String description;
  final String examCategoryId;
  final String stepType; // 'video', 'notes', 'question_bank', 'practice_test'
  final String? resourceId; // ID of the related resource (topic, subject, etc.)
  final int orderIndex;
  final bool isRequired;
  final int estimatedMinutes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RoadmapStep({
    required this.id,
    required this.title,
    required this.description,
    required this.examCategoryId,
    required this.stepType,
    this.resourceId,
    required this.orderIndex,
    required this.isRequired,
    required this.estimatedMinutes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RoadmapStep.fromJson(Map<String, dynamic> json) =>
      _$RoadmapStepFromJson(json);

  Map<String, dynamic> toJson() => _$RoadmapStepToJson(this);

  RoadmapStep copyWith({
    String? id,
    String? title,
    String? description,
    String? examCategoryId,
    String? stepType,
    String? resourceId,
    int? orderIndex,
    bool? isRequired,
    int? estimatedMinutes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoadmapStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      examCategoryId: examCategoryId ?? this.examCategoryId,
      stepType: stepType ?? this.stepType,
      resourceId: resourceId ?? this.resourceId,
      orderIndex: orderIndex ?? this.orderIndex,
      isRequired: isRequired ?? this.isRequired,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class UserRoadmapProgress {
  final String id;
  final String userId;
  final String roadmapStepId;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserRoadmapProgress({
    required this.id,
    required this.userId,
    required this.roadmapStepId,
    required this.isCompleted,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserRoadmapProgress.fromJson(Map<String, dynamic> json) =>
      _$UserRoadmapProgressFromJson(json);

  Map<String, dynamic> toJson() => _$UserRoadmapProgressToJson(this);

  UserRoadmapProgress copyWith({
    String? id,
    String? userId,
    String? roadmapStepId,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserRoadmapProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      roadmapStepId: roadmapStepId ?? this.roadmapStepId,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
