import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:klikspp/constraint/app_colors.dart';
import 'package:klikspp/constraint/app_typography.dart';
import 'package:klikspp/pages/home_page.dart';
import 'package:klikspp/pages/profile_page.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    const Center(child: Text('Riwayat')),
    const Center(child: Text('Tambah Data')),
    const Center(child: Text('Notifikasi')),
    ProfilePage(),
  ];

  Future<bool> _onWillPop(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white, // warna putih
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Yakin Ingin Keluar?",
                        style: AppTypography.heading4Primary,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Anda akan keluar dari aplikasi KlikSPP",
                    style: AppTypography.bodySmallBlack,
                  ),
                  Gap(10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(true),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                "Yakin",
                                style: AppTypography.button,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Gap(10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(false),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.primary),
                            ),
                            child: Center(
                              child: Text(
                                "Tidak",
                                style: AppTypography.heading4Primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );

    return shouldExit ?? false; // kalau null (dismiss), anggap false
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        body: _pages[_currentIndex],
        floatingActionButton: SizedBox(
          height: 70,
          width: 70,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 3,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FloatingActionButton(
              backgroundColor: AppColors.primary,
              shape: const CircleBorder(),
              elevation: 0, // kita matikan shadow default
              onPressed: () {
                setState(() {
                  _currentIndex = 2;
                });
              },
              child: const Icon(Icons.add, size: 35, color: Colors.white),
            ),
          ),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem("home", "Beranda", 0),
                _buildNavItem("history", "Riwayat", 1),
                const SizedBox(width: 40), // jarak untuk FAB
                _buildNavItem("notification", "Notifikasi", 3),
                _buildNavItem("profile", "Profil", 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String name, String label, int index) {
    final isActive = _currentIndex == index;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              isActive
                  ? 'assets/icons/$name${isActive ? index : ""}.png'
                  : 'assets/icons/$name.png',
              width: 25,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
