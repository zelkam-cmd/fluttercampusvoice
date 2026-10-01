import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/student.dart';
import '../../models/survey.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/stat_card.dart';
import '../auth/login_screen.dart';
import 'survey_take_screen.dart';
import 'student_profile_screen.dart';

class StudentDashboard extends StatefulWidget {
  final Function(int) onNavigateTab;

  const StudentDashboard({super.key, required this.onNavigateTab});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final _authService = AuthService();
  final _firebaseService = FirebaseService();
  List<Survey> _activeSurveys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    await _firebaseService.initializeSeedDataIfNeeded();
    final surveys = await _firebaseService.getSurveys();
    if (mounted) {
      setState(() {
        _activeSurveys = surveys.where((s) => s.status == 'active').toList();
        _isLoading = false;
      });
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Log Out',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to end your current session?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey[700])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _authService.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
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
          gwa: 1.45,
          completedTasks: 8,
        );

    final firstName = student.firstName.isNotEmpty ? student.firstName : 'Student';

    return Scaffold(
      body: GradientBackground(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: AppColors.primaryTeal,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Bar Card (1:1 with MIT App Screenshot media_1790821078337.png)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // "Student Portal" Title
                      Text(
                        'Student Portal',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const Spacer(),

                      // Notification Bell with Badge
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, size: 22),
                            onPressed: () => widget.onNavigateTab(2), // notices tab
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                          ),
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),

                      // User Pill (Name + Student role + Avatar)
                      GestureDetector(
                        onTap: () => widget.onNavigateTab(3), // profile tab
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    student.fullName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Student',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: AppColors.primaryTeal,
                                child: Text(
                                  student.fullName.isNotEmpty
                                      ? student.fullName.substring(0, 1).toUpperCase()
                                      : 'S',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Welcome Banner Card (Royal Blue with Department & Edit Profile button)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1D4ED8), // Deep Royal Blue
                        Color(0xFF2563EB), // Royal Blue
                        Color(0xFF3B82F6), // Sky Blue accent
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Department Pill Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          student.department,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Welcome back and Edit Profile row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                Text(
                                  firstName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CustomButton(
                            text: 'Edit Profile',
                            variant: ButtonVariant.bannerPill,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const StudentProfileScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 3. Stat Cards Row (1:1 with MIT App Screenshot: 1.45 CURRENT GWA, 8 COMPLETED TASKS)
                Row(
                  children: [
                    StatCard(
                      value: student.gwa.toStringAsFixed(2),
                      label: 'CURRENT GWA',
                      icon: Icons.description_outlined,
                      iconBgColor: const Color(0xFF0284C7), // Blue-cyan
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    StatCard(
                      value: student.completedTasks.toString(),
                      label: 'COMPLETED TASKS',
                      icon: Icons.access_time_rounded,
                      iconBgColor: const Color(0xFF7C3AED), // Purple
                      onTap: () => widget.onNavigateTab(1),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 4. Active Surveys Feed / Urgent Banner
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_activeSurveys.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'ACTIVE NOW',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFD97706),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${_activeSurveys.length} survey(s) available',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _activeSurveys.first.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _activeSurveys.first.description,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SurveyTakeScreen(survey: _activeSurveys.first),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryTeal,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Start Survey Now'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // 5. Quick Actions Card (1:1 with MIT App Screenshot media_1790821078337.png)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
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
                      Text(
                        'Quick Actions',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Primary button: Browse Surveys / Grades
                      CustomButton(
                        text: 'Browse Surveys & Voice',
                        onPressed: () => widget.onNavigateTab(1),
                      ),
                      const SizedBox(height: 12),

                      // Secondary outline button: Log Out
                      CustomButton(
                        text: 'Log Out',
                        variant: ButtonVariant.outline,
                        onPressed: _handleLogout,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
