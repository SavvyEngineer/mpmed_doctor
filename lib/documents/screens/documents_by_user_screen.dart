import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mpmed_doctor/appbar/universal_app_bar.dart';
import 'package:mpmed_doctor/doctorsList/provider/doctors_list_provider.dart';
import 'package:mpmed_doctor/documents/provider/documents_provider.dart';
import 'package:mpmed_doctor/documents/screens/documents_screen.dart';
import 'package:mpmed_doctor/notification/notification_bloc.dart';
import 'package:mpmed_doctor/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

class DocumentsByUserScreen extends StatefulWidget {
  static const String routeName = '/documents_by_user_screen';

  @override
  DocumentsByUserScreenState createState() => DocumentsByUserScreenState();
}

class DocumentsByUserScreenState extends State<DocumentsByUserScreen> {
  Future _usersListFuture = null as Future;
  bool _isInit = true;
  late Stream<LocalNotification> _notificationsStream;

  GlobalKey<ScaffoldState> _usersListscaffoldKey = GlobalKey<ScaffoldState>();
  final _advancedDrawerController = AdvancedDrawerController();

  final LocalStorage storage = new LocalStorage('userData');
  Map userData = {};

  _getNtcodeFromLS() async {
    await storage.ready;
    userData = storage.getItem('profile');
    _usersListFuture = _obtainUsersListFuture();
    // map.forEach((key, value) {
    //   print('key=$key---value=$value');
    // });
  }

  @override
  void initState() {
    super.initState();
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      _obtainUsersListFuture();
    });
  }

  Future _obtainUsersListFuture() async {
    return await Provider.of<DocumentsProvider>(context, listen: false)
        .fetchAndSetDocuments(userData['national_code']);
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _getNtcodeFromLS();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

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
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment(
                    0.8, 0.0), // 10% of the width, so there are ten blinds.
                colors: <Color>[
                  Color(0xff606060),
                  Color(0xff295f6e),
                  Color(0xffd81a60)
                ], // red to yellow
                tileMode:
                    TileMode.repeated, // repeats the gradient over the canvas
              ),
            ),
          ),
          Scaffold(
              backgroundColor: Colors.transparent,
              key: _usersListscaffoldKey,
              appBar: UniversalRoundedAppBar(
                height: 100,
                uniKey: _usersListscaffoldKey,
                advancedDrawerController: _advancedDrawerController,
                isHome: false,
                headerWidget: Text(
                  'بیماران شما',
                  style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54),
                ),
              ),
              body: RefreshIndicator(
                onRefresh: _obtainUsersListFuture,
                child: FutureBuilder(
                  future: _usersListFuture,
                  builder: (context, dataSnapShot) {
                    if (dataSnapShot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      if (dataSnapShot.error != null) {
                        return Center(
                          child: Text('An error occured'),
                        );
                      } else {
                        return Consumer<DocumentsProvider>(
                            builder: (context, usersDocumentData, child) =>
                                usersDocumentData.usersWithDocument.length <1 
                                    ? Center(child: CircularProgressIndicator())
                                    : Column(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: TextField(
                                                  onChanged: (keyChanged) {
                                                    if (keyChanged == '') {
                                                      usersDocumentData
                                                          .fetchAndSetDocuments(
                                                              userData[
                                                                  'national_code']);
                                                    } else {
                                                      usersDocumentData
                                                          .runFilterInusers(
                                                              keyChanged);
                                                    }
                                                  },
                                                  decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      prefixIcon: Icon(
                                                        Icons.search,
                                                        color: Colors.black38,
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          25)),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                      color: Colors
                                                                          .white,
                                                                      width: 1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          25)))),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 8,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: StaggeredGridView
                                                  .countBuilder(
                                                itemCount: usersDocumentData
                                                    .usersWithDocument.length,
                                                crossAxisCount: 4,
                                                itemBuilder:
                                                    (BuildContext context,
                                                            int index) =>
                                                        InkWell(
                                                  onTap: () {
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                            DocumentsScreen
                                                                .routeName,
                                                            arguments: {
                                                          'userId':
                                                              usersDocumentData
                                                                  .usersWithDocument[
                                                                      index]
                                                                  .user_id,
                                                          'doctorNtcode':
                                                              userData[
                                                                  'national_code']
                                                        });
                                                  },
                                                  child: GlassContainer(
                                                    isFrostedGlass: true,
                                                    frostedOpacity: 0.05,
                                                    borderColor: Colors.transparent,
                                                    blur: 20,
                                                    elevation: 15,
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.white
                                                            .withOpacity(0.25),
                                                        Colors.white
                                                            .withOpacity(0.05),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                    borderGradient:
                                                        LinearGradient(
                                                      colors: [
                                                        Colors.white
                                                            .withOpacity(0.60),
                                                        Colors.white
                                                            .withOpacity(0.0),
                                                        Colors.white
                                                            .withOpacity(0.0),
                                                        Colors.white
                                                            .withOpacity(0.60),
                                                      ],
                                                      stops: [
                                                        0.0,
                                                        0.45,
                                                        0.55,
                                                        1.0
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            5,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              4,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          ClipRRect(
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          15),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          15)),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    ProfilePicture(
                                                                  name:
                                                                      '${usersDocumentData.usersWithDocument[index].last_name}',
                                                                  radius: 25,
                                                                  fontsize: 21,
                                                                  random: true,
                                                                ),
                                                              )),

                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                                '${usersDocumentData.usersWithDocument[index].name} ${usersDocumentData.usersWithDocument[index].last_name}',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700)),
                                                          ),
                                                          // FittedBox(
                                                          //   fit: BoxFit.scaleDown,
                                                          //   child: Text(
                                                          //       usersDocumentData
                                                          //           .usersWithDocument[index]
                                                          //           .
                                                          //           .toString(),
                                                          //       style: TextStyle(
                                                          //           fontSize: 15,
                                                          //           fontWeight:
                                                          //               FontWeight.w500)),
                                                          // ),
                                                          // FittedBox(
                                                          //   fit: BoxFit.scaleDown,
                                                          //   child: Text(
                                                          //       '${doctorsData.getDoctorsList[index].wstate} ${doctorsData.getDoctorsList[index].wcity}',
                                                          //       style: TextStyle(
                                                          //           fontSize: 15,
                                                          //           fontWeight:
                                                          //               FontWeight.w400)),
                                                          // )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                staggeredTileBuilder: (int
                                                        index) =>
                                                    new StaggeredTile.fit(2),
                                                mainAxisSpacing: 8.0,
                                                crossAxisSpacing: 8.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ));
                      }
                    }
                  },
                ),
              ))
        ],
      ),
    );
  }
}
