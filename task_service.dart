import 'package:secure_view/pages/task_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskService {
  final supabase = Supabase.instance.client;

  Future<List<TaskModel>> fetchActiveTasks() async {
  final response = await supabase
      .from('tasks')
      .select('id, client_id, title, target_url, reward, active, created_at, clients(company_name)')
      .eq('active', true);

  final data = response as List<dynamic>;

  return data.map((task) {
    final client = task['clients'];
    return TaskModel(
      id: task['id'].toString(),
      clientId: task['client_id'].toString(),
      title: task['title'] as String,
      targetUrl: task['target_url'] as String,
      reward: task['reward'] as int,
      active: task['active'] as bool,
      createdAt: DateTime.parse(task['created_at'] as String),
      clientName: client != null ? client['company_name'] as String : 'Unknown Client',
    );
  }).toList();
}

}
