import 'package:eecamp/providers/bluetooth_provider.dart';
import 'package:eecamp/services/navigation_service.dart';
import 'package:eecamp/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(const InitProvider());
}

class InitProvider extends StatelessWidget {
  const InitProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NavigationService>(
          create: (_) => NavigationService(),
        ),
        ChangeNotifierProvider(
          create: (_) => BluetoothProvider(),
        ),
      ],
      child: const EECampApp(),
    );
  }
}

class EECampApp extends StatelessWidget {
  const EECampApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: routerConfig,
      theme: ThemeData(useMaterial3: true, colorScheme: MaterialTheme.lightScheme()),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: MaterialTheme.darkScheme()),
    );
  }
}