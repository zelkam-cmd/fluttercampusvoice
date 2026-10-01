import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/student.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_background.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final _authService = AuthService();
  final _firebaseService = FirebaseService();

  late TextEditingController _contactController;
  late TextEditingController _addressController;
  late String _civilStatus;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final student = _authService.currentStudent;
    _contactController = TextEditingController(text: student?.contactNumber ?? '+63 912 345 6789');
    _addressController = TextEditingController(text: student?.address ?? 'City of Malolos, Bulacan');
    _civilStatus = student?.civilStatus ?? 'Single';
  }

  @override
  void dispose() {
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    final current = _authService.currentStudent;
    if (current != null) {
      final updated = Student(
        id: current.id,
        studentNumber: current.studentNumber,
        fullName: current.fullName,
        firstName: current.firstName,
        lastName: current.lastName,
        email: current.email,
        department: current.department,
        yearLevel: current.yearLevel,
        civilStatus: _civilStatus,
        contactNumber: _contactController.text.trim(),
        address: _addressController.text.trim(),
        gwa: current.gwa,
        completedTasks: current.completedTasks,
        profilePhoto: current.profilePhoto,
        role: current.role,
      );

      await _firebaseService.updateStudent(updated);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile details updated successfully!'),
        backgroundColor: Color(0xFF16A34A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = _authService.currentStudent ??
        Student(
          id: '2023-100234',
          studentNumber: '2023-100234',
          fullName: 'Jaredd Catalan',
          firstName: 'Jaredd',
          lastName: 'Catalan',
          email: 'jaredd.catalan@bulsu.edu.ph',
          department: 'College of Information and Communications Technology (CICT)',
          yearLevel: '3rd Year',
        );

    return Scaffold(
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    'Student Profile',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: AppColors.primaryTeal,
                      child: Text(
                        student.fullName.isNotEmpty ? student.fullName[0].toUpperCase() : 'S',
                        style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      student.fullName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      student.studentNumber,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTealLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        student.department,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryTealDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Editable Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact & Personal Details',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Contact Number',
                      hintText: 'e.g. +63 912 345 6789',
                      controller: _contactController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),

                    CustomTextField(
                      label: 'Home Address',
                      hintText: 'Enter complete residential address',
                      controller: _addressController,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),

                    Text(
                      'Civil Status',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _civilStatus,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                      ),
                      items: ['Single', 'Married', 'Widowed', 'Separated'].map((status) {
                        return DropdownMenuItem(value: status, child: Text(status, style: GoogleFonts.inter(fontSize: 13)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _civilStatus = val);
                      },
                    ),
                    const SizedBox(height: 20),

                    CustomButton(
                      text: 'Save Profile Changes',
                      isLoading: _isSaving,
                      onPressed: _handleSave,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
