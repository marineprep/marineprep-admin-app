import 'package:json_annotation/json_annotation.dart';

part 'exam_category.g.dart';

@JsonSerializable()
class ExamCategory {
  final String id;
  final String name;
  final String description;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const ExamCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExamCategory.fromJson(Map<String, dynamic> json) =>
      _$ExamCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$ExamCategoryToJson(this);

  ExamCategory copyWith({
    String? id,
    String? name,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExamCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
