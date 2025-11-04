import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:klikspp/constraint/app_colors.dart';
import 'package:klikspp/pages/login_page.dart';
import 'package:klikspp/layouts/app_layout.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KlikSPP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF-Pro-Display',
        scaffoldBackgroundColor: Colors.white,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primary,
          selectionColor: AppColors.primary,
          selectionHandleColor: AppColors.primary,
        ),
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/app': (context) => const AppLayout(),
      },
      home: const SplashScreen(), // 👈 Mulai dari splash
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    final route = await _checkToken();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, route);
  }

  Future<String> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final refreshToken = prefs.getString('refresh_token');

    if (token == null || refreshToken == null) {
      return '/login';
    }

    try {
      // Cek token ke /check
      final response = await http.get(
        Uri.parse('$baseUrl/check'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data']?['id'] != null) {
          return '/app';
        } else {
          return '/login';
        }
      } else if (response.statusCode == 401) {
        // Token expired, coba refresh
        final refreshResponse = await http.post(
          Uri.parse('$baseUrl/auth/refresh-token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"refresh_token": refreshToken}),
        );

        if (refreshResponse.statusCode == 200) {
          final refreshData = jsonDecode(refreshResponse.body);

          if (refreshData['success'] == true) {
            final newToken = refreshData['data']?['token'];
            final newRefreshToken = refreshData['data']?['refresh_token'];

            if (newToken != null && newRefreshToken != null) {
              await prefs.setString('token', newToken);
              await prefs.setString('refresh_token', newRefreshToken);

              // Coba ulang /check dengan token baru
              final retry = await http.get(
                Uri.parse('$baseUrl/check'),
                headers: {'Authorization': 'Bearer $newToken'},
              );

              if (retry.statusCode == 200) {
                return '/app';
              }
            }
          }
        }
        return '/login'; // refresh gagal
      } else {
        return '/login'; // selain 200/401, anggap gagal
      }
    } catch (e, st) {
      debugPrint("Exception saat cek token: $e\n$st");
      return '/login';
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
