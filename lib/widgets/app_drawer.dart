import 'package:flutter/material.dart';
import 'package:mpmed_doctor/doctorsList/screen/doctors_list_screen.dart';
import 'package:mpmed_doctor/documents/screens/documents_by_user_screen.dart';
import 'package:mpmed_doctor/documents/screens/documents_screen.dart';
import 'package:mpmed_doctor/patientReport/screens/patient_report_by_user_screen.dart';
import 'package:mpmed_doctor/profile/screens/doctor_profile_screen.dart';
import 'package:mpmed_doctor/screens/home_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(30),
              decoration: new BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20.0,
                    // shadow
                    spreadRadius: .5,
                    // set effect of extending the shadow
                    offset: Offset(
                      0.0,
                      5.0,
                    ),
                  )
                ],
              ),
              height: 150,
              child: Image.asset(
                'assets/img/drawer_logo.png',
                fit: BoxFit.fill,
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("خانه"),
              onTap: () {
                Navigator.of(context).pushNamed(MyHomePage.routeName);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person_sharp),
              title: Text("ویرایش حساب کاربری"),
              onTap: () {
                Navigator.of(context).pushNamed(DoctorProfileScreen.routeName);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('ویزیت آنلاین'),
              onTap: () {
                // Navigator.of(context).pushReplacementNamed(routeName)
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.question_answer),
              title: Text('سوالات بیماران'),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.document_scanner),
              title: Text('مدارک ارسال شده'),
              onTap: () {
                Navigator.of(context).pushNamed(DocumentsByUserScreen.routeName);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.note),
              title: Text('گزارش ویزیت های حضوری'),
              onTap: () {
                Navigator.of(context)
                    .pushNamed(PatientReportScreenByUser.routeName);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('اسامی پزشکان'),
              onTap: () {
                Navigator.of(context)
                    .pushNamed(DoctorsListScreen.routeName);
              },
            )
          ],
        ),
      ),
    );
  }
}
