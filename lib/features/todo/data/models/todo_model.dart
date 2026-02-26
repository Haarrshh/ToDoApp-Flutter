class TodoModel {
  TodoModel({
    required this.id,
    required this.title,
    this.completed = false,
    this.userId,
    this.remoteId,
    this.createdAt,
    this.updatedAt,
    this.syncPending = false,
  });

  final int id;
  final int? remoteId;
  final String title;
  final bool completed;
  final int? userId;
  final int? createdAt;
  final int? updatedAt;
  final bool syncPending;

  static bool _parseBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is int) return v != 0;
    return false;
  }

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as int? ?? 0,
      remoteId: json['remote_id'] as int? ?? json['id'] as int?,
      title: json['title'] as String? ?? '',
      completed: _parseBool(json['completed']),
      userId: json['userId'] as int? ?? json['user_id'] as int?,
      createdAt: json['created_at'] as int?,
      updatedAt: json['updated_at'] as int?,
      syncPending: _parseBool(json['sync_pending']),
    );
  }

  factory TodoModel.fromApi(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as int? ?? 0,
      remoteId: json['id'] as int?,
      title: json['title'] as String? ?? '',
      completed: _parseBool(json['completed']),
      userId: json['userId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'remote_id': remoteId,
      'title': title,
      'completed': completed ? 1 : 0,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'sync_pending': syncPending ? 1 : 0,
    };
  }

  Map<String, dynamic> toApi() => {
        'title': title,
        'completed': completed,
        if (userId != null) 'userId': userId,
      };

  TodoModel copyWith({
    int? id,
    int? remoteId,
    String? title,
    bool? completed,
    int? userId,
    int? createdAt,
    int? updatedAt,
    bool? syncPending,
  }) {
    return TodoModel(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncPending: syncPending ?? this.syncPending,
    );
  }
}
