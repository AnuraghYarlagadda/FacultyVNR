import 'dart:collection';
import 'package:faculty/DataModels/courseCoordinatorsDetails.dart';
import 'package:faculty/Utils/Settings.dart';
import 'package:faculty/Utils/StoragePermissions.dart';
import 'package:faculty/Utils/login.dart';
import 'package:faculty/Utils/signin.dart';
import 'package:faculty/team.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'DataModels/courseCoordinatorsDetails.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

enum Status { data, nodata }

class HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> _children = [Home(), Team()];

  bool userLoggedIn;
  FirebaseUser user;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  String userEmail, userName;
  final fb = FirebaseDatabase.instance;
  CourseCoordinatorsDetails coordinatorsDetails;
  LinkedHashMap courses;
  int status;
  @override
  void initState() {
    super.initState();
    this.user = null;
    this.userLoggedIn = null;
    this.courses = new LinkedHashMap<dynamic, dynamic>();
    this.status = Status.nodata.index;
    checkUserStatus();
    grantStoragePermissionAndCreateDir(context);
  }

  checkUserStatus() async {
    await googleSignIn.isSignedIn().then((onValue) {
      setState(() {
        this.userLoggedIn = onValue;
      });
    });
    if (this.userLoggedIn == true) {
      await getUserDetails();
    }
  }

  getUserDetails() async {
    await FirebaseAuth.instance.currentUser().then((onValue) async {
      setState(() {
        this.user = onValue;
        this.userEmail = onValue.email;
        this.userName = onValue.displayName;
        Fluttertoast.showToast(
            msg: "Welcome " + this.userName,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.cyan,
            textColor: Colors.white);
      });
      await getCoordinatorCourses(this.userEmail);
    });
  }

  void handleClick(String value) async {
    await signOutGoogle().then((onValue) {
      Navigator.of(context).pushReplacementNamed("home");
    });
  }

  getCoordinatorCourses(String email) async {
    final ref = fb.reference();
    LinkedHashMap data =
        new LinkedHashMap<dynamic, CourseCoordinatorsDetails>();
    String id = email.replaceAll('.', ',');
    id = id.replaceAll('@', ',');
    id = id.replaceAll('#', ',');
    id = id.replaceAll('[', ',');
    id = id.replaceAll(']', ',');
    await ref.child("CourseCoordinators").once().then((onValue) async {
      if (onValue.value == null) {
        print(onValue.value);
      } else {
        data = onValue.value;
      }
    });
    if (data.containsKey(id)) {
      setState(() {
        this.coordinatorsDetails = CourseCoordinatorsDetails.fromJson(data[id]);
        this.courses = this.coordinatorsDetails.courses;
        this.status = Status.data.index;
      });
      print(this.coordinatorsDetails.email);
      print(this.courses.length);
    } else {
      this.status = Status.data.index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: this._currentIndex == 0
          ? AppBar(
              title: Text("Home",
                  style: GoogleFonts.acme(
                    textStyle: TextStyle(),
                  )),
              leading: Icon(Icons.home),
              actions: <Widget>[
                PopupMenuButton<String>(
                  onSelected: handleClick,
                  itemBuilder: (BuildContext context) {
                    return ['Sign-Out'].map((String choice) {
                      return PopupMenuItem<String>(
                        enabled: this.userLoggedIn,
                        height: MediaQuery.of(context).size.height / 18,
                        value: choice,
                        child: Text(choice,
                            style: GoogleFonts.slabo27px(
                              textStyle: TextStyle(fontSize: 15),
                            )),
                      );
                    }).toList();
                  },
                ),
              ],
            )
          : AppBar(
              title: Text("Team",
                  style: GoogleFonts.acme(
                    textStyle: TextStyle(),
                  )),
              leading: Icon(Icons.group)),
      body: this._currentIndex == 0
          ? this.userLoggedIn == null
              ? Center(
                  child: SpinKitFadingCube(color: Colors.cyan),
                )
              : this.userLoggedIn == false
                  ? Login()
                  : this.user == null
                      ? Center(
                          child: SpinKitFadingCube(color: Colors.cyan),
                        )
                      : this.status == Status.nodata.index
                          ? Center(
                              child: SpinKitFadingCube(color: Colors.cyan),
                            )
                          : this.courses.length == 0
                              ? Center(
                                  child: Text("😕 No Courses found..!",
                                      style: GoogleFonts.robotoSlab(
                                        textStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                          fontSize: 18,
                                        ),
                                      )))
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Scrollbar(
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: this.courses.length,
                                          itemBuilder: (context, index) {
                                            String key = this
                                                .courses
                                                .keys
                                                .elementAt(index);
                                            return Container(
                                                child: Card(
                                                    elevation: 5,
                                                    child: ListTile(
                                                      title: Text(
                                                          key.toUpperCase(),
                                                          style: GoogleFonts
                                                              .headlandOne(
                                                            textStyle: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 15,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          )),
                                                      trailing: IconButton(
                                                          icon: Icon(
                                                            Icons
                                                                .remove_red_eye,
                                                            color: Colors.blue,
                                                          ),
                                                          onPressed: () async {
                                                            await (Connectivity()
                                                                    .checkConnectivity())
                                                                .then(
                                                                    (onValue) {
                                                              if (onValue ==
                                                                  ConnectivityResult
                                                                      .none) {
                                                                Fluttertoast.showToast(
                                                                    msg:
                                                                        "No Active Internet Connection!",
                                                                    toastLength:
                                                                        Toast
                                                                            .LENGTH_SHORT,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red,
                                                                    textColor:
                                                                        Colors
                                                                            .white);
                                                                openWIFISettingsVNR();
                                                              } else {
                                                                if (this.courses[
                                                                        key] ==
                                                                    true) {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pushNamed(
                                                                          "courseDetails",
                                                                          arguments: {
                                                                        "courseName":
                                                                            key,
                                                                      });
                                                                } else {
                                                                  Fluttertoast.showToast(
                                                                      msg: key +
                                                                          " Entry Denied!",
                                                                      toastLength:
                                                                          Toast
                                                                              .LENGTH_LONG,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red,
                                                                      textColor:
                                                                          Colors
                                                                              .white);
                                                                }
                                                              }
                                                            });
                                                          }),
                                                    )));
                                          }),
                                    ),
                                  ],
                                )
          : this._children[this._currentIndex],
      bottomNavigationBar: (this.userLoggedIn != false)
          ? FancyBottomNavigation(
              onTabChangedListener: (position) {
                setState(() {
                  this._currentIndex = position;
                });
              },
              tabs: [
                TabData(iconData: Icons.home, title: "Home"),
                TabData(iconData: Icons.group, title: "Team")
              ],
              inactiveIconColor: Colors.blueGrey,
              textColor: Colors.blueGrey,
            )
          : Padding(padding: EdgeInsets.all(0)),
    );
  }
}
