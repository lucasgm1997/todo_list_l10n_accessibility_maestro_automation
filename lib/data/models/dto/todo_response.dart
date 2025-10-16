class TodoResponse {
  final String id;
  final String title;
  final bool completed;
  final String createdAt;

  TodoResponse({
    required this.id,
    required this.title,
    required this.completed,
    required this.createdAt,
  });

  factory TodoResponse.fromJson(Map<String, dynamic> json) {
    return TodoResponse(
      id: json['id'] as String,
      title: json['title'] as String,
      completed: json['completed'] as bool,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'createdAt': createdAt,
    };
  }
}
