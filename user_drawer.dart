import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserDrawer extends StatelessWidget {
  const UserDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.amber),
            accountName: Text(user?.userMetadata?['full_name'] ?? 'User'),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(
                user?.userMetadata?['avatar_url'] ?? 'https://via.placeholder.com/150',
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pushReplacementNamed(context, '/userDashboard'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Task History'),
            onTap: () {},
          ),
          ListTile(leading: const Icon(Icons.payment), title: const Text('Payouts'), onTap: () {}),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Lock', style: TextStyle(color: Colors.red)),
            onTap: () async {
              
              await _googleSignIn.signOut();
              await Supabase.instance.client.auth.signOut();
              Navigator.pushReplacementNamed(context, '/');
              
              
            },
          ),
        ],
      ),
    );
  }
}
