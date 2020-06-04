import 'package:faculty/home.dart';
import 'package:faculty/postAttendance.dart';
import 'package:faculty/showAttendance.dart';
import 'package:faculty/viewAndEditCourse.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: MaterialApp(
          title: "VNR CSE",
          home: Home(),
          debugShowCheckedModeBanner: false,
          routes: {
            "home": (context) => Home(),
            "postAttendance": (context) =>
                PostAttendance(ModalRoute.of(context).settings.arguments),
            "showAttendance": (context) =>
                ShowAttendance(ModalRoute.of(context).settings.arguments),
            "courseDetails": (context) =>
                ViewAndEditCourse(ModalRoute.of(context).settings.arguments),
          },
        ));
  }
}
