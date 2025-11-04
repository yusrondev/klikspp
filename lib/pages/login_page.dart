import 'package:flutter/material.dart';
import 'package:klikspp/services/auth_service.dart';
import 'package:klikspp/widgets/custom_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gap/gap.dart';
import 'package:flutter/services.dart';
import 'package:klikspp/constraint/app_colors.dart';
import 'package:klikspp/constraint/app_typography.dart';
import 'package:klikspp/widgets/custom_button.dart';
import 'package:klikspp/widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isPasswordVisible = false;
  bool isLoading = false;

  String? usernameError;
  String? passwordError;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService apiService = AuthService();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login(context) async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    // Reset error dulu
    setState(() {
      usernameError = null;
      passwordError = null;
    });

    // Validasi local
    if (username.isEmpty) {
      setState(() => usernameError = "NIS tidak boleh kosong");
      return;
    }
    if (password.isEmpty) {
      setState(() => passwordError = "Password tidak boleh kosong");
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await apiService.login(username, password);
      final statusCode = result['statusCode'];
      final body = result['body'];

      if (statusCode == 201 && body['success'] == true) {
        final data = body['data'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('refresh_token', data['refresh_token']);
        await prefs.setString('name', data['user']['name']);
        await prefs.setString('username', data['user']['username']);

        showCustomToast(
          context: context,
          message: "Berhasil Masuk!",
          type: ToastType.success,
        );

        Navigator.pushReplacementNamed(context, '/app');
      } else {
        if (body != null &&
            body['errors'] != null &&
            body['errors'].isNotEmpty) {
          // Tampilkan error ke field
          setState(() {
            usernameError = body['errors']['username'];
            passwordError = body['errors']['password'];
          });
        } else {
          // Pesan umum
          showCustomToast(
            context: context,
            message: body?["message"] ?? "Sedang ada masalah",
            type: ToastType.error,
          );
        }
      }
    } catch (e) {
      showCustomToast(
        context: context,
        message: "Terjadi kesalahan!",
        type: ToastType.error,
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Selamat Datang!",
                          style: AppTypography.heading2Primary,
                        ),
                        Text(
                          "Silakan isi form di bawah untuk melanjutkan.",
                          style: AppTypography.body,
                        ),
                        const Gap(20),
                        CustomTextField(
                          label: "NIS",
                          hintText: "01234567",
                          isNumber: true,
                          controller: usernameController,
                          errorText: usernameError,
                        ),
                        CustomTextField(
                          label: "Password",
                          hintText: "**********",
                          isPassword: true,
                          obscureText: !isPasswordVisible,
                          controller: passwordController,
                          toggleVisibility: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                          onTapForgotPassword: () {},
                          errorText: passwordError,
                        ),
                      ],
                    ),
                  ),
                ),
                CustomButton(
                  label: isLoading ? 'Loading...' : 'Masuk',
                  onPressed: isLoading ? null : () => login(context),
                  type: CustomButtonType.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
