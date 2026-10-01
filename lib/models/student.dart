class Student {
  final String id;
  final String studentNumber;
  final String fullName;
  final String firstName;
  final String lastName;
  final String email;
  final String department;
  final String yearLevel;
  final String civilStatus;
  final String contactNumber;
  final String address;
  final double gwa;
  final int completedTasks;
  final String? profilePhoto;
  final String role; // 'student' or 'admin'

  Student({
    required this.id,
    required this.studentNumber,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.department,
    required this.yearLevel,
    this.civilStatus = 'Single',
    this.contactNumber = '',
    this.address = '',
    this.gwa = 1.45,
    this.completedTasks = 8,
    this.profilePhoto,
    this.role = 'student',
  });

  factory Student.fromJson(Map<String, dynamic> json, [String? id]) {
    return Student(
      id: id ?? json['id']?.toString() ?? json['student_id']?.toString() ?? '',
      studentNumber: json['studentNumber']?.toString() ?? json['student_number']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['full_name']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? json['first_name']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      department: json['department']?.toString() ?? 'CICT',
      yearLevel: json['yearLevel']?.toString() ?? json['year_level']?.toString() ?? '3rd Year',
      civilStatus: json['civilStatus']?.toString() ?? json['civil_status']?.toString() ?? 'Single',
      contactNumber: json['contactNumber']?.toString() ?? json['contact_number']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      gwa: (json['gwa'] != null) ? double.tryParse(json['gwa'].toString()) ?? 1.45 : 1.45,
      completedTasks: (json['completedTasks'] != null)
          ? int.tryParse(json['completedTasks'].toString()) ?? 8
          : (json['completed_tasks'] != null)
              ? int.tryParse(json['completed_tasks'].toString()) ?? 8
              : 8,
      profilePhoto: json['profilePhoto'] ?? json['profile_photo'],
      role: json['role']?.toString() ?? 'student',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentNumber': studentNumber,
      'fullName': fullName,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'department': department,
      'yearLevel': yearLevel,
      'civilStatus': civilStatus,
      'contactNumber': contactNumber,
      'address': address,
      'gwa': gwa,
      'completedTasks': completedTasks,
      'profilePhoto': profilePhoto,
      'role': role,
    };
  }
}
