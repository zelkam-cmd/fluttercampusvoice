import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/survey.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_background.dart';
import 'survey_create_screen.dart';
import 'survey_results_screen.dart';

class AdminSurveysScreen extends StatefulWidget {
  const AdminSurveysScreen({super.key});

  @override
  State<AdminSurveysScreen> createState() => _AdminSurveysScreenState();
}

class _AdminSurveysScreenState extends State<AdminSurveysScreen> {
  final _firebaseService = FirebaseService();
  List<Survey> _surveys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurveys();
  }

  Future<void> _loadSurveys() async {
    setState(() => _isLoading = true);
    final list = await _firebaseService.getSurveys();
    if (mounted) {
      setState(() {
        _surveys = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSurveyStatus(Survey survey) async {
    final newStatus = survey.status == 'active' ? 'closed' : 'active';
    await _firebaseService.updateSurveyStatus(survey.id, newStatus);
    if (!mounted) return;
    _loadSurveys();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Survey is now ${newStatus.toUpperCase()}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteSurvey(Survey survey) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Survey?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete "${survey.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firebaseService.deleteSurvey(survey.id);
      _loadSurveys();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Survey Management',
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
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _surveys.isEmpty
                      ? Center(
                          child: Text(
                            'No surveys found. Tap + to create one.',
                            style: GoogleFonts.inter(color: Colors.grey[600]),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadSurveys,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            itemCount: _surveys.length,
                            itemBuilder: (context, index) {
                              final survey = _surveys[index];
                              final isActive = survey.status == 'active';

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
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Status Switch Pill
                                        GestureDetector(
                                          onTap: () => _toggleSurveyStatus(survey),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isActive ? const Color(0xFF86EFAC) : const Color(0xFFCBD5E1),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isActive ? Icons.check_circle_rounded : Icons.pause_circle_outline,
                                                  size: 13,
                                                  color: isActive ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  isActive ? 'ACTIVE (TAP TO CLOSE)' : 'CLOSED (TAP TO OPEN)',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w800,
                                                    color: isActive ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFEF4444)),
                                          onPressed: () => _deleteSurvey(survey),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      survey.title,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      survey.description,
                                      style: GoogleFonts.inter(
                                        fontSize: 12.5,
                                        color: const Color(0xFF64748B),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Text(
                                          '${survey.responseCount} Responses',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text('•', style: TextStyle(color: Colors.grey)),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${survey.questions.length} Questions',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                        const Spacer(),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => SurveyResultsScreen(survey: survey),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.royalBlue,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          icon: const Icon(Icons.bar_chart_rounded, size: 16),
                                          label: const Text('Results', style: TextStyle(fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SurveyCreateScreen()),
          );
          if (res == true) _loadSurveys();
        },
        backgroundColor: AppColors.primaryTeal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'New Survey',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}
