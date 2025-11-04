import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:klikspp/constraint/app_colors.dart';
import 'package:klikspp/constraint/app_typography.dart';
import 'package:klikspp/services/student_service.dart';
import 'package:klikspp/widgets/custom_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? activeStudent;
  int? activeStudentId;
  List<Student> students = [];

  @override
  void initState() {
    super.initState();
    _loadActiveStudent();
    _fetchStudents();
  }

  Future<void> _loadActiveStudent() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      activeStudent = prefs.getString('active_student_name');
      activeStudentId = prefs.getInt('active_student_id');
    });
  }

  Future<void> _setActiveStudent(Student student) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_student_name', student.name);
    await prefs.setInt('active_student_id', student.id);
    setState(() {
      activeStudent = student.name;
      activeStudentId = student.id;
    });
    showCustomToast(
      // ignore: use_build_context_synchronously
      context: context,
      message: "Beralih ke $activeStudent",
      type: ToastType.success,
    );
    // ignore: use_build_context_synchronously
    Navigator.pop(context); // tutup dialog
  }

  Future<void> _fetchStudents() async {
    try {
      final service = StudentService();
      final data = await service.getStudentsByParent();
      if (data.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();

        // kalau belum ada yg terset → ambil data pertama
        final savedId = prefs.getInt('active_student_id');
        if (savedId == null) {
          final first = data.first;
          await prefs.setString('active_student_name', first.name);
          await prefs.setInt('active_student_id', first.id);

          setState(() {
            students = data;
            activeStudent = first.name;
            activeStudentId = first.id;
          });
        } else {
          setState(() {
            students = data;
          });
        }
      } else {
        setState(() {
          students = [];
        });
      }
    } catch (e) {
      // LogPrin("Error fetch students: $e");
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
        body: ListView(
          children: [
            buildHeader(context, activeStudent, students, _setActiveStudent),
            buildNews(),
            const Gap(15),
            buildPaymentComplete(),
            const Gap(15),
            buildHistoryTransaction(),
            const Gap(50),
          ],
        ),
      ),
    );
  }
}

Widget buildHeader(
  BuildContext context,
  String? activeStudent,
  List<Student> students,
  Function(Student) setActiveStudent,
) {
  return Stack(
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        height: 190,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/img/logo-light.png', width: 50),
                students.isNotEmpty
                    ? InkWell(
                      onTap:
                          () => _showMyDialog(
                            context,
                            activeStudent,
                            students,
                            setActiveStudent,
                          ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 15,
                            ),
                            const Gap(5),
                            Text(
                              activeStudent ?? "-",
                              style: AppTypography.bodySmallWhite,
                            ),
                          ],
                        ),
                      ),
                    )
                    : const SizedBox.shrink(),
              ],
            ),
            const Gap(10),
            Text("Tagihan Bulan Ini", style: AppTypography.bodySmallWhite),
            Text("Rp 245.000", style: AppTypography.heading2White),
            const Gap(5),
            Row(
              children: [
                Image.asset('assets/icons/calendar.png', width: 15),
                const Gap(5),
                Text("Agustus", style: AppTypography.bodySmallWhite),
              ],
            ),
            const Gap(20),
            // Menu bawah
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Image.asset('assets/icons/atm.png', width: 28),
                      const Gap(5),
                      Text("Bayar SPP", style: AppTypography.captionBlack),
                    ],
                  ),
                  Column(
                    children: [
                      Image.asset('assets/icons/basketball.png', width: 28),
                      const Gap(5),
                      Text(
                        "Ekstrakurikuler",
                        style: AppTypography.captionBlack,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Image.asset('assets/icons/teacher.png', width: 28),
                      const Gap(5),
                      Text("Informasi Guru", style: AppTypography.captionBlack),
                    ],
                  ),
                  Column(
                    children: [
                      Image.asset('assets/icons/megaphone.png', width: 28),
                      const Gap(5),
                      Text("Berita Sekolah", style: AppTypography.captionBlack),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

void _showMyDialog(
  BuildContext context,
  String? activeStudent,
  List<Student> students,
  Function(Student) onSelect,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Pilih Siswa", style: AppTypography.heading4Primary),
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
              const Gap(10),
              if (students.isEmpty)
                const Center(child: CircularProgressIndicator()),
              ...students.map((student) {
                final isActive = student.name == activeStudent;
                return GestureDetector(
                  onTap: () => onSelect(student),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          isActive
                              ? null
                              : Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      children: [
                        if (isActive)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 15,
                          ),
                        if (isActive) const Gap(5),
                        Text(
                          student.name,
                          style:
                              isActive
                                  ? AppTypography.button
                                  : AppTypography.heading4Primary,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}

Widget buildNews() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color(0xffE74B32).withValues(alpha: 0.15),
        border: Border.all(
          color: Color(0xffE74B32).withValues(alpha: 0.50),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Image.asset('assets/icons/megaphone.png', width: 28),
          Gap(15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hadirilah rapat wali murid!",
                  style: AppTypography.heading4Primary,
                ),
                Text(
                  "Yang akan diadalakan lorem ipsum dolor sit amesst.",
                  style: AppTypography.bodySmallPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildPaymentComplete() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Telah Menyelesaikan Tagihan",
            style: AppTypography.heading4Primary,
          ),
          Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset('assets/img/people.png', width: 40),
                  Gap(10),
                  Text("Beryosa", style: AppTypography.bodySmallBlack),
                ],
              ),
              Text("13/08/2025", style: AppTypography.bodySmall),
            ],
          ),
          Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset('assets/img/people.png', width: 40),
                  Gap(10),
                  Text("Beryosa", style: AppTypography.bodySmallBlack),
                ],
              ),
              Text("13/08/2025", style: AppTypography.bodySmall),
            ],
          ),
          Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset('assets/img/people.png', width: 40),
                  Gap(10),
                  Text("Beryosa", style: AppTypography.bodySmallBlack),
                ],
              ),
              Text("13/08/2025", style: AppTypography.bodySmall),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget buildHistoryTransaction() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Riwayat Pembayaran", style: AppTypography.heading4Primary),
          Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("September", style: AppTypography.subTitle),
                  Text("13/08/2025", style: AppTypography.bodySmall),
                ],
              ),
              Text("Rp 245.000", style: AppTypography.subTitle),
              Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 15),
                  Gap(3),
                  Text("Lunas", style: AppTypography.bodySmallSuccess),
                ],
              ),
            ],
          ),
          Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("September", style: AppTypography.subTitle),
                  Text("13/08/2025", style: AppTypography.bodySmall),
                ],
              ),
              Text("Rp 245.000", style: AppTypography.subTitle),
              Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 15),
                  Gap(3),
                  Text("Lunas", style: AppTypography.bodySmallSuccess),
                ],
              ),
            ],
          ),
          Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("September", style: AppTypography.subTitle),
                  Text("13/08/2025", style: AppTypography.bodySmall),
                ],
              ),
              Text("Rp 245.000", style: AppTypography.subTitle),
              Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 15),
                  Gap(3),
                  Text("Lunas", style: AppTypography.bodySmallSuccess),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
