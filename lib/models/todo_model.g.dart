// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Todo _$TodoFromJson(Map<String, dynamic> json) => Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt:
          Todo._fromJsonTimestamp(json['createdAt'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TodoToJson(Todo instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'createdAt': Todo._toJsonTimestamp(instance.createdAt),
    };
