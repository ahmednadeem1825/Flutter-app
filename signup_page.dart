import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:secure_view/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

final supabase = Supabase.instance.client;

class _SignupPageState extends State<SignupPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  var logger = Logger();
  String? _userId;
  bool _consentGiven = false; // Track checkbox state
  bool _isSigningIn = false; // Track loading state for Google sign-in

  @override
  void initState() {
    super.initState();
    supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        _userId = data.session?.user.id;
      });
    });

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  Future<void> _insertUserToDb(User user) async {
    final response = await supabase.from('users').upsert({
      'id': user.id,
      'full_name': user.userMetadata?['full_name'] ?? user.email ?? '',
      'email': user.email,
      'profile_image': user.userMetadata?['picture'] ?? '',
      'is_active': true,
    }, onConflict: 'id');

    if (response.error != null) {
      logger.e('Error inserting user: ${response.error!.message}');
    } 
  }

  Future<AuthResponse> _googleSignIn() async {
    if (!_consentGiven) return Future.error("Consent not given");

    setState(() => _isSigningIn = true);

    try {
      const webClientId = '375041248339-9l1ofuoj2r0sribbomthv3hdi2mm2bau.apps.googleusercontent.com';
      final UserService db = UserService();

      final GoogleSignIn googleSignIn = GoogleSignIn(
        signInOption: SignInOption.standard,
        serverClientId: webClientId,
        scopes: ['email', 'openid', 'profile'],
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw Exception('User cancelled Google sign-in');

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null || accessToken == null) throw Exception('Missing Google Auth Token');

      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user != null) {
        final currentUser = response.user!;
        final email = currentUser.email;
        final existingUser = await db.fetchUserData(email!);

        if (existingUser != null) {
          if (context.mounted) Navigator.pushReplacementNamed(context, '/userDashboard');
        } else {
          if (context.mounted) {
            await _insertUserToDb(currentUser);
            Navigator.pushReplacementNamed(context, '/roleSelection');
          }
        }
      }

      return response;
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(scale: _scaleAnimation.value, child: child),
                ),
                child: Image.asset(
                  "assets/images/logo.png",
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Where real engagement\nmeets transparency",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontFamily: 'Roboto', color: Colors.blueGrey),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _consentGiven && !_isSigningIn ? _googleSignIn : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _consentGiven ? const Color(0xFFF6CF5C) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      if (_consentGiven)
                        const BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 8,
                          offset: Offset(1, 3),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/images/SVGs/google.svg', width: 28, height: 28),
                      const SizedBox(width: 16),
                      _isSigningIn
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Text(
                              "Continue with Google",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'Montesrrat',
                                color: Colors.black,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(fontFamily: 'Roboto', fontSize: 14, color: Colors.blueGrey),
                  children: [
                    TextSpan(
                      text: "We use Google sign-in to securely verify your identity. No other sign-up methods are supported.",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _consentGiven,
                    onChanged: (value) => setState(() => _consentGiven = value ?? false),
                    checkColor: Colors.white,
                    activeColor: const Color(0xFFF6CF5C),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          color: Colors.blueGrey,
                        ),
                        children: [
                          const TextSpan(text: "I consent to sign in with Google and\naccept the "),
                          TextSpan(
                            text: "Terms & Privacy Policy",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.lightBlue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () {
                              // TODO: open terms URL
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Text("SecureView v1.0 Developed by X", style: TextStyle(fontSize: 11)),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
