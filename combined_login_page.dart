import 'package:flutter/material.dart';
import 'package:secure_view/pages/signup_page.dart';

class Combinedloginpage extends StatelessWidget {
  const Combinedloginpage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: SignupPage(),
      ),
    );
  }
}
