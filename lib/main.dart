import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xapp/Config.dart';
import 'package:xapp/Home.dart';
import 'package:xapp/providers/AuthProvider.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/providers/FunctionProvider.dart';
import 'package:xapp/widget/Error.dart';
import 'package:xapp/widget/Splashscreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done || _loading) {
          return Splashscreen(
            isAnimate: true,
            onEndAnimation: () => setState(() => _loading = false),
          );
        }

        if (snapshot.hasError) {
          return Error();
        }

        final FirebaseAuth auth = FirebaseAuth.instance;
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        final FirebaseFunctions functions = FirebaseFunctions.instance;

        if (!Config.production) {
          print('Debug release');

          String host = defaultTargetPlatform == TargetPlatform.android
              ? '10.0.2.2:8080'
              : 'localhost:8080';

          firestore.settings = Settings(
            host: host,
            sslEnabled: false,
          );

          functions.useFunctionsEmulator(origin: 'http://localhost:5001');
        }

        final AuthProvider authProvider = AuthProvider(auth: auth);

        // authProvider.logout();

        final TextTheme textTheme = TextTheme(
          button: TextStyle(
            fontSize: 16.0,
          ),
          headline1: TextStyle(
            fontSize: 50.0,
          ),
          bodyText2: TextStyle(
            fontSize: 16.0,
          ),
        );

        return MultiProvider(
          providers: [
            Provider<AuthProvider>(
              create: (_) => authProvider,
            ),
            Provider<FirestoreProvider>(
              create: (_) => FirestoreProvider(
                firestore: firestore,
                authProvider: authProvider,
              ),
            ),
            Provider<FunctionProvider>(
              create: (_) => FunctionProvider(
                functions: functions,
                auth: authProvider,
              ),
            )
          ],
          child: MaterialApp(
            title: 'Flutter Demo',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('fr', ''),
            ],
            theme: ThemeData(
              primaryColor: Color(Config.primaryColor),
              accentColor: Color(0xFFFF8F00),
              textTheme: textTheme,
              buttonTheme: ButtonThemeData(
                buttonColor: Color(Config.primaryColor),
                textTheme: ButtonTextTheme.primary,
              ),
            ),
            home: Builder(
              builder: (context) => StreamBuilder(
                stream: Provider.of<FirestoreProvider>(context).user,
                builder: (context, snapshotUser) {
                  print('Initialize user connection');
                  if (snapshotUser.connectionState != ConnectionState.active) {
                    return Splashscreen();
                  }

                  if (snapshotUser.hasError) {
                    return Error();
                  }

                  return Home();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
