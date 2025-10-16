class Todo {
  final String id;
  final String title;
  final bool completed;
  final bool isPending;
  final DateTime createdAt;

  const Todo({
    required this.id,
    required this.title,
    required this.completed,
    this.isPending = false,
    required this.createdAt,
  });

  Todo copyWith({
    String? id,
    String? title,
    bool? completed,
    bool? isPending,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      isPending: isPending ?? this.isPending,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
