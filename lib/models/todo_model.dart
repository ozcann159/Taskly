import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../utils/timestamp_converter.dart';

part 'todo_model.g.dart';

@JsonSerializable()
class Todo {
  final String id;
  final String title;
  final String description;

  @JsonKey(fromJson: _fromJsonTimestamp, toJson: _toJsonTimestamp)
  final Timestamp createdAt;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory Todo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Todo(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: const TimestampConverter().fromJson(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'createdAt': const TimestampConverter().toJson(createdAt),
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
  Map<String, dynamic> toJson() => _$TodoToJson(this);

  static Timestamp _fromJsonTimestamp(Map<String, dynamic> json) {
    return const TimestampConverter().fromJson(json);
  }

  static Map<String, dynamic> _toJsonTimestamp(Timestamp timestamp) {
    return const TimestampConverter().toJson(timestamp);
  }
}
