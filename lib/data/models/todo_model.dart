import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'todo_model.g.dart';

enum TodoPriority { low, medium, high }

enum TodoCategory { work, personal, shopping, health, other }

@JsonSerializable()
class Todo {
  final String? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final TodoPriority priority;
  final TodoCategory category;
  final String userId;

  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime createdAt;

  Todo({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.priority,
    required this.category,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'priority': priority.toString(),
      'category': category.toString(),
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Todo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Timestamp kontrolü ekleyin
    Timestamp? dueDateTimestamp = data['dueDate'];
    Timestamp? createdAtTimestamp = data['createdAt'];

    return Todo(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate:
          dueDateTimestamp != null ? dueDateTimestamp.toDate() : DateTime.now(),
      isCompleted: data['isCompleted'] ?? false,
      priority: TodoPriority.values.firstWhere(
        (e) => e.toString() == data['priority'],
        orElse: () => TodoPriority.low,
      ),
      category: TodoCategory.values.firstWhere(
        (e) => e.toString() == data['category'],
        orElse: () => TodoCategory.other,
      ),
      userId: data['userId'] ?? '',
      createdAt:
          createdAtTimestamp != null
              ? createdAtTimestamp.toDate()
              : DateTime.now(),
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
  Map<String, dynamic> toJson() => _$TodoToJson(this);

  static DateTime _dateTimeFromTimestamp(Timestamp timestamp) =>
      timestamp.toDate();
  static Timestamp _dateTimeToTimestamp(DateTime dateTime) =>
      Timestamp.fromDate(dateTime);
}
