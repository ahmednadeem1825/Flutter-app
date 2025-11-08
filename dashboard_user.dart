import 'package:flutter/material.dart';
import 'package:secure_view/pages/task_model.dart';
import 'package:secure_view/pages/user/user_drawer.dart';
import 'package:secure_view/pages/user/user_model.dart';
import 'package:secure_view/pages/user/user_task_screen.dart';
import 'package:secure_view/pages/user/user_webview.dart';
import 'package:secure_view/services/task_service.dart';
import 'package:secure_view/services/user_service.dart';
import './../customs_widgets/SparklinePainter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreenUser extends StatefulWidget {
  const DashboardScreenUser({super.key});

  @override
  State<DashboardScreenUser> createState() => _DashboardScreenUserState();
}

class _DashboardScreenUserState extends State<DashboardScreenUser> {
  final UserService _db = UserService();
  UserModel? user;
  int _selectedIndex = 0;

  void _onItemTapped(int index) async {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Future.delayed(Duration.zero, () {
          if (!mounted) return;
          if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
            Scaffold.of(context).openDrawer();
          }
        });
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
  try {
    final current = Supabase.instance.client.auth.currentUser;
    if (current == null) return;

    final fetchedUserData = await _db.fetchUserData(current.email!);
    if (!mounted) return;

    if (fetchedUserData == null) {
      await _db.createUserIfNotExist(
        id: current.id,
        fullName: current.userMetadata?['full_name'] ?? 'New User',
        email: current.email!,
        profileImage: current.userMetadata?['picture'],
      );

      final newUserData = await _db.fetchUserData(current.email!);
      if (newUserData != null) {
        setState(() => user = UserModel.fromMap(newUserData));
      }
    } else {
      setState(() => user = UserModel.fromMap(fetchedUserData));
    }
  } catch (e, stack) {
    print('user: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isLandscape = width > height;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    Widget buildCard(String title, Widget child) {
      return SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(1, 3)),
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
              if (title.isNotEmpty) const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      );
    }

    Widget buildSparkline(List<double> data, Color color) {
      List<double> safeData;

      if (data.isEmpty) {
        safeData = List.filled(10, 0.5);
      } else {
        safeData = List.from(data);
      }

      final double minVal = safeData.reduce((a, b) => a < b ? a : b);
      final double maxVal = safeData.reduce((a, b) => a > b ? a : b);
      final double range = (maxVal - minVal).abs() < 0.001 ? 1 : (maxVal - minVal);

      final normalized = safeData.map((v) => (v - minVal) / range).toList();

      return Container(
        width: double.infinity,
        height: 120,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: CustomPaint(painter: SparklinePainter(normalized, color)),
      );
    }

    Widget buildEarningsWidget(String userId) {
      Future<List<double>> fetchWeeklyEarnings() async {
        final supabase = Supabase.instance.client;

        final response = await supabase
            .from('user_task_log')
            .select('created_at, tasks!inner(reward)')
            .eq('user_id', userId)
            .eq('verified', true)
            .gte('created_at', DateTime.now().subtract(const Duration(days: 7)).toIso8601String())
            .order('created_at', ascending: true);

        if (response.isEmpty) {
          return List.filled(7, 0.0);
        }

        Map<String, double> dailyTotals = {};
        for (var entry in response) {
          final date = DateTime.parse(entry['created_at']).toIso8601String().split('T').first;
          final reward = (entry['tasks']['reward'] as num).toDouble();
          dailyTotals[date] = (dailyTotals[date] ?? 0) + reward;
        }

        final today = DateTime.now();
        List<double> last7Days = [];
        for (int i = 6; i >= 0; i--) {
          final d = today.subtract(Duration(days: i)).toIso8601String().split('T').first;
          last7Days.add(dailyTotals[d] ?? 0.0);
        }
        return last7Days;
      }

      return FutureBuilder<List<double>>(
        future: fetchWeeklyEarnings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text('Error loading chart: ${snapshot.error}');
          }

          final data = snapshot.data ?? [];
          final total = data.fold<double>(0, (sum, value) => sum + value);

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                buildSparkline(data, Colors.amber),
                const SizedBox(height: 6),
                Text(
                  "This week: ${total.toStringAsFixed(0)} credits",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.notifications_none, color: Color(0xFF111827)),
          ),
        ],
      ),
      drawer: UserDrawer(),
      bottomNavigationBar: _BottomBar(selectedIndex: _selectedIndex, onTap: _onItemTapped),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(width * 0.04),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: buildCard(
                        "Time Spent",
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.trending_up, color: Colors.green, size:30),
                            const SizedBox(width: 15),
                            Text(
                              "${user!.hoursSpent.toStringAsFixed(1)} hrs",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: buildCard(
                        "",
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.0),
                                child: Switch(value: true, onChanged: null),
                              ),
                              Text(
                                "Passive Mode",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: buildCard(
                        "Payments",
                        Text(
                          "Rs. ${user!.payments.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: buildCard(
                        "Weekly Check-ins",
                        Text(
                          "${user!.weeklyCheckins}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                isLandscape
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: buildCard(
                                "Earnings (This Week)",
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildEarningsWidget(user!.id),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(flex: 3, child: buildCard("Active Sessions", buildTasksCard())),
                        ],
                      )
                    : Column(
                        children: [
                          buildCard(
                            "Earnings (This Week)",
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [buildEarningsWidget(user!.id), const SizedBox(height: 10)],
                            ),
                          ),
                          const SizedBox(height: 10),
                          buildCard("Active Sessions", buildTasksCard()),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildTasksCard() {
  return FutureBuilder<List<TaskModel>>(
    future: TaskService().fetchActiveTasks(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Error loading tasks: ${snapshot.error}"),
        );
      }

      final tasks = snapshot.data ?? [];
      if (tasks.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "No active tasks available right now.",
            style: TextStyle(color: Colors.black54),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(1, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Available Tasks",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const Divider(height: 20, color: Colors.grey),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECB3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.link, color: Colors.amber, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            task.targetUrl,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD54F),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/taskWebView', arguments: task);
                      },
                      child: Text("+${task.reward} cr"),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    },
  );
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
