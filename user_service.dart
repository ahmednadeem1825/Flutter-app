import 'package:secure_view/pages/user/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> createUserIfNotExist({
    required String id,
    required String fullName,
    required String email,
    String? profileImage,
  }) async {
    final response = await supabase.from('users').select().eq('id', id).maybeSingle();

    if (response == null) {
      final insertResponse = await supabase.from('users').insert({
        'id': id,
        'full_name': fullName,
        'email': email,
        'profile_image': profileImage,
        'is_active': true,
      });
      if (insertResponse.error != null) {
        throw Exception();
      }
    }
  }

  Future<void> addUser(User user) async {
    final response = await supabase.from('users').upsert({
      'id': user.id,
      'full_name': user.userMetadata?['full_name'] ?? user.email ?? '',
      'email': user.email,
      'profile_image': user.userMetadata?['picture'] ?? '',
      'is_active': true,
    }, onConflict: 'id');

    return response;
  }

  Future<void> addUser1(String name, String email, String profileImage) async {
    await supabase.from('users').insert({
      'full_name': name,
      'email': email,
      'profile_image': profileImage,
    });
  }

 Future<Map<String, dynamic>?> fetchUserData(String email) async {
  return await supabase
      .from('users')
      .select()
      .eq('email', email)
      .maybeSingle(); 
}


  Future<void> updateUserCredits(String userId, int currentCredits, int rewardAmount) async {
    await supabase
        .from('users')
        .update({
          'credits': currentCredits + rewardAmount,
          'payments': currentCredits + rewardAmount,
        })
        .eq('id', userId);
  }

  Future<void> addClient(String companyName, String email, String websiteUrl) async {
    await supabase.from('clients').insert({
      'company_name': companyName,
      'contact_email': email,
      'website_url': websiteUrl,
    });
  }

  Future<Map<String, dynamic>?> getUserbyId(String id) async {
    final response = await supabase.from('users').select().eq('id', id).single();
    return response;
  }
}
