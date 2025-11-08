import 'package:flutter/material.dart';

class Screen3 extends StatefulWidget {
  const Screen3({super.key});
  @override
  State<Screen3> createState() => _Screen2State();
}

class _Screen2State extends State<Screen3> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(scale: _scaleAnimation.value, child: child),
              );
            },

            child: Image.asset("assets/images/screen3.png", height: 120, fit: BoxFit.contain),
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontFamily: 'Roboto', fontSize: 22, color: Colors.blueGrey),
              children: [
                TextSpan(
                  text: "Authentic Traffic,\nReal People\n",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber),
                ),
                const TextSpan(
                  text:
                      "Clients recieve verified, transparent engagement from genuine users—never bots",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Container(
            width: 70,
            height: 3,
            decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(2)),
          ),
        ],
      ),
    );
  }
}
