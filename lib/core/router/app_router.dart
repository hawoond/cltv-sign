import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../features/landing/screens/landing_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/document/screens/documents_screen.dart';
import '../../features/document/screens/document_detail_screen.dart';
import '../../features/document/screens/new_document_screen.dart';
import '../../features/document/screens/sign_request_screen.dart';
import '../../features/sign/screens/sign_view_screen.dart';
import '../../features/sign/screens/sign_complete_screen.dart';
import '../../features/template/screens/templates_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../constants/app_constants.dart';
import 'main_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) {
      final auth = context.read<AuthProvider>();
      final isAuth = auth.isAuthenticated;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;
      final isPublicRoute = state.matchedLocation == AppRoutes.landing ||
          state.matchedLocation == AppRoutes.pricing ||
          state.matchedLocation.startsWith('/sign/');

      if (!isAuth && !isAuthRoute && !isPublicRoute) {
        return AppRoutes.login;
      }
      if (isAuth && isAuthRoute) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.landing,
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/sign/complete/:token',
        builder: (context, state) => SignCompleteScreen(
          token: state.pathParameters['token'],
        ),
      ),
      GoRoute(
        path: '/sign/:token',
        builder: (context, state) => SignViewScreen(
          token: state.pathParameters['token'] ?? '',
        ),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.documents,
            builder: (context, state) => const DocumentsScreen(),
          ),
          GoRoute(
            path: '/documents/new',
            builder: (context, state) => const NewDocumentScreen(),
          ),
          GoRoute(
            path: '/documents/:id',
            builder: (context, state) => DocumentDetailScreen(
              documentId: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(
            path: '/sign-request/:id',
            builder: (context, state) => SignRequestScreen(
              documentId: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(
            path: AppRoutes.templates,
            builder: (context, state) => const TemplatesScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
