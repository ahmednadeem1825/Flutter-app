import 'package:flutter/material.dart';
import 'package:secure_view/pages/user/user_model.dart';
import 'package:secure_view/pages/user/user_provider.dart';
import 'package:secure_view/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  final db = UserService();
  bool _isLoading = true;
  bool _hasData = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      final userDataMap = await db.fetchUserData(user.email ?? '');
      if (userDataMap != null) {
        final userModel = UserModel.fromMap(userDataMap);
        provider.setUser(userModel);
        setState(() => _hasData = true);
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.08,
              vertical: screenSize.height * 0.05,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.network_check, color: Colors.black87, size: 80),
                const SizedBox(height: 16),
                const Text(
                  "Select Your Role",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Tell us how you’d like to continue.\nChoose your role to get the right experience.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Roboto', fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 40),

                GestureDetector(
                  onTap: () async {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user != null) {
                      await db.addUser(user);
                    }
                    if (!mounted) return;
                    Navigator.pushReplacementNamed(context, '/userDashboard');
                  },
                  child: _buildRoleCard(
                    icon: Icons.person,
                    title: "Continue as User",
                    description:
                        "Earn credits by sharing bandwidth\nand visiting websites ethically.",
                  ),
                ),

                const SizedBox(height: 25),

                GestureDetector(
                  onTap: () {
                    //Navigator.pushReplacementNamed(context, '/clientDashboard');
                  },
                  child: _buildRoleCard(
                    icon: Icons.business_center,
                    title: "Continue as Client",
                    description: "Drive real user visits securely\nand track verified traffic.",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        children: [
          Icon(icon, size: 50, color: Colors.amber.shade600),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
