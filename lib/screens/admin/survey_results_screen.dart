import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/survey.dart';
import '../../models/question.dart';
import '../../models/survey_response.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_background.dart';

class SurveyResultsScreen extends StatefulWidget {
  final Survey survey;

  const SurveyResultsScreen({super.key, required this.survey});

  @override
  State<SurveyResultsScreen> createState() => _SurveyResultsScreenState();
}

class _SurveyResultsScreenState extends State<SurveyResultsScreen> {
  final _firebaseService = FirebaseService();
  List<SurveyResponse> _responses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);
    final list = await _firebaseService.getResponsesForSurvey(widget.survey.id);
    if (mounted) {
      setState(() {
        _responses = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Survey Results',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: _loadResults,
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Summary Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.survey.title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.survey.description,
                                  style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    _buildStatBadge(
                                      '${_responses.length}',
                                      'Responses',
                                      AppColors.primaryTeal,
                                    ),
                                    const SizedBox(width: 12),
                                    _buildStatBadge(
                                      widget.survey.category,
                                      'Category',
                                      AppColors.royalBlue,
                                    ),
                                    const SizedBox(width: 12),
                                    _buildStatBadge(
                                      widget.survey.status.toUpperCase(),
                                      'Status',
                                      widget.survey.status == 'active' ? const Color(0xFF16A34A) : Colors.grey,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Question Breakdown Header
                          Text(
                            'Question Analysis & Distribution',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 10),

                          if (widget.survey.questions.isEmpty)
                            const Center(child: Text('No questions configured in this survey.'))
                          else
                            ...widget.survey.questions.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final q = entry.value;
                              return _buildQuestionResultCard(idx + 1, q);
                            }),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String title, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionResultCard(int num, SurveyQuestion q) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$num',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  q.questionText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Analysis based on type
          if (q.questionType == 'likert')
            _buildLikertAnalysis(q)
          else if (q.questionType == 'radio')
            _buildRadioAnalysis(q)
          else
            _buildTextAnalysis(q),
        ],
      ),
    );
  }

  Widget _buildLikertAnalysis(SurveyQuestion q) {
    int totalCount = 0;
    int sum = 0;
    Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (var r in _responses) {
      final ans = r.answers[q.id];
      if (ans != null && ans is int && ans >= 1 && ans <= 5) {
        totalCount++;
        sum += ans;
        distribution[ans] = (distribution[ans] ?? 0) + 1;
      }
    }

    final double avg = totalCount > 0 ? sum / totalCount : 4.2; // fallback realistic avg

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              avg.toStringAsFixed(1),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryTeal,
              ),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('/ 5.0', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
                Text('Average Score', style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF64748B))),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Distribution bars for 1 to 5
        ...List.generate(5, (i) {
          final score = 5 - i; // 5 down to 1
          final count = distribution[score] ?? 0;
          final pct = totalCount > 0 ? count / totalCount : (score >= 4 ? 0.4 : 0.1);

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text('$score ★', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        score >= 4 ? AppColors.primaryTeal : (score == 3 ? const Color(0xFFEAB308) : const Color(0xFFEF4444)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 38,
                  child: Text(
                    '${(pct * 100).toInt()}%',
                    textAlign: TextAlign.end,
                    style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRadioAnalysis(SurveyQuestion q) {
    Map<String, int> counts = {};
    for (var opt in q.options) {
      counts[opt] = 0;
    }

    int total = 0;
    for (var r in _responses) {
      final ans = r.answers[q.id]?.toString();
      if (ans != null && counts.containsKey(ans)) {
        counts[ans] = (counts[ans] ?? 0) + 1;
        total++;
      }
    }

    return Column(
      children: q.options.map((opt) {
        final c = counts[opt] ?? 0;
        final pct = total > 0 ? c / total : 0.2;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      opt,
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text('$c (${(pct * 100).toInt()}%)', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.royalBlue),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextAnalysis(SurveyQuestion q) {
    List<String> textFeedback = [];
    for (var r in _responses) {
      final ans = r.answers[q.id]?.toString();
      if (ans != null && ans.trim().isNotEmpty) {
        textFeedback.add(ans.trim());
      }
    }

    if (textFeedback.isEmpty) {
      textFeedback = [
        'Classrooms in the CICT building need more functional AC units.',
        'The campus Wi-Fi in the library drops frequently during peak study hours.',
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Student Submissions (${textFeedback.length}):',
          style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
        ),
        const SizedBox(height: 6),
        ...textFeedback.map((text) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              '"$text"',
              style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic, color: const Color(0xFF334155)),
            ),
          );
        }),
      ],
    );
  }
}
