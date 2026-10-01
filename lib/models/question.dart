class SurveyQuestion {
  final String id;
  final String surveyId;
  final String questionText;
  final String questionType; // 'likert', 'radio', 'checkbox', 'text'
  final List<String> options;
  final bool isRequired;
  final int orderIndex;

  SurveyQuestion({
    required this.id,
    required this.surveyId,
    required this.questionText,
    required this.questionType,
    this.options = const [],
    this.isRequired = true,
    this.orderIndex = 0,
  });

  factory SurveyQuestion.fromJson(Map<String, dynamic> json, [String? id]) {
    List<String> parsedOptions = [];
    if (json['options'] != null) {
      if (json['options'] is List) {
        parsedOptions = (json['options'] as List).map((e) => e.toString()).toList();
      } else if (json['options'] is Map) {
        parsedOptions = (json['options'] as Map).values.map((e) => e.toString()).toList();
      }
    }

    return SurveyQuestion(
      id: id ?? json['id']?.toString() ?? json['question_id']?.toString() ?? '',
      surveyId: json['surveyId']?.toString() ?? json['survey_id']?.toString() ?? '',
      questionText: json['questionText']?.toString() ?? json['question_text']?.toString() ?? '',
      questionType: json['questionType']?.toString() ?? json['question_type']?.toString() ?? 'likert',
      options: parsedOptions,
      isRequired: json['isRequired'] == true || json['is_required'] == 1 || json['is_required'] == '1',
      orderIndex: int.tryParse(json['orderIndex']?.toString() ?? json['order_index']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surveyId': surveyId,
      'questionText': questionText,
      'questionType': questionType,
      'options': options,
      'isRequired': isRequired,
      'orderIndex': orderIndex,
    };
  }
}
