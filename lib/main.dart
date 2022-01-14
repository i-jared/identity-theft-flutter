import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:id_theft/general/enums.dart';
import 'package:id_theft/pages/group_page.dart';
import 'package:id_theft/state/tracker_state.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInAnonymously();
  await Hive.initFlutter();
  Hive.registerAdapter(NumberStatusAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: ChangeNotifierProvider(
        create: (context) => TrackerState(),
        child: MaterialApp(
          color: Colors.white,
          title: 'Hacker Tracker',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const GroupPage(),
        ),
      ),
    );
  }
}
