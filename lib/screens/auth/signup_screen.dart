import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_background.dart';
import '../student/student_main_nav.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedDept = 'College of Information and Communications Technology (CICT)';
  String _selectedYear = '3rd Year';
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _departments = [
    'College of Information and Communications Technology (CICT)',
    'College of Engineering (COE)',
    'College of Education (COED)',
    'College of Business Administration (CBA)',
    'College of Science (CS)',
    'College of Arts and Letters (CAL)',
  ];

  final List<String> _yearLevels = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'Graduate Studies',
  ];

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final id = _idController.text.trim();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (id.isEmpty || name.isEmpty || email.isEmpty || pass.isEmpty) {
      setState(() {
        _errorMessage = 'Please complete all required fields.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await AuthService().signup(
      studentNumber: id,
      fullName: name,
      email: email,
      password: pass,
      department: _selectedDept,
      yearLevel: _selectedYear,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const StudentMainNav()),
        (route) => false,
      );
    } else {
      setState(() {
        _errorMessage = 'Could not create account. Please check network connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              // Top Back button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 6),

              // Card Container
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Student Account',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter your university credentials to participate in student voice surveys.',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 18),

                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFDC2626)),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    CustomTextField(
                      label: 'Student Number',
                      hintText: 'e.g. 2023-100234',
                      controller: _idController,
                      isRequired: true,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      label: 'Full Name',
                      hintText: 'e.g. Juan Dela Cruz',
                      controller: _nameController,
                      isRequired: true,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      label: 'BulSU Email',
                      hintText: 'e.g. juan.delacruz@bulsu.edu.ph',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      isRequired: true,
                    ),
                    const SizedBox(height: 12),

                    // College dropdown
                    Text(
                      'College / Department *',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDept,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                      ),
                      items: _departments.map((dept) {
                        return DropdownMenuItem(
                          value: dept,
                          child: Text(
                            dept,
                            style: GoogleFonts.inter(fontSize: 12.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDept = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Year Level dropdown
                    Text(
                      'Year Level *',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedYear,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                      ),
                      items: _yearLevels.map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year, style: GoogleFonts.inter(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedYear = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      label: 'Password',
                      hintText: 'Enter a secure password',
                      controller: _passwordController,
                      isPassword: true,
                      isRequired: true,
                    ),
                    const SizedBox(height: 20),

                    CustomButton(
                      text: 'Create Account',
                      isLoading: _isLoading,
                      onPressed: _handleSignup,
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
