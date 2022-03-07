import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:mpmed_doctor/appbar/universal_app_bar.dart';
import 'package:mpmed_doctor/doctorsList/provider/doctors_list_provider.dart';
import 'package:mpmed_doctor/doctorsList/screen/doctor_item_screen.dart';
import 'package:mpmed_doctor/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

class DoctorsListScreen extends StatefulWidget {
  static const String routeName = '/doctors_list';

  @override
  _DoctorsListScreenState createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  late Future _doctorsListFuture;

  GlobalKey<ScaffoldState> _doctorsListscaffoldKey = GlobalKey<ScaffoldState>();
  final _advancedDrawerController = AdvancedDrawerController();

  Future _obtainDoctorsListFuture() {
    return Provider.of<DoctorsListProvider>(context, listen: false)
        .fetchAndSetDoctorsList();
  }

  @override
  void initState() {
    super.initState();
    _doctorsListFuture = _obtainDoctorsListFuture();
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
                begin: Alignment.topRight,
                end: Alignment
                    .bottomLeft, // 10% of the width, so there are ten blinds.
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
              key: _doctorsListscaffoldKey,
              appBar: UniversalRoundedAppBar(
                height: 100,
                uniKey: _doctorsListscaffoldKey,
                advancedDrawerController: _advancedDrawerController,
                isHome: false,
                headerWidget: Text(
                  'اسامی پزشکان',
                  style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54),
                ),
              ),
              body: RefreshIndicator(
                onRefresh: _obtainDoctorsListFuture,
                child: FutureBuilder(
                  future: _doctorsListFuture,
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
                        return Consumer<DoctorsListProvider>(
                            builder: (context, doctorsData, child) => Column(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: TextField(
                                            onChanged: (keyChanged) {
                                              if (keyChanged == '') {
                                                doctorsData
                                                    .fetchAndSetDoctorsList();
                                              } else {
                                                doctorsData
                                                    .runFilter(keyChanged);
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
                                                            color: Colors.white,
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25)),
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
                                      child: StaggeredGridView.countBuilder(
                                        itemCount:
                                            doctorsData.getDoctorsList.length,
                                        crossAxisCount: 4,
                                        itemBuilder:
                                            (BuildContext context, int index) =>
                                                GlassContainer(
                                          isFrostedGlass: true,
                                          frostedOpacity: 0.05,
                                          blur: 20,
                                          elevation: 15,
                                          borderColor: Colors.transparent,
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
                                          height: 170,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.5,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          DoctorItemScreen(
                                                              doctorsData
                                                            .getDoctorsList[
                                                                index])));
                                            },
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: CircleAvatar(
                                                    radius: 31,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    backgroundImage:
                                                        NetworkImage(doctorsData
                                                            .getDoctorsList[
                                                                index]
                                                            .profilePic
                                                            .toString()),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8, right: 8),
                                                  child: Divider(),
                                                ),
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                      '${doctorsData.getDoctorsList[index].name} ${doctorsData.getDoctorsList[index].lastName}',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w700)),
                                                ),
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                      doctorsData
                                                          .getDoctorsList[index]
                                                          .specialty
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8, right: 8),
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                        '${doctorsData.getDoctorsList[index].wstate} ${doctorsData.getDoctorsList[index].wcity}',
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400)),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        staggeredTileBuilder: (int index) =>
                                            new StaggeredTile.fit(2),
                                        mainAxisSpacing: 8.0,
                                        crossAxisSpacing: 8.0,
                                      ),
                                    ),
                                  ],
                                ));
                      }
                    }
                  },
                ),
              )),
        ],
      ),
    );
  }
}
