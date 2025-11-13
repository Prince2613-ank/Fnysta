class ApiConstants {
  // Assuming a production base URL. Replace with your actual URL.
  static const String baseUrl = "https://fnysta-backend.onrender.com/";

  // Horoscope Endpoints
  static const String dailyHoroscope = "/api/horo/today/";
  static const String weeklyHoroscope = "/api/horo/weekly/";
  static const String monthlyHoroscope = "/api/horo/monthly/";
  static const String yearlyHoroscope = "/api/horo/yearly/";
  static const String sendOtp = "/api/auth/send-otp/";
  static const String verifyOtp = "/api/auth/verify-otp/";
  static const String getCoin = "/api/user/get-coin/";
  static const String updateCoin = "/api/user/Update-coin/";
  static const String updateUser = "/api/user/Update-user/";
}
