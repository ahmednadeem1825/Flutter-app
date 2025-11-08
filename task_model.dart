// task_model.dart

class TaskModel {
  final String id;
  final String clientId;
  final String title;
  final String targetUrl;
  final int reward;
  final bool active;
  final DateTime createdAt;
  final String clientName;

  TaskModel({
    required this.id,
    required this.clientId,
    required this.title,
    required this.targetUrl,
    required this.reward,
    required this.active,
    required this.createdAt,
    required this.clientName,
  });

  /// Factory method to create a TaskModel from a Supabase JSON response
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final client = json['clients'];
    return TaskModel(
      id: json['id'].toString(),
      clientId: json['client_id'].toString(),
      title: json['title'] as String,
      targetUrl: json['target_url'] as String,
      reward: json['reward'] as int,
      active: json['active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      clientName: client != null ? client['company_name'] as String : 'Unknown Client',
    );
  }

  /// Optional: Convert a TaskModel to a Map (useful for inserts/updates)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'title': title,
      'target_url': targetUrl,
      'reward': reward,
      'active': active,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Optional: List<TaskModel> from a list of maps
  static List<TaskModel> listFromJson(List<dynamic> data) {
    return data.map((task) => TaskModel.fromJson(task)).toList();
  }
}
