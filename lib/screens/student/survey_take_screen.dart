import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/survey.dart';
import '../../models/question.dart';
import '../../models/survey_response.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/gradient_background.dart';
import 'survey_success_screen.dart';

class SurveyTakeScreen extends StatefulWidget {
  final Survey survey;

  const SurveyTakeScreen({super.key, required this.survey});

  @override
  State<SurveyTakeScreen> createState() => _SurveyTakeScreenState();
}

class _SurveyTakeScreenState extends State<SurveyTakeScreen> {
  final Map<String, dynamic> _answers = {};
  int _currentIndex = 0;
  bool _isSubmitting = false;
  final TextEditingController _textController = TextEditingController();

  final List<String> _likertLabels = [
    'Strongly Disagree',
    'Disagree',
    'Neutral',
    'Agree',
    'Strongly Agree'
  ];

  final List<Color> _likertColors = [
    const Color(0xFFEF4444), // Red
    const Color(0xFFF97316), // Orange
    const Color(0xFFEAB308), // Yellow
    const Color(0xFF10B981), // Emerald
    const Color(0xFF059669), // Green
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onAnswerSelected(String questionId, dynamic value) {
    setState(() {
      _answers[questionId] = value;
    });
  }

  Future<void> _handleSubmit() async {
    final questions = widget.survey.questions;
    // Check if required questions are answered
    for (var q in questions) {
      if (q.isRequired && (!_answers.containsKey(q.id) || _answers[q.id] == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please answer question #${questions.indexOf(q) + 1} before submitting.'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    final authService = AuthService();
    final student = authService.currentStudent;
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final response = SurveyResponse(
      id: 'resp_${DateTime.now().millisecondsSinceEpoch}',
      surveyId: widget.survey.id,
      studentId: student?.id ?? '2023-100234',
      studentName: student?.fullName ?? 'Jaredd Catalan',
      answers: _answers,
      submittedAt: now,
    );

    await FirebaseService().submitResponse(response);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SurveySuccessScreen(surveyTitle: widget.survey.title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.survey.questions;

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.survey.title)),
        body: const Center(child: Text('No questions available in this survey.')),
      );
    }

    final currentQuestion = questions[_currentIndex];
    final progress = (_currentIndex + 1) / questions.length;

    return Scaffold(
      body: GradientBackground(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      widget.survey.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${questions.length}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Progress indicator bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Question Card Container
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Question ${_currentIndex + 1}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (currentQuestion.isRequired)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Required',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFDC2626),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Question Text
                      Text(
                        currentQuestion.questionText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Input choices based on question type
                      _buildQuestionInput(currentQuestion),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Navigation & Submit Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    if (_currentIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _currentIndex--;
                              final prevQ = questions[_currentIndex];
                              _textController.text = _answers[prevQ.id]?.toString() ?? '';
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Previous',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    if (_currentIndex > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _currentIndex == questions.length - 1
                          ? CustomButton(
                              text: 'Submit Survey',
                              isLoading: _isSubmitting,
                              onPressed: _handleSubmit,
                            )
                          : CustomButton(
                              text: 'Next Question',
                              onPressed: () {
                                if (currentQuestion.questionType == 'text') {
                                  _answers[currentQuestion.id] = _textController.text.trim();
                                }
                                setState(() {
                                  _currentIndex++;
                                  final nextQ = questions[_currentIndex];
                                  _textController.text = _answers[nextQ.id]?.toString() ?? '';
                                });
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionInput(SurveyQuestion question) {
    switch (question.questionType) {
      case 'likert':
        return _buildLikertInput(question);
      case 'radio':
        return _buildRadioInput(question);
      case 'text':
      default:
        return _buildTextInput(question);
    }
  }

  Widget _buildLikertInput(SurveyQuestion question) {
    final selectedScore = _answers[question.id] as int?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your level of agreement:',
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 14),

        // 1 to 5 Likert Buttons (Clean mobile touch layout)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final score = index + 1;
            final isSelected = selectedScore == score;
            final buttonColor = _likertColors[index];

            return GestureDetector(
              onTap: () => _onAnswerSelected(question.id, score),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected ? buttonColor : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? buttonColor : const Color(0xFFE2E8F0),
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: buttonColor.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  '$score',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),

        // Descriptive label of selected score
        if (selectedScore != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: _likertColors[selectedScore - 1].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '$selectedScore — ${_likertLabels[selectedScore - 1]}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _likertColors[selectedScore - 1],
              ),
            ),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1 = Strongly Disagree',
                style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF94A3B8)),
              ),
              Text(
                '5 = Strongly Agree',
                style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF94A3B8)),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildRadioInput(SurveyQuestion question) {
    final selectedOption = _answers[question.id]?.toString();

    return Column(
      children: question.options.map((opt) {
        final isSelected = selectedOption == opt;

        return GestureDetector(
          onTap: () => _onAnswerSelected(question.id, opt),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryTealLight : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primaryTeal : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? AppColors.primaryTeal : const Color(0xFF94A3B8),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    opt,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextInput(SurveyQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _textController,
          maxLines: 5,
          onChanged: (val) {
            _answers[question.id] = val;
          },
          decoration: InputDecoration(
            hintText: 'Type your feedback, opinion, or suggestions here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
          ),
        ),
      ],
    );
  }
}
