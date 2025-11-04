import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Student {
  final int id;
  final String name;
  final String nis;
  final String className;
  final String? parentName;
  final String? city;

  Student({
    required this.id,
    required this.name,
    required this.nis,
    required this.className,
    this.parentName,
    this.city,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as int,
      name: json['full_name'] ?? "-",
      nis: json['nis']?.toString() ?? "-",
      className: json['class_name'] ?? "-",
      parentName: json['parent_name'],
      city: json['city'],
    );
  }
}

class StudentService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<List<Student>> getStudentsByParent() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('$baseUrl/student/by-parent');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // asumsi response -> {"data": [ { "id": 1, "name": "Yusron Laksono"}, ... ]}
      List list = data['data'] ?? [];
      print(list);
      return list.map((e) => Student.fromJson(e)).toList();
    } else {
      throw Exception("Gagal ambil data siswa");
    }
  }
}
