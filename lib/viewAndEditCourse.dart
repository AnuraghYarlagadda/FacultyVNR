import 'dart:collection';
import 'package:faculty/DataModels/courseDetails.dart';
import 'package:faculty/DataModels/studentDetails.dart';
import 'package:faculty/Utils/StoragePermissions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewAndEditCourse extends StatefulWidget {
  final LinkedHashMap args;
  const ViewAndEditCourse(this.args);
  ViewAndEditCourseState createState() => ViewAndEditCourseState();
}

class ViewAndEditCourseState extends State<ViewAndEditCourse> {
  CourseDetails courseDetails;
  String courseName, year;
  final fb = FirebaseDatabase.instance;
  Future<void> _launched;
  List phone;
  LinkedHashSet students;
  List studentDetails;

  @override
  void initState() {
    super.initState();
    this.studentDetails = [];
    grantStoragePermissionAndCreateDir(context);
    this.students = new LinkedHashSet<StudentDetails>();
    this.phone = [];
    print(widget.args);
    if (widget.args != null) {
      if (widget.args["courseName"] != null) {
        this.courseName = widget.args["courseName"];
        getData(this.courseName);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  getData(String courseName) {
    final ref = fb.reference();
    String id = courseName.trim().toLowerCase();
    ref.child("Courses").child(id).once().then((DataSnapshot data) {
      setState(() {
        this.courseDetails = CourseDetails.fromSnapshot(data);
        this.courseName = this.courseDetails.courseName;
        this.year = this.courseDetails.year;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.courseName.toUpperCase(),
            style: GoogleFonts.sourceCodePro()),
      ),
      body: this.courseDetails == null
          ? Center(
              child: SpinKitDualRing(
              color: Colors.pink,
            ))
          : Padding(
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Card(
                      elevation: 5,
                      child: ListTile(
                          title: Text(
                            this.courseDetails.trainerName,
                            style: GoogleFonts.manrope(
                                textStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w500)),
                          ),
                          trailing: IconButton(
                              icon: Icon(Icons.phone),
                              color: Colors.green,
                              onPressed: () {
                                if (this.courseDetails.phone.length == 1) {
                                  _launched = _makePhoneCall(
                                      'tel:' + this.courseDetails.phone[0]);
                                } else {
                                  showContacts(
                                      context, this.courseDetails.phone);
                                }
                              })),
                    ),
                    Card(
                        elevation: 5,
                        child: ListTile(
                            title: Text(
                          this.courseDetails.venue,
                          style: GoogleFonts.manrope(
                              textStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w500)),
                        ))),
                    Card(
                        elevation: 5,
                        child: ListTile(
                          title: Text(
                            "Post Attendance",
                            style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w600)),
                          ),
                          trailing: IconButton(
                              icon: Icon(
                                Icons.group,
                                color: Colors.teal,
                              ),
                              onPressed: () {
                                if (this.courseDetails.lock) {
                                  Fluttertoast.showToast(
                                      msg: "Course is locked by Admin!",
                                      toastLength: Toast.LENGTH_SHORT,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white);
                                } else {
                                  Navigator.of(context)
                                      .pushNamed("postAttendance", arguments: {
                                    "route": "courseDetails",
                                    "courseName": this.courseName,
                                    "year": this.year,
                                  });
                                }
                              }),
                        )),
                    Card(
                        elevation: 5,
                        child: ListTile(
                          title: Text(
                            "Show Present Attendance",
                            style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w600)),
                          ),
                          trailing: IconButton(
                              icon: Icon(
                                Icons.person_outline,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                if (this.courseDetails.lock) {
                                  Fluttertoast.showToast(
                                      msg: "Course is locked by Admin!",
                                      toastLength: Toast.LENGTH_SHORT,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white);
                                } else {
                                  Navigator.of(context)
                                      .pushNamed("showAttendance", arguments: {
                                    "route": "courseDetails",
                                    "courseName": this.courseName,
                                    "what": "present"
                                  });
                                }
                              }),
                        )),
                    Card(
                        elevation: 5,
                        child: ListTile(
                          title: Text(
                            "Show Absent Attendance",
                            style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w600)),
                          ),
                          trailing: IconButton(
                              icon: Icon(
                                Icons.person_outline,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                if (this.courseDetails.lock) {
                                  Fluttertoast.showToast(
                                      msg: "Course is locked by Admin!",
                                      toastLength: Toast.LENGTH_SHORT,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white);
                                } else {
                                  Navigator.of(context)
                                      .pushNamed("showAttendance", arguments: {
                                    "route": "courseDetails",
                                    "courseName": this.courseName,
                                    "what": "absent"
                                  });
                                }
                              }),
                        ))
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  showContacts(BuildContext context, List phone) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text("Multiple Numbers"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: phone.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(phone[index]),
                          trailing: IconButton(
                              icon: Icon(Icons.phone),
                              color: Colors.green,
                              onPressed: () {
                                _launched =
                                    _makePhoneCall('tel:' + phone[index]);
                                Navigator.of(context).pop(); // dismiss dialog
                              }),
                        );
                      }),
                )
              ],
            ));
      },
    );
  }
}
