import 'package:json_annotation/json_annotation.dart';

part 'subject.g.dart';

@JsonSerializable()
class Subject {
  final String id;
  final String name;
  final String description;
  @JsonKey(name: 'exam_category_id')
  final String examCategoryId;
  @JsonKey(name: 'order_index')
  final int orderIndex;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.examCategoryId,
    required this.orderIndex,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) =>
      _$SubjectFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectToJson(this);

  Subject copyWith({
    String? id,
    String? name,
    String? description,
    String? examCategoryId,
    int? orderIndex,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      examCategoryId: examCategoryId ?? this.examCategoryId,
      orderIndex: orderIndex ?? this.orderIndex,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
