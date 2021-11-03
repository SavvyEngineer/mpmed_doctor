import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mpmed_doctor/authOtp/theme.dart';
import 'package:mpmed_doctor/authOtp/widgets/loader_hud.dart';
import 'package:mpmed_doctor/patientReport/providers/patient_report_provider.dart';
import 'package:mpmed_doctor/patientReport/screens/report_form_screen.dart';
import 'package:mpmed_doctor/patientReport/screens/report_item_screen.dart';
import 'package:provider/provider.dart';

class PatientReport extends StatefulWidget {
  static const String routeName = '/patient_report';

  @override
  _PatientReportState createState() => _PatientReportState();
}

class _PatientReportState extends State<PatientReport> {
  bool isInit = true;
  int _id = null as int;
  String _patientLastName = '';
  String _patientName = '';

  @override
  void didChangeDependencies() {
    if (isInit) {
      final Map<String, dynamic> map =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _id = map["reportId"];
      _patientName = map["patientName"];
      _patientLastName = map["patientLastName"];
      fetchDataFromServer();
    }
    isInit = false;
    super.didChangeDependencies();
  }

  Future<void> fetchDataFromServer() async {
    await Provider.of<PatientReportProvider>(context, listen: false)
        .getReportsByUserId(_id)
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
    await fetchDataFromServer();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientReportProvider>(builder: (_, patientProvider, __) {
      return Observer(
          builder: (_) => LoaderHUD(
                inAsyncCall: patientProvider.isGettingPatientReportLoading,
                child: Scaffold(
                  key: patientProvider.patientReportScaffoldKey,
                  body: RefreshIndicator(
                    onRefresh: () => _refreshReports(context),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: ListTile(
                            leading: IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20)),
                                  color:
                                      MyColors.primaryColorLight.withAlpha(20),
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: MyColors.primaryColor,
                                  size: 16,
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            title: Text(
                                'گزارش ویزیت $_patientName $_patientLastName',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    )),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.all(4),
                            height: MediaQuery.of(context).size.height - 100,
                            child: new StaggeredGridView.countBuilder(
                              crossAxisCount: 4,
                              itemCount: patientProvider.getReports.length,
                              itemBuilder: (BuildContext context, int index) =>
                                  InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      ReportItemScreen.routeName,
                                      arguments: {
                                        'appBarTitle':
                                            'brief for patient $_patientName $_patientLastName',
                                        'content': patientProvider
                                            .getReports[index].content,
                                        'editedTime': patientProvider
                                            .getReports[index].last_edited_time,
                                      });
                                },
                                child: Card(
                                  elevation: 15,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    child: new Container(
                                        // color: Color(0xfffdfd96),
                                        // color: Colors.transparent,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    'assets/img/yellow_note_bg.jpg'),
                                                fit: BoxFit.cover)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  new Text(patientProvider
                                                      .getReports[index]
                                                      .last_edited_time),
                                                  SizedBox(
                                                    height: 15,
                                                  ),
                                                  new Text(patientProvider
                                                      .getReports[index]
                                                      .content),
                                                ],
                                              ),
                                              ClipRRect(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                child: Container(
                                                  color: Colors.black38,
                                                  child: ListTile(
                                                      trailing: IconButton(
                                                          onPressed: () {
                                                            Navigator.of(context)
                                                                .pushNamed(
                                                                    ReportFormScreen
                                                                        .routeName,
                                                                    arguments: {
                                                                  "isAddReport":
                                                                      false,
                                                                  'isReportEdit':
                                                                      true,
                                                                  'brief_id':
                                                                      patientProvider
                                                                          .getReports[
                                                                              index]
                                                                          .id,
                                                                  'brief_content':
                                                                      patientProvider
                                                                          .getReports[
                                                                              index]
                                                                          .content,
                                                                  'edited_time':
                                                                      patientProvider
                                                                          .getReports[
                                                                              index]
                                                                          .last_edited_time,
                                                                  "patientId": patientProvider
                                                                      .getReports[
                                                                          index]
                                                                      .offline_user_ref_id,
                                                                  "patientLastName":
                                                                      _patientLastName,
                                                                  "patientName":
                                                                      _patientName,
                                                                });
                                                          },
                                                          icon: Icon(Icons.edit, color: Colors.white,)),
                                                      // title: Text('آخرین ویرایش'),
                                                      // subtitle: Text(
                                                      //     patientProvider
                                                      //         .getReports[index]
                                                      //         .last_edited_time),
                                                      leading: IconButton(
                                                        icon: Icon(
                                                            Icons.delete_forever,color: Colors.white,),
                                                        onPressed: () async {
                                                          await patientProvider
                                                              .deleteReport(
                                                                  patientProvider
                                                                      .getReports[
                                                                          index]
                                                                      .id,
                                                                  patientProvider
                                                                      .getReports[
                                                                          index]
                                                                      .offline_user_ref_id);
                                                        },
                                                      )),
                                                ),
                                              )
                                            ],
                                          ),
                                        )),
                                  ),
                                ),
                              ),
                              staggeredTileBuilder: (int index) =>
                                  new StaggeredTile.fit(2),
                              mainAxisSpacing: 4.0,
                              crossAxisSpacing: 4.0,
                            )),
                      ],
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(ReportFormScreen.routeName, arguments: {
                        "patientId": _id,
                        "patientLastName": _patientLastName,
                        "patientName": _patientName,
                        "isAddReport": true,
                        'isReportEdit': false
                      });
                    },
                  ),
                ),
              ));
    });
  }
}
