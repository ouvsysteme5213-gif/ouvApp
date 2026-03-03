import 'package:authentication/authentication.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:ouv_dooks/firebase_options.dart';
import 'package:ouv_dooks/splash_screen.dart';
import 'package:ouv_dooks/vieux/ouvCitaions/ouv_citations.dart';
import 'package:ouv_dooks/vieux/ouvDooks_Home_nav.dart';
import 'package:ouv_dooks/vieux/segnupLogin/ouv_emails.dart';
import 'package:ouv_dooks/vieux/segnupLogin/ouv_login.dart';
import 'package:ouv_dooks/vieux/segnupLogin/ouv_nouveauPassWord.dart';
import 'package:ouv_dooks/vieux/segnupLogin/ouv_segnup.dart';
import 'package:provider/provider.dart';
import 'package:shared_ui/shared_ui.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use one of the predefined enum values instead of trying to create one
    final OuvApp monApp = OuvApp.dooks; // Or whichever app you want
    final homeNavBar = OuvDooksHomeNav(
      pages: [
        OuvCitations(myApp: monApp,),
        Center(child: Text("Livres")),
        Center(child: Text("Paramètres"))
      ],
    );

    return MultiProvider(
      providers: AuthProviders.providers,
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: OuvThemes.lightTheme,
        darkTheme: OuvThemes.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/login': (context) => OuvLogin(app: monApp),
          '/signup': (context) => OuvSegnup(app: monApp),
          '/forgot-password': (context) => OuvEmails(app: monApp),
          '/reset-password': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as String?;
            return OuvNouveauPassWord(
              app: monApp,
              email: args ?? '',
            );
          },
          '/home': (context) => homeNavBar,
        },
      ),
    );
  }
}
