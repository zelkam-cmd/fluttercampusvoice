import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student.dart';
import '../models/survey.dart';
import '../models/question.dart';
import '../models/survey_response.dart';
import '../models/announcement.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  static const String baseUrl = 'https://flutter-33232-default-rtdb.firebaseio.com';

  /// Performs a GET request to Firebase RTDB
  Future<dynamic> _get(String path) async {
    final url = Uri.parse('$baseUrl/$path.json');
    final response = await http.get(url);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body == 'null' || response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      throw Exception('Firebase GET failed: ${response.statusCode} - ${response.body}');
    }
  }

  /// Performs a PUT request to Firebase RTDB
  Future<dynamic> _put(String path, dynamic data) async {
    final url = Uri.parse('$baseUrl/$path.json');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Firebase PUT failed: ${response.statusCode} - ${response.body}');
    }
  }

  /// Performs a POST request to Firebase RTDB
  Future<String?> _post(String path, dynamic data) async {
    final url = Uri.parse('$baseUrl/$path.json');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final resData = jsonDecode(response.body);
      return resData['name']?.toString();
    } else {
      throw Exception('Firebase POST failed: ${response.statusCode} - ${response.body}');
    }
  }

  /// Performs a DELETE request to Firebase RTDB
  Future<void> _delete(String path) async {
    final url = Uri.parse('$baseUrl/$path.json');
    final response = await http.delete(url);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Firebase DELETE failed: ${response.statusCode}');
    }
  }

  /// Checks if Firebase RTDB is empty and seeds initial data if needed
  Future<void> initializeSeedDataIfNeeded() async {
    try {
      final studentsData = await _get('students');
      if (studentsData == null) {
        // Seed default students
        final defaultStudent = Student(
          id: '2023-100234',
          studentNumber: '2023-100234',
          fullName: 'Jaredd Catalan',
          firstName: 'Jaredd',
          lastName: 'Catalan',
          email: 'jaredd.catalan@bulsu.edu.ph',
          department: 'College of Information and Communications Technology (CICT)',
          yearLevel: '3rd Year - BSIT',
          civilStatus: 'Single',
          contactNumber: '+63 912 345 6789',
          address: 'City of Malolos, Bulacan',
          gwa: 1.45,
          completedTasks: 8,
          role: 'student',
        );

        await _put('students/${defaultStudent.id}', {
          ...defaultStudent.toJson(),
          'password': 'password123',
        });

        // Seed demo Admin
        await _put('admins/admin_1', {
          'id': 'admin_1',
          'username': 'admin',
          'fullName': 'CampusVoice Administrator',
          'email': 'admin@campusvoice.bulsu.edu.ph',
          'password': 'admin123',
          'role': 'admin',
        });
      }

      final surveysData = await _get('surveys');
      if (surveysData == null) {
        // Seed 3 initial surveys
        final survey1 = Survey(
          id: 'srv_midterm_2026',
          title: 'Midterm Facilities & Learning Evaluation',
          description: 'Assess campus Wi-Fi, classroom ventilation, computer laboratories, and overall learning conditions.',
          category: 'Facilities & Academics',
          targetAudience: 'All CICT Students',
          status: 'active',
          startDate: '2026-09-15',
          endDate: '2026-10-15',
          responseCount: 38,
          questions: [
            SurveyQuestion(
              id: 'q1',
              surveyId: 'srv_midterm_2026',
              questionText: 'The classroom environment (lighting, air conditioning/ventilation, cleanliness) is conducive to learning.',
              questionType: 'likert',
              orderIndex: 0,
            ),
            SurveyQuestion(
              id: 'q2',
              surveyId: 'srv_midterm_2026',
              questionText: 'Computer lab hardware and software tools are up to date and functional during practical sessions.',
              questionType: 'likert',
              orderIndex: 1,
            ),
            SurveyQuestion(
              id: 'q3',
              surveyId: 'srv_midterm_2026',
              questionText: 'Campus Wi-Fi connectivity and bandwidth meet your academic and research needs.',
              questionType: 'likert',
              orderIndex: 2,
            ),
            SurveyQuestion(
              id: 'q4',
              surveyId: 'srv_midterm_2026',
              questionText: 'Which facility requires the most urgent renovation or upgrade?',
              questionType: 'radio',
              options: ['Computer Laboratories', 'Library & Study Hubs', 'Comfort Rooms', 'Canteen Dining Hall', 'Student Activity Center'],
              orderIndex: 3,
            ),
            SurveyQuestion(
              id: 'q5',
              surveyId: 'srv_midterm_2026',
              questionText: 'Please share any specific suggestions or comments for university administration:',
              questionType: 'text',
              isRequired: false,
              orderIndex: 4,
            ),
          ],
        );

        final survey2 = Survey(
          id: 'srv_canteen_2026',
          title: 'Campus Food Services & Hygiene Survey',
          description: 'Help the University Food Committee evaluate food pricing, nutritional value, and cafeteria hygiene.',
          category: 'Student Welfare',
          targetAudience: 'All Enrolled Students',
          status: 'active',
          startDate: '2026-09-20',
          endDate: '2026-10-25',
          responseCount: 64,
          questions: [
            SurveyQuestion(
              id: 'c1',
              surveyId: 'srv_canteen_2026',
              questionText: 'Canteen food prices are reasonable and affordable for students.',
              questionType: 'likert',
              orderIndex: 0,
            ),
            SurveyQuestion(
              id: 'c2',
              surveyId: 'srv_canteen_2026',
              questionText: 'Meals served adhere to clean food safety and sanitary standards.',
              questionType: 'likert',
              orderIndex: 1,
            ),
            SurveyQuestion(
              id: 'c3',
              surveyId: 'srv_canteen_2026',
              questionText: 'There is adequate seating capacity during peak lunch hours.',
              questionType: 'likert',
              orderIndex: 2,
            ),
          ],
        );

        final survey3 = Survey(
          id: 'srv_mentalhealth_2026',
          title: 'Guidance & Mental Well-being Support',
          description: 'Feedback on guidance counseling accessibility, wellness workshops, and stress relief initiatives.',
          category: 'Student Welfare',
          targetAudience: 'All Students',
          status: 'closed',
          startDate: '2026-08-01',
          endDate: '2026-09-01',
          responseCount: 92,
          questions: [
            SurveyQuestion(
              id: 'm1',
              surveyId: 'srv_mentalhealth_2026',
              questionText: 'Guidance counseling services are approachable and confidential.',
              questionType: 'likert',
              orderIndex: 0,
            ),
          ],
        );

        await _put('surveys/${survey1.id}', survey1.toJson());
        await _put('surveys/${survey2.id}', survey2.toJson());
        await _put('surveys/${survey3.id}', survey3.toJson());
      }

      final announcementsData = await _get('announcements');
      if (announcementsData == null) {
        final a1 = Announcement(
          id: 'ann_1',
          title: 'Midterm Survey Period is Active',
          content: 'CICT students are encouraged to accomplish the Facilities and Academic evaluation before Oct 15.',
          date: '2026-10-01',
          priority: 'high',
        );
        final a2 = Announcement(
          id: 'ann_2',
          title: 'BulSU CampusVoice Mobile App v1.0',
          content: 'Welcome to the official mobile application of CampusVoice. Submit responses on the go!',
          date: '2026-09-28',
          priority: 'normal',
        );

        await _put('announcements/${a1.id}', a1.toJson());
        await _put('announcements/${a2.id}', a2.toJson());
      }
    } catch (e) {
      // Seed failure or already seeded
    }
  }

  // ==================== SURVEYS ====================

  Future<List<Survey>> getSurveys() async {
    try {
      final data = await _get('surveys');
      if (data == null) return [];
      List<Survey> list = [];
      if (data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            list.add(Survey.fromJson(Map<String, dynamic>.from(value), key.toString()));
          }
        });
      }
      return list;
    } catch (e) {
      return [];
    }
  }

  Future<Survey?> getSurvey(String surveyId) async {
    try {
      final data = await _get('surveys/$surveyId');
      if (data == null) return null;
      return Survey.fromJson(Map<String, dynamic>.from(data), surveyId);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveSurvey(Survey survey) async {
    await _put('surveys/${survey.id}', survey.toJson());
  }

  Future<void> updateSurveyStatus(String surveyId, String status) async {
    final url = Uri.parse('$baseUrl/surveys/$surveyId/status.json');
    await http.put(url, body: jsonEncode(status));
  }

  Future<void> deleteSurvey(String surveyId) async {
    await _delete('surveys/$surveyId');
  }

  // ==================== RESPONSES ====================

  Future<void> submitResponse(SurveyResponse response) async {
    await _post('responses', response.toJson());
    // Increment responseCount on survey
    try {
      final currentSurvey = await getSurvey(response.surveyId);
      if (currentSurvey != null) {
        final newCount = currentSurvey.responseCount + 1;
        final url = Uri.parse('$baseUrl/surveys/${response.surveyId}/responseCount.json');
        await http.put(url, body: jsonEncode(newCount));
      }
    } catch (_) {}
  }

  Future<List<SurveyResponse>> getResponsesForSurvey(String surveyId) async {
    try {
      final data = await _get('responses');
      if (data == null) return [];
      List<SurveyResponse> list = [];
      if (data is Map) {
        data.forEach((key, value) {
          if (value is Map && value['surveyId'] == surveyId) {
            list.add(SurveyResponse.fromJson(Map<String, dynamic>.from(value), key.toString()));
          }
        });
      }
      return list;
    } catch (e) {
      return [];
    }
  }

  Future<List<SurveyResponse>> getResponsesForStudent(String studentId) async {
    try {
      final data = await _get('responses');
      if (data == null) return [];
      List<SurveyResponse> list = [];
      if (data is Map) {
        data.forEach((key, value) {
          if (value is Map && (value['studentId'] == studentId || value['student_id'] == studentId)) {
            list.add(SurveyResponse.fromJson(Map<String, dynamic>.from(value), key.toString()));
          }
        });
      }
      return list;
    } catch (e) {
      return [];
    }
  }

  Future<int> getTotalResponsesCount() async {
    try {
      final data = await _get('responses');
      if (data == null) return 0;
      if (data is Map) return data.length;
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // ==================== STUDENTS ====================

  Future<Student?> getStudent(String id) async {
    try {
      final data = await _get('students/$id');
      if (data != null && data is Map) {
        return Student.fromJson(Map<String, dynamic>.from(data), id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Student>> getAllStudents() async {
    try {
      final data = await _get('students');
      if (data == null) return [];
      List<Student> list = [];
      if (data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            list.add(Student.fromJson(Map<String, dynamic>.from(value), key.toString()));
          }
        });
      }
      return list;
    } catch (e) {
      return [];
    }
  }

  Future<void> updateStudent(Student student) async {
    await _put('students/${student.id}', student.toJson());
  }

  // ==================== ANNOUNCEMENTS ====================

  Future<List<Announcement>> getAnnouncements() async {
    try {
      final data = await _get('announcements');
      if (data == null) return [];
      List<Announcement> list = [];
      if (data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            list.add(Announcement.fromJson(Map<String, dynamic>.from(value), key.toString()));
          }
        });
      }
      return list;
    } catch (e) {
      return [];
    }
  }
}
