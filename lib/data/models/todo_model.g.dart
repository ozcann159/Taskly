// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Todo _$TodoFromJson(Map<String, dynamic> json) => Todo(
  id: json['id'] as String?,
  title: json['title'] as String,
  description: json['description'] as String,
  dueDate: DateTime.parse(json['dueDate'] as String),
  isCompleted: json['isCompleted'] as bool? ?? false,
  priority: $enumDecode(_$TodoPriorityEnumMap, json['priority']),
  category: $enumDecode(_$TodoCategoryEnumMap, json['category']),
  userId: json['userId'] as String,
  createdAt: Todo._dateTimeFromTimestamp(json['createdAt'] as Timestamp),
);

Map<String, dynamic> _$TodoToJson(Todo instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'dueDate': instance.dueDate.toIso8601String(),
  'isCompleted': instance.isCompleted,
  'priority': _$TodoPriorityEnumMap[instance.priority]!,
  'category': _$TodoCategoryEnumMap[instance.category]!,
  'userId': instance.userId,
  'createdAt': Todo._dateTimeToTimestamp(instance.createdAt),
};

const _$TodoPriorityEnumMap = {
  TodoPriority.low: 'low',
  TodoPriority.medium: 'medium',
  TodoPriority.high: 'high',
};

const _$TodoCategoryEnumMap = {
  TodoCategory.work: 'work',
  TodoCategory.personal: 'personal',
  TodoCategory.shopping: 'shopping',
  TodoCategory.health: 'health',
  TodoCategory.other: 'other',
};
