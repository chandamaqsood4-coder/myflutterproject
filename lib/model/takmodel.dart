// class Task {
//   String title;
//   String description;
//   bool isCompleted;

//   Task({required this.title, this.description = '', this.isCompleted = false});
// }
class Task {
  int? id;
  String title;
  String description;
  String category;
  bool completed;
  DateTime? dueDate;
  bool reminder;

  Task({
    this.id,
    required this.title,
    this.description = '',
    this.category = 'Personal',
    this.completed = false,
    this.dueDate,
    this.reminder = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'completed': completed ? 1 : 0,
      'dueDate': dueDate?.toIso8601String(),
      'reminder': reminder ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Personal',
      completed: map['completed'] == 1,
      dueDate: map['dueDate'] == null
          ? null
          : DateTime.tryParse(map['dueDate'].toString()),
      reminder: map['reminder'] == 1,
    );
  }
}
