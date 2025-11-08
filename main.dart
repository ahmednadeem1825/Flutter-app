import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:secure_view/pages/combined_login_page.dart';
import 'package:secure_view/pages/customs_widgets/auth_gate.dart';
import 'package:secure_view/pages/role_selection.dart';
import 'package:secure_view/pages/signup_page.dart';
import 'package:secure_view/pages/user/dashboard_user.dart';
import 'package:secure_view/pages/user/user_profile.dart';
import 'package:secure_view/pages/user/user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/startup_screen .dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: const SecureView(),
    ),
  );
}

class SecureView extends StatelessWidget {
  const SecureView({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      routes: {
        '/': (context) => AuthGate(),
        '/roleSelection': (context) => RoleSelectionPage(),
        '/userDashboard': (context) => DashboardScreenUser(),
        '/startupScreen': (context) => const StartupScreen(),
        '/signIn': (context) => SignupPage(),
        '/profileUser': (context) => const UserProfileScreen(),

        //'/clientDashboard': (context) => const ClientDashboard(),
      },
      title: "Secure View",
    );
  }
}
