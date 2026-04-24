class AppConstants {
  static const String appName = 'cltv-sign';
  static const String appTagline = '서명이 필요한 모든 곳에';
  static const String appDescription = '빠르고 안전한 전자서명 플랫폼';

  static const double maxContentWidth = 1200;
  static const double sidebarWidth = 240;
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;

  static const int signatureExpiryDays = 30;
  static const int maxFileSize = 10 * 1024 * 1024;
  static const List<String> supportedFileTypes = ['pdf', 'docx', 'hwp', 'jpg', 'png'];

  static const String demoEmail = 'demo@cltv-sign.com';
  static const String demoPassword = 'demo1234';
}

class AppRoutes {
  static const String landing = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String documents = '/documents';
  static const String documentDetail = '/documents/:id';
  static const String newDocument = '/documents/new';
  static const String signRequest = '/sign-request/:id';
  static const String signView = '/sign/:token';
  static const String signComplete = '/sign/complete';
  static const String templates = '/templates';
  static const String templateDetail = '/templates/:id';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String pricing = '/pricing';
  static const String notifications = '/notifications';
}
