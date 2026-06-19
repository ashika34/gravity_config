class ApiConstants {
  static const String baseUrl = 'https://gravity.lijutharayil.com';

  static const String login = '/api/login';
  static const String seatDesigns = '/api/seat-designs';

  static String seatDesignDetail(int id) => '/api/seat-designs/$id';

  // Fixed credentials as per spec
  static const String loginEmail = 'user@gmail.com';
  static const String loginPassword = 'password123';
}
