class ApiEndpoints {
  static const String baseUrl =
      "http://127.0.0.1:5000";

  // ================= AUTH =================

  static const String studentLogin =
      "$baseUrl/user/login/login";

  static const String facultyLogin =
      "$baseUrl/user/login/login";

  static const String parentLogin =
      "$baseUrl/user/login/login";

  static const String studentSignup =
      "$baseUrl/user/signup/signup";

  static const String facultySignup =
      "$baseUrl/user/signup_faculty/signup_faculty";

  static const String parentSignup =
      "$baseUrl/user/signup_parent/signup_parent";

  static const String parentConfirmEmail =
      "$baseUrl/user/confirm_email/confirm_email";

  static const String confirmPhone =
      "$baseUrl/user/confirm_phone/confirm_phone";

  static const String finalizeSignup =
      "$baseUrl/user/finalize_signup/finalize_signup";

  static const String logout =
      "$baseUrl/user/logout/logout";

  // ================= CLASS =================

  static const String createClass =
      "$baseUrl/user/create_class/create_class";

  static const String joinClass =
      "$baseUrl/user/join_class/join_class";

  static const String getFacultyClasses =
      "$baseUrl/user/get_class_faculty/get_class_faculty";

  static const String getStudentClasses =
      "$baseUrl/user/get_class_student/get_class_student";


  // ================= ASSIGNMENT =================

  /// Generate assignment (LLM)
  static const String generateAssignment =
      "$baseUrl/user/generate/assngen";
  static const String submitAssignment =
      "$baseUrl/user/update/uploadassn";

  /// Faculty → Get assignments
  static const String getFacultyAssignments =
      "$baseUrl/user/get_assignment_faculty/get_assignment_faculty";

  /// Student → Get assignments
  static const String getStudentAssignments =
      "$baseUrl/user/get_assignment_student/get_assignment_student";

  /// Assignment details (common)
  static const String getAssignmentDetails =
      "$baseUrl/user/get_assignment_details/get_assignment_details";

  static const String retrieveAssignments =
      "$baseUrl/user/retrieve/assnretrieve";

  static const String evaluateAssignment =
      "$baseUrl/user/evaluate/assneval";

  static const String sendAssignmentMail =
      "$baseUrl/user/send_mail/sendassn";

  static const String viewAssignment =
      "$baseUrl/user/view/viewassn";

  static const String getBatchMails =
      "$baseUrl/user/getbatchmails/getbatch_mails";
}
