import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:memorize_up/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:memorize_up/firebase_options.dart';
import 'package:memorize_up/model/database.dart';
import 'package:memorize_up/signin.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

const testMode = true;
var theme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color.fromARGB(255, 30, 40, 50),
  dialogBackgroundColor: const Color.fromARGB(255, 30, 40, 50),
  canvasColor: const Color.fromARGB(255, 30, 40, 50),
  shadowColor: const Color.fromARGB(255, 30, 40, 50),
  highlightColor: Colors.white30,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 20.0, overflow: TextOverflow.visible, color: Colors.white70),
    displayMedium: TextStyle(fontSize: 16.0, overflow: TextOverflow.visible, color: Colors.white70),
    displaySmall: TextStyle(fontSize: 12.0, overflow: TextOverflow.visible, color: Colors.white70),
    labelMedium: TextStyle(fontSize: 14.0, color: Color.fromRGBO(120, 120, 120, 1),
                  overflow: TextOverflow.visible),
    labelSmall: TextStyle(fontSize: 12.0, overflow: TextOverflow.visible, color: Color.fromRGBO(120, 120, 120, 1))
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 50, 60, 70),
    scrolledUnderElevation: 0.0
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color.fromARGB(255, 25, 35, 45),
    actionBackgroundColor: Color.fromARGB(255, 50, 60, 70),
    actionTextColor: Colors.white70
  ),
  navigationDrawerTheme: const NavigationDrawerThemeData(
    backgroundColor: Color.fromARGB(255, 30, 40, 50),
    indicatorColor: Color.fromARGB(255, 50, 60, 70),
    iconTheme: WidgetStatePropertyAll(IconThemeData(
      color: Colors.white70
    ))
  ),
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: Colors.white30),
      borderRadius: BorderRadius.circular(20.0)
    ),
    color: const Color.fromARGB(255, 25, 35, 45),
  ),
  dropdownMenuTheme: const DropdownMenuThemeData(
    textStyle: TextStyle(fontSize: 16.0)
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.white70,
    selectionColor: Colors.white70,
    selectionHandleColor: Colors.white70
  ),
  inputDecorationTheme: const InputDecorationTheme(
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white70)
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white70)
    ),
    disabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white70)
    )
  ),
  elevatedButtonTheme: const ElevatedButtonThemeData(
    style: ButtonStyle(
      iconColor: WidgetStatePropertyAll(Colors.white70),
      backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 20, 30, 40)),
      overlayColor: WidgetStatePropertyAll(Colors.white10)
    )
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      iconColor: const WidgetStatePropertyAll(Colors.white70),
      overlayColor: const WidgetStatePropertyAll(Colors.white10),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white70),
        borderRadius: BorderRadius.circular(20.0),
      ))
    )
  ),
  textButtonTheme: const TextButtonThemeData(
    style: ButtonStyle(
      iconColor: WidgetStatePropertyAll(Colors.white70),
      overlayColor: WidgetStatePropertyAll(Colors.white10),
    )
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color.fromARGB(255, 50, 60, 70),
    foregroundColor: Colors.white70,
    splashColor: Colors.white10,
    hoverColor: Colors.white10,
    focusColor: Colors.white10,
  ),
  iconTheme: const IconThemeData(
    color: Colors.white70
  ),
  iconButtonTheme: const IconButtonThemeData(
    style: ButtonStyle(
      iconColor: WidgetStatePropertyAll(Colors.white70)
    )
  ),
  menuTheme: const MenuThemeData(
    style: MenuStyle(
      backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 50, 60, 70)),
    )
  ),
  dividerTheme: const DividerThemeData(
    color: Colors.white70
  ),
);

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  
  if (testMode) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  } else {

    await FirebaseAppCheck.instance.activate(
      appleProvider: AppleProvider.appAttest
    );

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  if (FirebaseAuth.instance.currentUser != null && await checkUserInDatabase()) {
    await updateUserEmail(email: FirebaseAuth.instance.currentUser!.email!);
  }

  runApp(MaterialApp(
    theme: theme,
    home: FirebaseAuth.instance.currentUser == null ? const SignIn() : const Home()
  ));
}