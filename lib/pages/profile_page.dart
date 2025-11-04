import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:klikspp/constraint/app_colors.dart';
import 'package:klikspp/constraint/app_typography.dart';
import 'package:klikspp/pages/form_profile.dart';
import 'package:klikspp/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService authService = AuthService();
  String name = "";
  String nim = "";

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'Guest';
      nim = prefs.getString('username') ?? '0000';
    });
  }

  Widget buildMenuItem({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: iconBgColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(icon, color: iconBgColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await authService.logout();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (Route<dynamic> route) => false, // hapus semua riwayat halaman
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Gap(50),
            // Foto profil
            Container(
              decoration: const BoxDecoration(shape: BoxShape.circle),
              padding: const EdgeInsets.all(3),
              child: CircleAvatar(
                radius: 45,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "G",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(nim, style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),
            SizedBox(
              width: 150,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: Offset(0, 4), // arah bayangan ke bawah
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0, // hilangkan default shadow
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FormProfile(),
                      ),
                    );
                  },
                  child: const Text(
                    "Edit Profil",
                    style: AppTypography.button,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xfff1f2f6)),
            buildMenuItem(
              icon: Icons.settings,
              iconBgColor: AppColors.primary,
              title: "Settings",
              onTap: () {},
            ),
            buildMenuItem(
              icon: Icons.remove_circle_outline,
              iconBgColor: AppColors.primary,
              title: "Billing Details",
              onTap: () {},
            ),
            buildMenuItem(
              icon: Icons.supervised_user_circle_outlined,
              iconBgColor: AppColors.primary,
              title: "User Management",
              onTap: () {},
            ),
            const Divider(color: Color(0xfff1f2f6)),
            buildMenuItem(
              icon: Icons.info_outline,
              iconBgColor: AppColors.primary,
              title: "Information",
              onTap: () {},
            ),
            buildMenuItem(
              icon: Icons.logout,
              iconBgColor: AppColors.primary,
              title: "Log out",
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
