enum TaskType {
  regular,
  email,
  phone,
}

class Task {
  String title;
  String? description;
  DateTime dueDate;
  bool status;
  String? phone;
  String? email;
  TaskType type;

  Task({
    required this.title,
    this.description,
    required this.dueDate,
    this.status = false,
    this.phone,
    this.email,
    this.type = TaskType.regular,
  });

  String toJsonString() {
    String descriptionValue = description ?? 'null';
    String phoneValue = phone ?? 'null';
    String emailValue = email ?? 'null';
    return '$title||$descriptionValue||${dueDate.toString()}||$status||$phoneValue||$emailValue||${type.index}';
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      status: json['status'],
      phone: json['phone'],
      email: json['email'],
      type: TaskType.values[json['type']],
    );
  }
}
