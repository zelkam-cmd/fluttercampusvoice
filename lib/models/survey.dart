import 'question.dart';

class Survey {
  final String id;
  final String title;
  final String description;
  final String category;
  final String targetAudience;
  final String status; // 'active', 'closed', 'draft'
  final String startDate;
  final String endDate;
  final int responseCount;
  final List<SurveyQuestion> questions;

  Survey({
    required this.id,
    required this.title,
    required this.description,
    this.category = 'Campus Climate',
    this.targetAudience = 'All Students',
    this.status = 'active',
    required this.startDate,
    required this.endDate,
    this.responseCount = 0,
    this.questions = const [],
  });

  factory Survey.fromJson(Map<String, dynamic> json, [String? id]) {
    List<SurveyQuestion> questionList = [];
    if (json['questions'] != null) {
      if (json['questions'] is Map) {
        (json['questions'] as Map).forEach((qKey, qVal) {
          if (qVal is Map) {
            questionList.add(SurveyQuestion.fromJson(Map<String, dynamic>.from(qVal), qKey.toString()));
          }
        });
      } else if (json['questions'] is List) {
        for (var i = 0; i < (json['questions'] as List).length; i++) {
          var item = (json['questions'] as List)[i];
          if (item is Map) {
            questionList.add(SurveyQuestion.fromJson(Map<String, dynamic>.from(item), 'q_$i'));
          }
        }
      }
    }

    return Survey(
      id: id ?? json['id']?.toString() ?? json['survey_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Campus Survey',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      targetAudience: json['targetAudience']?.toString() ?? json['target_audience']?.toString() ?? 'All Students',
      status: json['status']?.toString() ?? 'active',
      startDate: json['startDate']?.toString() ?? json['start_date']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? json['end_date']?.toString() ?? '',
      responseCount: int.tryParse(json['responseCount']?.toString() ?? json['response_count']?.toString() ?? '0') ?? 0,
      questions: questionList,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> qMap = {};
    for (var i = 0; i < questions.length; i++) {
      qMap['q_$i'] = questions[i].toJson();
    }
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'targetAudience': targetAudience,
      'status': status,
      'startDate': startDate,
      'endDate': endDate,
      'responseCount': responseCount,
      'questions': qMap,
    };
  }
}
