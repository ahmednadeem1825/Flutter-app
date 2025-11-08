import 'package:secure_view/pages/user/live_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LiveSessionService {
  final supabase = Supabase.instance.client;

  Future<List<LiveSessionModel>> fetchActiveSessions() async {
    final response = await supabase
        .from('live_sessions')
        .select('id, website, started_at, active, clients(company_name)')
        .eq('active', true)
        .order('started_at', ascending: false)
        .limit(5);

    final data = response as List<dynamic>;
    return data.map((e) => LiveSessionModel.fromMap(e)).toList();
  }
}
