class ApiConstant {
  static const String baseUrlLaravel = 'http:///10.124.107.2:8000/api';
  static const String publicApiUrl = 'https://api.spaceflightnewsapi.net/v4/articles';

  // Auth Endpoints
  static const String register = '$baseUrlLaravel/register';
  static const String login = '$baseUrlLaravel/login';
  static const String logout = '$baseUrlLaravel/logout';
  static const String user = '$baseUrlLaravel/user';

  // CRUD Endpoints
  static const String missions = '$baseUrlLaravel/missions';
  static const String clippedNews = '$baseUrlLaravel/clipped-news';
}