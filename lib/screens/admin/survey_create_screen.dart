import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/survey.dart';
import '../../models/question.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_background.dart';

class SurveyCreateScreen extends StatefulWidget {
  const SurveyCreateScreen({super.key});

  @override
  State<SurveyCreateScreen> createState() => _SurveyCreateScreenState();
}

class _SurveyCreateScreenState extends State<SurveyCreateScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _category = 'Academics & Instruction';
  final String _targetAudience = 'All Enrolled Students';
  final List<SurveyQuestion> _questions = [];
  bool _isSaving = false;

  final List<String> _categories = [
    'Academics & Instruction',
    'Campus Facilities',
    'Student Welfare & Guidance',
    'Canteen & Food Hygiene',
    'IT & Wi-Fi Services',
    'Extracurricular & Sports',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-populate with 2 default questions
    _questions.add(
      SurveyQuestion(
        id: 'q_${DateTime.now().millisecondsSinceEpoch}_1',
        surveyId: '',
        questionText: 'The quality of academic instruction in our classes meets my expectations.',
        questionType: 'likert',
        orderIndex: 0,
      ),
    );
    _questions.add(
      SurveyQuestion(
        id: 'q_${DateTime.now().millisecondsSinceEpoch}_2',
        surveyId: '',
        questionText: 'What improvements or facilities would best enhance your student life on campus?',
        questionType: 'text',
        isRequired: false,
        orderIndex: 1,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _addQuestion(String type) {
    showDialog(
      context: context,
      builder: (ctx) {
        final qTextController = TextEditingController();
        final optionsController = TextEditingController(text: 'Option 1, Option 2, Option 3');

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            type == 'likert'
                ? 'Add Likert Scale Question'
                : (type == 'radio' ? 'Add Multiple Choice Question' : 'Add Open Text Question'),
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: qTextController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Question Statement *',
                    hintText: 'e.g. Facilities are kept tidy and well-maintained',
                  ),
                ),
                if (type == 'radio') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: optionsController,
                    decoration: const InputDecoration(
                      labelText: 'Options (comma separated)',
                      hintText: 'e.g. Yes, No, Maybe',
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (qTextController.text.trim().isEmpty) return;
                List<String> options = [];
                if (type == 'radio') {
                  options = optionsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                }

                setState(() {
                  _questions.add(
                    SurveyQuestion(
                      id: 'q_${DateTime.now().millisecondsSinceEpoch}',
                      surveyId: '',
                      questionText: qTextController.text.trim(),
                      questionType: type,
                      options: options,
                      orderIndex: _questions.length,
                    ),
                  );
                });
                Navigator.of(ctx).pop();
              },
              child: const Text('Add Question'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSaveSurvey() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a survey title.'), backgroundColor: Color(0xFFDC2626)),
      );
      return;
    }

    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one question.'), backgroundColor: Color(0xFFDC2626)),
      );
      return;
    }

    setState(() => _isSaving = true);

    final surveyId = 'srv_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final endDate = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 30)));

    final newSurvey = Survey(
      id: surveyId,
      title: title,
      description: desc,
      category: _category,
      targetAudience: _targetAudience,
      status: 'active',
      startDate: now,
      endDate: endDate,
      responseCount: 0,
      questions: _questions,
    );

    await FirebaseService().saveSurvey(newSurvey);

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Survey created successfully and now live!'), backgroundColor: Color(0xFF16A34A)),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
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
                    'Create New Survey',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Metadata Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Survey Information',
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 14),

                    CustomTextField(
                      label: 'Survey Title',
                      hintText: 'e.g. 1st Semester Learning Resources Survey',
                      controller: _titleController,
                      isRequired: true,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      label: 'Description / Purpose',
                      hintText: 'Explain the goal of this evaluation to students...',
                      controller: _descController,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'Category',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.inter(fontSize: 13)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _category = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Questions Builder Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Questions (${_questions.length})',
                          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        PopupMenuButton<String>(
                          onSelected: _addQuestion,
                          icon: const Icon(Icons.add_circle, color: AppColors.primaryTeal),
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(value: 'likert', child: Text('Likert Scale (1 - 5)')),
                            const PopupMenuItem(value: 'radio', child: Text('Multiple Choice')),
                            const PopupMenuItem(value: 'text', child: Text('Open Feedback (Text)')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (_questions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text('No questions added yet. Tap + to add.', style: GoogleFonts.inter(color: Colors.grey[500])),
                        ),
                      )
                    else
                      ..._questions.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final q = entry.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryTeal,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${idx + 1}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      q.questionText,
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Type: ${q.questionType.toUpperCase()}',
                                      style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFEF4444), size: 20),
                                onPressed: () {
                                  setState(() {
                                    _questions.removeAt(idx);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              CustomButton(
                text: 'Publish Survey to Mobile Feed',
                isLoading: _isSaving,
                onPressed: _handleSaveSurvey,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
