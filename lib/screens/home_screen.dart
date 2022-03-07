import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:mpmed_doctor/appbar/custom_app_bar.dart';
import 'package:mpmed_doctor/authOtp/stores/login_store.dart';
import 'package:mpmed_doctor/doctorsList/screen/doctors_list_screen.dart';
import 'package:mpmed_doctor/documents/provider/documents_provider.dart';
import 'package:mpmed_doctor/documents/screens/documents_by_user_screen.dart';
import 'package:mpmed_doctor/documents/screens/documents_screen.dart';
import 'package:mpmed_doctor/notification/model/push_notifiication_pojo.dart';
import 'package:mpmed_doctor/notification/widget/notification_badge.dart';
import 'package:mpmed_doctor/patientReport/screens/patient_report_by_user_screen.dart';
import 'package:mpmed_doctor/patientReport/screens/patient_report_screen.dart';
import 'package:mpmed_doctor/questions/screen/users_list_screen.dart';
import 'package:mpmed_doctor/widgets/app_drawer.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';


class MyHomePage extends StatefulWidget {
  static const String routeName = '/home_screen';

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _advancedDrawerController = AdvancedDrawerController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();



  @override
  void dispose() {
    _advancedDrawerController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdropColor: Colors.blueGrey,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: true,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
          // NOTICE: Uncomment if you want to add shadow behind the page.
          // Keep in mind that it may cause animation jerks.
          // boxShadow: <BoxShadow>[
          //   BoxShadow(
          //     color: Colors.black12,
          //     blurRadius: 0.0,
          //   ),
          // ],
          borderRadius: const BorderRadius.all(Radius.circular(16))),
      drawer: AppDrawer(),
      child: Scaffold(
        key: _scaffoldKey,
        body: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
                floating: true,
                pinned: false,
                delegate: CustomAppBar(
                    height: 120,
                    key: _scaffoldKey,
                    advancedDrawerController: _advancedDrawerController)),
            SliverFillRemaining(
              fillOverscroll: true,
              hasScrollBody: false,
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(UsersListQuestions.routeName);
                    },
                    child: Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height / 4,
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/img/one_ques.png'),
                                    fit: BoxFit.cover)),
                          )),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      margin: EdgeInsets.all(10),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      print("tap");
                      // Navigator.of(context)
                      //     .pushNamed(DocumentsScreen.routeName);
                      Navigator.of(context)
                          .pushNamed(DocumentsByUserScreen.routeName);
                    },
                    child: Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height / 4,
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/img/recieved_doc.png'),
                                    fit: BoxFit.cover)),
                          )),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      margin: EdgeInsets.all(10),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(PatientReportScreenByUser.routeName);
                    },
                    child: Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height / 4,
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/img/visit_brief.png'),
                                    fit: BoxFit.cover)),
                          )),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      margin: EdgeInsets.all(10),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(DoctorsListScreen.routeName);
                    },
                    child: Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height / 4,
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image:
                                        AssetImage('assets/img/doc_list.png'),
                                    fit: BoxFit.cover)),
                          )),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      margin: EdgeInsets.all(10),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
