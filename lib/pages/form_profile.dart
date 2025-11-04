import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter/services.dart';
import 'package:klikspp/constraint/app_colors.dart';
import 'package:klikspp/constraint/app_typography.dart';
import 'package:klikspp/services/auth_service.dart';
import 'package:klikspp/widgets/custom_alert.dart';
import 'package:klikspp/widgets/custom_button.dart';
import 'package:klikspp/widgets/custom_text_field.dart';

class FormProfile extends StatefulWidget {
  const FormProfile({super.key});

  @override
  State<FormProfile> createState() => _FormProfileState();
}

class _FormProfileState extends State<FormProfile> {
  bool isPasswordVisible = false;
  bool isLoading = false;

  final oldPassword = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService apiService = AuthService();

  String? newPasswordError, oldPasswordError; //

  Future<void> updatePassword() async {
    setState(() => isLoading = true);

    final result = await apiService.resetPassword(
      oldPassword: oldPassword.text,
      newPassword: passwordController.text,
    );

    setState(() => isLoading = false);

    if (result["statusCode"] == 200 && result["body"]["success"] == true) {
      showCustomToast(
        context: context,
        message: "Password berhasil diperbarui!",
        type: ToastType.success,
      );

      await apiService.logout();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      final body = result["body"];
      if (body != null && body["errors"] != null && body["errors"].isNotEmpty) {
        // Ada error validasi field
        setState(() {
          newPasswordError = body["errors"]["new_password"];
          oldPasswordError = body["errors"]["old_password"];
        });
      } else {
        // Tidak ada error field → tampilkan pesan umum
        showCustomToast(
          context: context,
          message: "Opps!",
          secondaryMessage: body?["message"] ?? "Gagal update password",
          type: ToastType.error,
        );
      }
    }
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
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              color:
                                  AppColors
                                      .primary, // bisa ganti sesuai tema kamu
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            Gap(8),
                            Text(
                              "Edit Profil",
                              style: AppTypography.heading2Primary,
                            ),
                          ],
                        ),
                        Text(
                          "Buat kata sandi baru untuk akun Anda.",
                          style: AppTypography.body,
                        ),
                        const Gap(20),
                        CustomTextField(
                          label: "Password Lama",
                          hintText: "**********",
                          isPassword: false,
                          controller: oldPassword,
                          errorText: oldPasswordError,
                        ),
                        CustomTextField(
                          label: "Password Baru",
                          hintText: "**********",
                          isPassword: true,
                          obscureText: !isPasswordVisible,
                          controller: passwordController,
                          toggleVisibility: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                          errorText:newPasswordError, // 👈 munculin error di bawah field
                        ),
                      ],
                    ),
                  ),
                ),
                CustomButton(
                  label: isLoading ? 'Loading...' : 'Simpan Perubahan',
                  onPressed: isLoading ? null : updatePassword,
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
