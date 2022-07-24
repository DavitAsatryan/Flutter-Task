class TaskModel {
  int? id;
  String title;
  String description;
  String completed;
  String active;

  TaskModel(
      {this.id,
      required this.title,
      required this.description,
      required this.completed,
      required this.active});

  factory TaskModel.fromMap(Map<String, dynamic> json) => TaskModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        completed: json['completed'],
        active: json['active'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      "description": description,
      "completed": completed,
      "active": active,
    };
  }
}
