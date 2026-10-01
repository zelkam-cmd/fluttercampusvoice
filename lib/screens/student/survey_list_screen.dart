import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/survey.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_background.dart';
import 'survey_take_screen.dart';

class SurveyListScreen extends StatefulWidget {
  const SurveyListScreen({super.key});

  @override
  State<SurveyListScreen> createState() => _SurveyListScreenState();
}

class _SurveyListScreenState extends State<SurveyListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _firebaseService = FirebaseService();
  final _authService = AuthService();
  List<Survey> _allSurveys = [];
  Set<String> _completedSurveyIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSurveys();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSurveys() async {
    setState(() => _isLoading = true);
    final surveys = await _firebaseService.getSurveys();
    final studentId = _authService.currentStudent?.id ?? '2023-100234';
    final myResponses = await _firebaseService.getResponsesForStudent(studentId);

    if (mounted) {
      setState(() {
        _allSurveys = surveys;
        _completedSurveyIds = myResponses.map((r) => r.surveyId).toSet();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableSurveys = _allSurveys
        .where((s) => s.status == 'active' && !_completedSurveyIds.contains(s.id))
        .toList();
    final completedSurveys = _allSurveys
        .where((s) => _completedSurveyIds.contains(s.id) || s.status == 'closed')
        .toList();

    return Scaffold(
      body: GradientBackground(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Campus Surveys',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: _loadSurveys,
                  ),
                ],
              ),
            ),

            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primaryTeal,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                tabs: [
                  Tab(text: 'Available (${availableSurveys.length})'),
                  Tab(text: 'Completed / Past (${completedSurveys.length})'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSurveyList(availableSurveys, isAvailable: true),
                        _buildSurveyList(completedSurveys, isAvailable: false),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurveyList(List<Survey> list, {required bool isAvailable}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAvailable ? Icons.assignment_turned_in_outlined : Icons.history_edu_outlined,
              size: 56,
              color: const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 12),
            Text(
              isAvailable ? 'No active surveys at the moment!' : 'No completed surveys yet.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isAvailable ? 'Great job! You are all caught up.' : 'Participate in active surveys to share your voice.',
              style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF94A3B8)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSurveys,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final survey = list[index];
          final isCompleted = _completedSurveyIds.contains(survey.id);

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                        color: isCompleted
                            ? const Color(0xFFDCFCE7)
                            : (survey.status == 'active'
                                ? const Color(0xFFE0F2FE)
                                : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isCompleted ? 'COMPLETED' : (survey.status == 'active' ? 'OPEN' : 'CLOSED'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isCompleted
                              ? const Color(0xFF16A34A)
                              : (survey.status == 'active' ? const Color(0xFF0284C7) : const Color(0xFF64748B)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      survey.category,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.people_alt_outlined,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${survey.responseCount} responses',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  survey.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  survey.description,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: const Color(0xFF475569),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.help_outline_rounded, size: 14, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text(
                          '${survey.questions.length} questions',
                          style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    if (isAvailable && !isCompleted)
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SurveyTakeScreen(survey: survey),
                            ),
                          );
                          if (result == true) {
                            _loadSurveys();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTeal,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Answer Survey',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isCompleted ? 'Response Submitted ✓' : 'Survey Ended',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
