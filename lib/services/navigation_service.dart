import 'package:eecamp/widgets/control_page/control_page.dart';
import 'package:eecamp/widgets/home_page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final routerConfig = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  debugLogDiagnostics: true,
  redirect: (context, state) {
    if (state.uri.path == '/') return '/home';
    return null;
  },
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri.path}'),
    ),
  ),
  routes: <RouteBase>[
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: HomePage(context: context),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.5, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;

          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);

          final exitTween = Tween(begin: Offset.zero, end: const Offset(-0.5, 0.0)).chain(CurveTween(curve: curve));
          final exitAnimation = secondaryAnimation.drive(exitTween);

          return SlideTransition(
            position: offsetAnimation,
            child: SlideTransition(
              position: exitAnimation,
              child: child,
            ),
          );
        },
      ),
      routes: <RouteBase>[
        GoRoute(
          path: 'controlPanel/:deviceId',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const ControlPage(),
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutQuart;

              final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              final offsetAnimation = animation.drive(tween);

              final exitTween = Tween(begin: Offset.zero, end: const Offset(-1.0, 0.0)).chain(CurveTween(curve: curve));
              final exitAnimation = secondaryAnimation.drive(exitTween);

              return SlideTransition(
                position: offsetAnimation,
                child: SlideTransition(
                  position: exitAnimation,
                  child: child,
                ),
              );
            },
          ),
        ),
      ],
    ),
  ],
);

class NavigationService {
  late final GoRouter _router;

  NavigationService() {
    _router = routerConfig;
  }

  void goHome() {
    _router.go('/home');
  }

  void goControlPanel({required String deviceId}) {
    _router.go('/home/controlPanel/$deviceId');
  }
}
