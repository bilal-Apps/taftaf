class Schedule {
  final int id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String description;
  final bool isCompleted;
  final String? location;
  final String? category;
  final List<String>? tags;
  final String? color;
  final String? reminder;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int userId;

  Schedule({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.userId,
    this.isCompleted = false,
    this.location,
    this.category,
    this.tags,
    this.color,
    this.reminder,
    this.createdAt,
    this.updatedAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as int,
      title: json['title'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      description: json['description'] as String,
      userId: json['userId'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      location: json['location'] as String?,
      category: json['category'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      color: json['color'] as String?,
      reminder: json['reminder'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'description': description,
      'userId': userId,
      'isCompleted': isCompleted,
      'location': location,
      'category': category,
      'tags': tags,
      'color': color,
      'reminder': reminder,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Schedule copyWith({
    int? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? description,
    bool? isCompleted,
    String? location,
    String? category,
    List<String>? tags,
    String? color,
    String? reminder,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? userId,
  }) {
    return Schedule(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      isCompleted: isCompleted ?? this.isCompleted,
      location: location ?? this.location,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      color: color ?? this.color,
      reminder: reminder ?? this.reminder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 