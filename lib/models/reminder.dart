// reminder.dart
class Reminder {
  int? id;
  String title;
  String description;

  Reminder({required this.id, required this.title, required this.description});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }
}
