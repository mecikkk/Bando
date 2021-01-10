import 'package:bando/core/utils/generate_screen.dart';
import 'package:bando/di.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:koin_flutter/koin_flutter.dart';

import 'bloc_observer.dart';
import 'core/utils/app_theme.dart';
import 'core/utils/localization.dart';
import 'features/authorization/presentation/blocs/auth/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();
  await Firebase.initializeApp();
  await initDi();

  runApp(BandoApp());
}

class BandoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final GenerateScreen _generateScreen = GenerateScreen(getKoin());

    return BlocProvider(
      create: (context) => get<AuthBloc>(),
      child: MaterialApp(
        title: 'Bando',
        initialRoute: Pages.SPLASH,
        onGenerateRoute: _generateScreen.onGenerate,
        debugShowCheckedModeBanner: false,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: ThemeMode.system,
        supportedLocales: [
          Locale('en'),
          Locale('pl'),
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        localeResolutionCallback: (Locale locale, Iterable<Locale> supportedLocales) {
          if (locale == null) {
            return supportedLocales.first;
          }

          for (Locale supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode ||
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        builder: (context, child) {
          return ScrollConfiguration(behavior: MyBehavior(), child: child);
        },
      ),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
