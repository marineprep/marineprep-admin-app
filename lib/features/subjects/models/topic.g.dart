// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Topic _$TopicFromJson(Map<String, dynamic> json) => Topic(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  subjectId: json['subject_id'] as String,
  orderIndex: (json['order_index'] as num).toInt(),
  videos: (json['videos'] as List<dynamic>)
      .map((e) => VideoFile.fromJson(e as Map<String, dynamic>))
      .toList(),
  notesUrl: json['notes_url'] as String?,
  notesFileName: json['notes_file_name'] as String?,
  isActive: json['is_active'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$TopicToJson(Topic instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'subject_id': instance.subjectId,
  'order_index': instance.orderIndex,
  'videos': instance.videos,
  'notes_url': instance.notesUrl,
  'notes_file_name': instance.notesFileName,
  'is_active': instance.isActive,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

VideoFile _$VideoFileFromJson(Map<String, dynamic> json) => VideoFile(
  url: json['url'] as String,
  fileName: json['file_name'] as String,
  fileSize: (json['file_size'] as num).toInt(),
);

Map<String, dynamic> _$VideoFileToJson(VideoFile instance) => <String, dynamic>{
  'url': instance.url,
  'file_name': instance.fileName,
  'file_size': instance.fileSize,
};
