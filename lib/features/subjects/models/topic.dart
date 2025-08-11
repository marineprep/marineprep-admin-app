import 'package:json_annotation/json_annotation.dart';

part 'topic.g.dart';

@JsonSerializable()
class Topic {
  final String id;
  final String name;
  final String description;
  @JsonKey(name: 'subject_id')
  final String subjectId;
  @JsonKey(name: 'order_index')
  final int orderIndex;
  final List<VideoFile> videos;
  @JsonKey(name: 'notes_url')
  final String? notesUrl;
  @JsonKey(name: 'notes_file_name')
  final String? notesFileName;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Topic({
    required this.id,
    required this.name,
    required this.description,
    required this.subjectId,
    required this.orderIndex,
    required this.videos,
    this.notesUrl,
    this.notesFileName,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);

  Map<String, dynamic> toJson() => _$TopicToJson(this);

  Topic copyWith({
    String? id,
    String? name,
    String? description,
    String? subjectId,
    int? orderIndex,
    List<VideoFile>? videos,
    String? notesUrl,
    String? notesFileName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Topic(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      orderIndex: orderIndex ?? this.orderIndex,
      videos: videos ?? this.videos,
      notesUrl: notesUrl ?? this.notesUrl,
      notesFileName: notesFileName ?? this.notesFileName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class VideoFile {
  final String url;
  @JsonKey(name: 'file_name')
  final String fileName;
  @JsonKey(name: 'file_size')
  final int fileSize;

  const VideoFile({
    required this.url,
    required this.fileName,
    required this.fileSize,
  });

  factory VideoFile.fromJson(Map<String, dynamic> json) =>
      _$VideoFileFromJson(json);

  Map<String, dynamic> toJson() => _$VideoFileToJson(this);

  VideoFile copyWith({
    String? url,
    String? fileName,
    int? fileSize,
  }) {
    return VideoFile(
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
    );
  }
}
