import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/professional_dashboard_screen.dart';
import 'screens/parent_dashboard_screen.dart';
import 'screens/observations_screen.dart';
import 'screens/social_scenarios_screen.dart';
import 'screens/create_social_scenario_screen.dart';
import 'screens/ai_analysis_screen.dart';
import 'screens/rag_chat_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_users_screen.dart';
import 'screens/admin/admin_knowledge_screen.dart';
import 'screens/admin/admin_monitoring_screen.dart';
import 'screens/comfort/comfort_dashboard_screen.dart';
import 'screens/comfort/routines_screen.dart';
import 'screens/comfort/comfort_items_screen.dart';
import 'screens/stock/stock_dashboard_screen.dart';
import 'screens/stock/stock_checklists_screen.dart';
import 'models/child_model.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: AbaTrackingApp(),
    ),
  );
}

class AbaTrackingApp extends ConsumerWidget {
  const AbaTrackingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'ABA Tracking',
          theme: theme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/professional-dashboard',
              builder: (context, state) => const ProfessionalDashboardScreen(),
            ),
            GoRoute(
              path: '/parent-dashboard',
              builder: (context, state) => const ParentDashboardScreen(),
            ),
    GoRoute(
      path: '/observations/:childId',
      builder: (context, state) {
        final childId = state.pathParameters['childId']!;
        return ObservationsScreen(childId: int.parse(childId));
      },
    ),
    GoRoute(
      path: '/social-scenarios',
      builder: (context, state) => const SocialScenariosScreen(),
    ),
    GoRoute(
      path: '/create-social-scenario',
      builder: (context, state) => const CreateSocialScenarioScreen(),
    ),
    GoRoute(
      path: '/ai-analysis',
      builder: (context, state) => const AIAnalysisScreen(),
    ),
            GoRoute(
              path: '/ai-analysis/:childId',
              builder: (context, state) {
                final childId = state.pathParameters['childId']!;
                return AIAnalysisScreen(childId: int.parse(childId));
              },
            ),
            GoRoute(
              path: '/subscriptions',
              builder: (context, state) => const SubscriptionScreen(),
            ),
            GoRoute(
              path: '/rag-chat',
              builder: (context, state) => const RAGChatScreen(),
            ),
            GoRoute(
              path: '/rag-chat/:childId',
              builder: (context, state) {
                final childId = state.pathParameters['childId']!;
                return RAGChatScreen(childId: int.parse(childId));
              },
            ),
            // Routes d'administration
            GoRoute(
              path: '/admin',
              builder: (context, state) => const AdminDashboardScreen(),
            ),
            GoRoute(
              path: '/admin/users',
              builder: (context, state) => const AdminUsersScreen(),
            ),
            GoRoute(
              path: '/admin/knowledge',
              builder: (context, state) => const AdminKnowledgeScreen(),
            ),
            GoRoute(
              path: '/admin/monitoring',
              builder: (context, state) => const AdminMonitoringScreen(),
            ),
            // Routes de confort
            GoRoute(
              path: '/children/:childId/comfort',
              builder: (context, state) {
                final childId = state.pathParameters['childId']!;
                final child = Child(id: int.parse(childId), name: 'Enfant', age: 5); // TODO: Récupérer l'enfant depuis l'état
                return ComfortDashboardScreen(child: child);
              },
            ),
            GoRoute(
              path: '/children/:childId/comfort/routines',
              builder: (context, state) {
                final childId = state.pathParameters['childId']!;
                final child = Child(id: int.parse(childId), name: 'Enfant', age: 5); // TODO: Récupérer l'enfant depuis l'état
                return RoutinesScreen(child: child);
              },
            ),
            GoRoute(
              path: '/children/:childId/comfort/items',
              builder: (context, state) {
                final childId = state.pathParameters['childId']!;
                final child = Child(id: int.parse(childId), name: 'Enfant', age: 5); // TODO: Récupérer l'enfant depuis l'état
                return ComfortItemsScreen(child: child);
              },
            ),
            // Routes de vérification de stock
            GoRoute(
              path: '/children/:childId/stock',
              builder: (context, state) {
                final childId = state.pathParameters['childId']!;
                final child = Child(id: int.parse(childId), name: 'Enfant', age: 5); // TODO: Récupérer l'enfant depuis l'état
                return StockDashboardScreen(child: child);
              },
            ),
            GoRoute(
              path: '/children/:childId/stock/checklists',
              builder: (context, state) {
                final childId = state.pathParameters['childId']!;
                final child = Child(id: int.parse(childId), name: 'Enfant', age: 5); // TODO: Récupérer l'enfant depuis l'état
                return StockChecklistsScreen(child: child);
              },
            ),
  ],
  redirect: (context, state) {
    // Redirection simple - la logique de redirection sera gérée dans les écrans individuels
    return null;
  },
);