import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TaskWebView extends StatefulWidget {
  final Map<String, dynamic>? task;
  const TaskWebView({super.key, required this.task});

  @override
  State<TaskWebView> createState() => _TaskWebViewState();
}

class _TaskWebViewState extends State<TaskWebView> {
  final supabase = Supabase.instance.client;
  late final WebViewController _controller;
  int secondsLeft = 15;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    if (widget.task != null && widget.task!.isNotEmpty) {
      _initWebView();
    }
  }

  Future<void> _initWebView() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final session = supabase.auth.currentSession;
    final accessToken = session?.accessToken;

    final secureUrl = Uri.parse(widget.task!['target_url']).replace(
      queryParameters: {
        'uid': user.id,
        if (accessToken != null) 'token': accessToken,
      },
    );

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(secureUrl);

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft > 0) {
        setState(() => secondsLeft--);
      } else {
        t.cancel();
        _rewardUser();
      }
    });
  }

  Future<void> _rewardUser() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from('user_task_log').insert({
        'user_id': user.id,
        'task_id': widget.task!['id'],
        'duration_seconds': 15,
        'verified': true,
      });

      await supabase
          .from('users')
          .update({
            'credits': (widget.task!['reward'] as int),
            'payments': (widget.task!['reward'] as int),
          })
          .eq('id', user.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Earned ${widget.task!['reward']} credits!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      print("Error rewarding user: $e");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If task is null or empty, show a "No running task" screen
    if (widget.task == null || widget.task!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("No Running Task")),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.shade200.withOpacity(0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.info_outline, size: 64, color: Colors.amber),
                SizedBox(height: 16),
                Text(
                  "No running task",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "You currently have no tasks to complete.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Otherwise, show the WebView task
    return Scaffold(
      appBar: AppBar(title: Text(widget.task!['title'])),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (secondsLeft > 0)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amberAccent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  "Wait $secondsLeft s",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
