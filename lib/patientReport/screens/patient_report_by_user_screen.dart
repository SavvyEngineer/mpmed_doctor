import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:mpmed_doctor/appbar/universal_app_bar.dart';
import 'package:mpmed_doctor/authOtp/widgets/loader_hud.dart';
import 'package:mpmed_doctor/patientReport/providers/patient_report_provider.dart';
import 'package:mpmed_doctor/patientReport/screens/patient_report_screen.dart';
import 'package:mpmed_doctor/patientReport/screens/report_form_screen.dart';
import 'package:mpmed_doctor/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

class PatientReportScreenByUser extends StatefulWidget {
  static const String routeName = '/patients_with_report';

  @override
  _PatientReportScreenByUserState createState() =>
      _PatientReportScreenByUserState();
}

class _PatientReportScreenByUserState extends State<PatientReportScreenByUser> {
  bool isInit = true;

  final _advancedDrawerController = AdvancedDrawerController();
  GlobalKey<ScaffoldState> _documentsListscaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    if (isInit) {
      fetchDataFromServer();
    }
    isInit = false;
    super.didChangeDependencies();
  }

  Future<void> fetchDataFromServer() async {
    await Provider.of<PatientReportProvider>(context, listen: false)
        .getUsers()
        .catchError((error) {
      print(error.toString());
      if (!error.toString().startsWith('HandshakeException'))
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occurred'),
                  content: Text('Something went wrong.'),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          setState(() {
                            Navigator.of(context, rootNavigator: true).pop();
                            fetchDataFromServer();
                          });
                        },
                        child: Text('Okay'))
                  ],
                ));
    });
  }

  Future<void> _refreshReports(BuildContext context) async {
    await Provider.of<PatientReportProvider>(context, listen: false).getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientReportProvider>(
        builder: (_, patientReportProvider, __) {
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
          child: Observer(
            builder: (_) => LoaderHUD(
                inAsyncCall: patientReportProvider.isPatientReportLoading,
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomRight,
                          end: Alignment
                              .topLeft, // 10% of the width, so there are ten blinds.
                          colors: <Color>[
                            Color(0xff606060),
                            Color(0xff295f6e),
                            Color(0xffd81a60)
                          ], // red to yellow
                          tileMode: TileMode
                              .repeated, // repeats the gradient over the canvas
                        ),
                      ),
                    ),
                    Scaffold(
                      backgroundColor: Colors.transparent,
                      key: patientReportProvider.patientReportByUserScaffoldKey,
                      appBar: UniversalRoundedAppBar(
                          height: 100,
                          uniKey: _documentsListscaffoldKey,
                          advancedDrawerController: _advancedDrawerController,
                          isHome: false,
                          headerWidget: Text('گزارش ویزیت های حضوری',
                              style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black54))),
                      body: RefreshIndicator(
                        onRefresh: () => _refreshReports(context),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: TextField(
                                    onChanged: (keyChanged) {
                                      if (keyChanged == '') {
                                        setState(() {
                                          patientReportProvider.getUsers();
                                        });
                                      } else {
                                        setState(() {
                                          patientReportProvider
                                              .runFilter(keyChanged);
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: Colors.black38,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white, width: 1),
                                            borderRadius:
                                                BorderRadius.circular(25)),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white, width: 1),
                                            borderRadius:
                                                BorderRadius.circular(25)))),
                              ),
                            ),
                            Expanded(
                              flex: 8,
                              child: StaggeredGridView.countBuilder(
                                itemCount: patientReportProvider
                                    .getOfflineUsers.length,
                                crossAxisCount: 4,
                                itemBuilder:
                                    (BuildContext context, int index) => Column(
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          // String rawJson =
                                          //     '{"reportId":${patientReportProvider.getOfflineUsers[index].id},"patientLastName":${patientReportProvider.getOfflineUsers[index].userLastName},"patientName":${patientReportProvider.getOfflineUsers[index].userName}}';
                                          // Map<String, dynamic> map = jsonDecode(rawJson);

                                          Navigator.of(context).pushNamed(
                                              PatientReport.routeName,
                                              arguments: {
                                                "reportId":
                                                    patientReportProvider
                                                        .getOfflineUsers[index]
                                                        .id,
                                                "patientLastName":
                                                    patientReportProvider
                                                        .getOfflineUsers[index]
                                                        .userLastName,
                                                "patientName":
                                                    patientReportProvider
                                                        .getOfflineUsers[index]
                                                        .userName
                                              });
                                        },
                                        child: GlassContainer(
                                          isFrostedGlass: true,
                                          frostedOpacity: 0.05,
                                          blur: 20,
                                          borderColor: Colors.transparent,
                                          elevation: 15,
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.25),
                                              Colors.white.withOpacity(0.05),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderGradient: LinearGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.60),
                                              Colors.white.withOpacity(0.0),
                                              Colors.white.withOpacity(0.0),
                                              Colors.white.withOpacity(0.60),
                                            ],
                                            stops: [0.0, 0.45, 0.55, 1.0],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          height: 150,
                                          width: MediaQuery.of(context).size.width /2.5,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                  padding: const EdgeInsets.all(
                                                      8.0),
                                                  child: ProfilePicture(
                                                    name:
                                                        '${patientReportProvider.getOfflineUsers[index].userLastName}',
                                                    radius: 25,
                                                    fontsize: 21,
                                                    random: true,
                                                  )),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                      '${patientReportProvider.getOfflineUsers[index].userName} ${patientReportProvider.getOfflineUsers[index].userLastName}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700),),
                                                ),
                                              ),
                                              Divider(),
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                    patientReportProvider
                                                        .getOfflineUsers[index]
                                                        .time,style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400),),
                                              )
                                            ],
                                          ),
                                        )

                                        // ListTile(
                                        //   leading: CircleAvatar(
                                        //     child: Icon(Icons.person),
                                        //   ),
                                        //   title: Text(patientReportProvider
                                        //       .getOfflineUsers[index].userName),
                                        //   subtitle: Text(patientReportProvider
                                        //       .getOfflineUsers[index].userLastName),
                                        //   trailing: Text(patientReportProvider
                                        //       .getOfflineUsers[index].time),
                                        // ),
                                        ),
                                  ],
                                ),
                                staggeredTileBuilder: (int index) =>
                                    new StaggeredTile.fit(2),
                                mainAxisSpacing: 8.0,
                                crossAxisSpacing: 8.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      floatingActionButton: FloatingActionButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(ReportFormScreen.routeName);
                        },
                        child: Icon(Icons.note_add),
                      ),
                    ),
                  ],
                )),
          ));
    });
  }
}
