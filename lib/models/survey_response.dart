class SurveyResponse {
  final String id;
  final String surveyId;
  final String studentId;
  final String studentName;
  final Map<String, dynamic> answers; // questionId -> answer (int for Likert, String for text/radio, List for checkbox)
  final String submittedAt;

  SurveyResponse({
    required this.id,
    required this.surveyId,
    required this.studentId,
    required this.studentName,
    required this.answers,
    required this.submittedAt,
  });

  factory SurveyResponse.fromJson(Map<String, dynamic> json, [String? id]) {
    return SurveyResponse(
      id: id ?? json['id']?.toString() ?? '',
      surveyId: json['surveyId']?.toString() ?? json['survey_id']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? json['student_id']?.toString() ?? '',
      studentName: json['studentName']?.toString() ?? json['student_name']?.toString() ?? '',
      answers: (json['answers'] is Map) ? Map<String, dynamic>.from(json['answers']) : {},
      submittedAt: json['submittedAt']?.toString() ?? json['submitted_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surveyId': surveyId,
      'studentId': studentId,
      'studentName': studentName,
      'answers': answers,
      'submittedAt': submittedAt,
    };
  }
}
