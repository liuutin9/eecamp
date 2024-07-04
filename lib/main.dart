import 'package:eecamp/services/bluetooth_service.dart';
import 'package:eecamp/services/navigation_service.dart';
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

  // if your terminal doesn't support color you'll see annoying logs like `\x1B[1;35m`
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);

  // Provider.debugCheckInvalidValueType = null;
  
  runApp(const InitProvider());
}

class InitProvider extends StatelessWidget {
  const InitProvider({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        // ChangeNotifierProvider(
        //   create: (_) => ThemeProvider(
        //     theme: theme,
        //     themeMode: themeMode,
        //   ),
        // ),
        Provider<NavigationService>(
          create: (_) => NavigationService(),
        ),
        ChangeNotifierProvider(
          create: (_) => BluetoothProvider(),
        ),
        // ChangeNotifierProvider(
        //   create: (_) => LocaleProvider(
        //     currLocale: language,
        //     isSystemDefault: languageCode == 'default',
        //   ),
        // ),
      ],
      child: const EECampApp(
        // themeMode: themeMode,
      ),
    );

    // return MaterialApp(
    //   title: 'Bluetooth Controller',
    //   theme: ThemeData(
    //     colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    //     useMaterial3: true,
    //   ),
    //   home: const HomePage(),
    //   debugShowCheckedModeBanner: false,
    // );
  }
}

class EECampApp extends StatelessWidget {
  const EECampApp({super.key});
  
  @override
  Widget build(BuildContext context) {

    // final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp.router(
      // theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      // darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      // themeMode: Provider.of<ThemeProvider>(context).themeMode,

      debugShowCheckedModeBanner: false,
      routerConfig: routerConfig,

      // restorationScopeId: 'app',

      // locale: localeProvider.locale,
      // localizationsDelegates: const [
      //   AppLocalizationsDelegate(),
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: const [
      //   Locale('en'),
      //   Locale.fromSubtags(
      //     languageCode: 'zh',
      //     scriptCode: 'Hant',
      //     countryCode: 'TW'
      //   ),
      // ],
    );
  }

}