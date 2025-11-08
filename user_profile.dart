import 'package:flutter/material.dart';
import 'package:secure_view/pages/user/dashboard_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:secure_view/pages/user/user_drawer.dart';
import 'package:secure_view/pages/user/user_task_screen.dart';
import 'package:secure_view/pages/user/user_webview.dart';
import 'package:secure_view/pages/user/user_model.dart';
import 'package:secure_view/services/user_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserService _db = UserService();
  UserModel? user;
  int _selectedIndex = 4;
  void _onItemTapped(int index) async {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreenUser()));
        break;

      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const UserTasksScreen()));
        break;

      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TaskWebView(task: null,)));
        break;

      case 3:
        Navigator.pushNamed(context, '/profileUser');
        break;
    }
  }
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

 Future<void> _loadUser() async {
  final current = Supabase.instance.client.auth.currentUser;
  if (current == null) return;

  final fetchedData = await _db.fetchUserData(current.email!);
  if (mounted) {
    setState(() => user = 
        fetchedData != null ? UserModel.fromMap(fetchedData) : null
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final isLandscape = screen.width > screen.height;

    Widget buildCard(String title, Widget child) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 8,
              offset: Offset(1, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      );
    }

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final infoTextStyle = const TextStyle(
      fontSize: 16,
      color: Color(0xFF111827),
      fontWeight: FontWeight.w500,
    );

    final labelTextStyle = const TextStyle(
      fontSize: 12,
      color: Colors.grey,
      fontWeight: FontWeight.w600,
    );

    final profileHeader = buildCard(
      "",
      Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: user!.profileImage != null
                ? NetworkImage(user!.profileImage!)
                : const AssetImage('assets/default_avatar.png') as ImageProvider,
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user!.fullName, style: infoTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(user!.email, style: labelTextStyle),
            ],
          ),
        ],
      ),
    );

    final metrics = buildCard(
      "Account Metrics",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricRow("Credits", "${user!.credits}", infoTextStyle, labelTextStyle),
          const Divider(),
          _buildMetricRow("Weekly Check-ins", "${user!.weeklyCheckins}", infoTextStyle, labelTextStyle),
          const Divider(),
          _buildMetricRow("Hours Spent", "${user!.hoursSpent.toStringAsFixed(1)} hrs", infoTextStyle, labelTextStyle),
          const Divider(),
          _buildMetricRow("Payments", "Rs. ${user!.payments.toStringAsFixed(2)}", infoTextStyle, labelTextStyle),
        ],
      ),
    );

    final created = buildCard(
      "Account Info",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Account Created:", style: labelTextStyle),
          const SizedBox(height: 4),
          Text(
            "${user!.createdAt.toLocal()}",
            style: infoTextStyle,
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
      ),
      drawer: UserDrawer(),
      bottomNavigationBar: _BottomBar(selectedIndex: _selectedIndex, onTap: _onItemTapped),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isLandscape
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: Column(children: [profileHeader, const SizedBox(height: 16), metrics])),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: created),
                  ],
                )
              : Column(
                  children: [
                    profileHeader,
                    const SizedBox(height: 16),
                    metrics,
                    const SizedBox(height: 16),
                    created,
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, TextStyle valueStyle, TextStyle labelStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}


class _BottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _BottomBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      Icons.home,
      Icons.folder_open_outlined,
      Icons.public,
      Icons.person,
    ];

    return BottomAppBar(
      color: Colors.white,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = index == selectedIndex;
            final color = isSelected ? const Color(0xFFFFD54F) : const Color(0xFF374151);

            return GestureDetector(
              onTap: () => onTap(index),
              child: Icon(items[index], color: color, size: isSelected ? 30 : 26),
            );
          }),
        ),
      ),
    );
  }
}
