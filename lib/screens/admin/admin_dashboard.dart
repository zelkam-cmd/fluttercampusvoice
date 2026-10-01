import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/survey.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/stat_card.dart';
import '../auth/login_screen.dart';
import 'survey_create_screen.dart';
import 'survey_results_screen.dart';

class AdminDashboard extends StatefulWidget {
  final Function(int) onNavigateTab;

  const AdminDashboard({super.key, required this.onNavigateTab});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _firebaseService = FirebaseService();
  final _authService = AuthService();
  List<Survey> _surveys = [];
  int _totalStudents = 0;
  int _totalResponses = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);
    await _firebaseService.initializeSeedDataIfNeeded();
    final surveys = await _firebaseService.getSurveys();
    final students = await _firebaseService.getAllStudents();
    final responsesCount = await _firebaseService.getTotalResponsesCount();

    if (mounted) {
      setState(() {
        _surveys = surveys;
        _totalStudents = students.length;
        _totalResponses = responsesCount;
        _isLoading = false;
      });
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Log Out Admin', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to exit Admin Portal?', style: GoogleFonts.inter()),
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeSurveysCount = _surveys.where((s) => s.status == 'active').length;

    return Scaffold(
      body: GradientBackground(
        child: RefreshIndicator(
          onRefresh: _loadAdminData,
          color: AppColors.royalBlue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Bar Card
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
                      Text(
                        'Admin Portal',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _authService.displayName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  'Administrator',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: AppColors.royalBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            const CircleAvatar(
                              radius: 15,
                              backgroundColor: AppColors.royalBlue,
                              child: Icon(Icons.security_rounded, size: 16, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Navy Admin Hero Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0F172A), // Slate 900
                        Color(0xFF1E293B), // Slate 800
                        Color(0xFF334155), // Slate 700
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'RTDB LIVE CONNECTED',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF34D399),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white70, size: 20),
                            onPressed: _handleLogout,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'University Survey Console',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bulacan State University — Institutional Research & Student Voice',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 3. Mobile 2x2 Metric Cards (Cut down from multi-column desktop tables)
                Row(
                  children: [
                    StatCard(
                      value: _totalStudents.toString(),
                      label: 'STUDENTS',
                      icon: Icons.school_outlined,
                      iconBgColor: AppColors.royalBlue,
                      onTap: () => widget.onNavigateTab(3),
                    ),
                    const SizedBox(width: 12),
                    StatCard(
                      value: activeSurveysCount.toString(),
                      label: 'ACTIVE SURVEYS',
                      icon: Icons.assignment_turned_in_outlined,
                      iconBgColor: AppColors.primaryTeal,
                      onTap: () => widget.onNavigateTab(1),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    StatCard(
                      value: _totalResponses.toString(),
                      label: 'RESPONSES',
                      icon: Icons.question_answer_outlined,
                      iconBgColor: const Color(0xFF7C3AED),
                      onTap: () => widget.onNavigateTab(2),
                    ),
                    const SizedBox(width: 12),
                    StatCard(
                      value: '${_surveys.length}',
                      label: 'TOTAL SURVEYS',
                      icon: Icons.layers_outlined,
                      iconBgColor: const Color(0xFFEA580C),
                      onTap: () => widget.onNavigateTab(1),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 4. Action Banner: Create New Survey
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
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primaryTealLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add_circle_outline, color: AppColors.primaryTeal),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Survey Creator',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  'Design mobile-optimized surveys with Likert scales & choices.',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'Build New Survey',
                        onPressed: () async {
                          final created = await Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SurveyCreateScreen()),
                          );
                          if (created == true) _loadAdminData();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 5. Active Surveys Quick Roster
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Live Surveys Overview',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.onNavigateTab(1),
                      child: Text(
                        'View All',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.royalBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ..._surveys.take(3).map((survey) {
                    final isActive = survey.status == 'active';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isActive ? 'ACTIVE' : 'CLOSED',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: isActive ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${survey.responseCount} responses',
                                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  survey.title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.bar_chart_rounded, color: AppColors.royalBlue),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SurveyResultsScreen(survey: survey),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
