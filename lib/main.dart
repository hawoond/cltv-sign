import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/document_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  runApp(const CltvSignApp());
}

class CltvSignApp extends StatelessWidget {
  const CltvSignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, DocumentProvider>(
          create: (_) => DocumentProvider(),
          update: (_, auth, docs) {
            docs ??= DocumentProvider();
            if (auth.isAuthenticated && auth.currentUser != null) {
              docs.loadDocuments(auth.currentUser!.id);
              docs.loadTemplates(auth.currentUser!.id);
            }
            return docs;
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final router = createRouter(context);
          return MaterialApp.router(
            title: 'cltv-sign',
            theme: AppTheme.lightTheme,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ko', 'KR'),
              Locale('en', 'US'),
            ],
            locale: const Locale('ko', 'KR'),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
