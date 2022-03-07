import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mpmed_doctor/appbar/universal_app_bar.dart';
import 'package:mpmed_doctor/doctorsList/provider/doctors_list_provider.dart';
import 'package:mpmed_doctor/helper/get_data_from_ls.dart';
import 'package:mpmed_doctor/profile/widgets/time_picker_widget.dart';
import 'package:mpmed_doctor/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:time_range_picker/time_range_picker.dart';

class DoctorProfileScreen extends StatefulWidget {
  static const String routeName = '/doctor_profile_screen';

  @override
  _DoctorProfileScreenState createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final _advancedDrawerController = AdvancedDrawerController();

  GetDataFromLs getDataFromLs = new GetDataFromLs();
  Map userData = {};

  late Future _workingHoursFuture;

  bool _is_init = true;

  GlobalKey<ScaffoldState> _docProfileScaffoldKey = GlobalKey<ScaffoldState>();

  Future _obtainWorkingHoursFuture() async {
    await getDataFromLs.getProfileData().then((value) {
      userData = value;
    });
    return Provider.of<DoctorsListProvider>(context, listen: false)
        .fetchAndSetWorkingHours(userData['national_code']);
  }

  List<String> _weekDays = [
    'شنبه',
    'یک‌شنبه',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنج‌شنبه',
    'جمعه'
  ];

  Map _submitedWorkingHours = {};

  Map _is_editing_allowed_by_weekDay = {
    0: false,
    1: false,
    2: false,
    3: false,
    4: false,
    5: false,
    6: false
  };

  String? _whResualt;

  @override
  void didChangeDependencies() {
    if (_is_init) {
      _workingHoursFuture = _obtainWorkingHoursFuture();
    }
    _is_init = false;
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
          RefreshIndicator(
              onRefresh: _obtainWorkingHoursFuture,
              child: FutureBuilder(
                  future: _workingHoursFuture,
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
                            builder: (context, doctorsData, child) => Scaffold(
                                  backgroundColor: Colors.transparent,
                                  extendBodyBehindAppBar: true,
                                  appBar: UniversalRoundedAppBar(
                                    height: 100,
                                    uniKey: _docProfileScaffoldKey,
                                    advancedDrawerController:
                                        _advancedDrawerController,
                                    isHome: false,
                                    headerWidget: Text(
                                      'ویرایش حساب کاربری',
                                      style: TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                    ),
                                  ),
                                  body: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        flex: 4,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(15),
                                              bottomRight: Radius.circular(15)),
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    3 +
                                                100,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            color: Colors.white,
                                            padding:
                                                EdgeInsets.only(bottom: 30),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                CircleAvatar(
                                                  radius: 60,
                                                  backgroundImage: NetworkImage(
                                                      userData['profile_pic']
                                                          .toString()),
                                                ),
                                                SizedBox(
                                                  height: 30,
                                                ),
                                                Text(
                                                  '${userData['name']} ${userData['lastName']}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 5,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'ساعات کاری',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 21,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            if (doctorsData.getWorkingHoursByDay
                                                    .length <
                                                1)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  margin: EdgeInsets.all(10),
                                                  padding: EdgeInsets.all(10),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                      color: Colors.orange,
                                                      border: Border.all(
                                                          color: Colors
                                                              .red, // Set border color
                                                          width: 3.0), // Set border width
                                                      borderRadius: BorderRadius.all(Radius.circular(10.0)), // Set rounded corner radius
                                                      boxShadow: [
                                                        BoxShadow(
                                                            blurRadius: 10,
                                                            color: Colors.black,
                                                            offset:
                                                                Offset(1, 3))
                                                      ] // Make rounded corner of border
                                                      ),
                                                  child: Text(
                                                    'لطفآ ساعت کاری خود را برای هر روز هفته مشخص کنید',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                ),
                                              ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 180,
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: ListView.builder(
                                                    itemCount: _weekDays.length,
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 8),
                                                        child: GlassContainer(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              30,
                                                          height: 170,
                                                          isFrostedGlass: true,
                                                          frostedOpacity: 0.05,
                                                          borderColor: Colors.transparent,
                                                          blur: 20,
                                                          elevation: 15,
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.25),
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.05),
                                                            ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          ),
                                                          borderGradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.60),
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.0),
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.0),
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.60),
                                                            ],
                                                            stops: [
                                                              0.0,
                                                              0.45,
                                                              0.55,
                                                              1.0
                                                            ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      25.0),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  IconButton(
                                                                      onPressed:
                                                                          () {
                                                                        if (!_is_editing_allowed_by_weekDay[
                                                                            index]) {
                                                                          _is_editing_allowed_by_weekDay[index] =
                                                                              true;
                                                                          setState(
                                                                              () {});
                                                                        } else {
                                                                          _is_editing_allowed_by_weekDay[index] =
                                                                              false;
                                                                          setState(
                                                                              () {});
                                                                        }
                                                                      },
                                                                      icon:
                                                                          Icon(
                                                                        !_is_editing_allowed_by_weekDay[index]
                                                                            ? Icons.edit_outlined
                                                                            : Icons.edit_off_outlined,
                                                                        color: Colors
                                                                            .amber,
                                                                      )),
                                                                  Text(
                                                                    _weekDays[
                                                                        index],
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        fontSize:
                                                                            21),
                                                                  ),
                                                                ],
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: SizedBox(
                                                                  width: double
                                                                      .infinity,
                                                                  child: _is_editing_allowed_by_weekDay[
                                                                          index]
                                                                      ? FittedBox(
                                                                          fit: BoxFit
                                                                              .scaleDown,
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              if (_submitedWorkingHours['day_$index'] != 'NA')
                                                                                FlatButton(
                                                                                    textColor: Colors.white,
                                                                                    shape: RoundedRectangleBorder(side: BorderSide(color: Colors.black, width: 1.5, style: BorderStyle.solid), borderRadius: BorderRadius.circular(50)),
                                                                                    onPressed: () async {
                                                                                      if (_submitedWorkingHours['day_$index'] == 'NA') {
                                                                                      } else {
                                                                                        TimeRange? result = await TimePickerWidget(context);
                                                                                        _whResualt = '${result.endTime.format(context).toString()}-${result.startTime.format(context).toString()}';
                                                                                        _submitedWorkingHours['day_$index'] = '$_whResualt';

                                                                                        setState(() {});
                                                                                      }
                                                                                    },
                                                                                    child: Text(doctorsData.getWorkingHoursByDay.length > 1
                                                                                        ? doctorsData.getWorkingHoursByDay[index]
                                                                                        : _submitedWorkingHours['day_$index'] == null || _submitedWorkingHours['day_$index'] == 'NA' || _is_editing_allowed_by_weekDay[index]
                                                                                            ? 'لطفا ساعت کاری خود را وارد کنید'
                                                                                            : _submitedWorkingHours['day_$index'])),
                                                                              if (doctorsData.getWorkingHoursByDay.length < 1 || _submitedWorkingHours['day_$index'] == null || _submitedWorkingHours['day_$index'] == 'NA')
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(right: 8),
                                                                                  child: FlatButton(
                                                                                      textColor: Colors.white,
                                                                                      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.black, width: 1.5, style: BorderStyle.solid), borderRadius: BorderRadius.circular(50)),
                                                                                      onPressed: () {
                                                                                        if (_submitedWorkingHours['day_$index'] == 'NA') {
                                                                                          _submitedWorkingHours['day_$index'] = null;
                                                                                          setState(() {});
                                                                                        } else {
                                                                                          _submitedWorkingHours['day_$index'] = 'NA';
                                                                                          setState(() {});
                                                                                        }
                                                                                      },
                                                                                      child: Text("روزه غیر کاری")),
                                                                                ),
                                                                            ],
                                                                          ),
                                                                        )
                                                                      : Center(
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 8),
                                                                                child: Icon(
                                                                                  Icons.access_time,
                                                                                  color: Colors.white70,
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                  doctorsData.getWorkingHoursByDay.length < 1
                                                                                      ? 'لطفآ منتظر بمانید !!!'
                                                                                      : doctorsData.getWorkingHoursByDay[index] == 'NA'
                                                                                          ? "روزه غیر کاری"
                                                                                          : doctorsData.getWorkingHoursByDay[index],
                                                                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white70)),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                ),
                                                              ),
                                                              if (_is_editing_allowed_by_weekDay[
                                                                  index])
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      right: 8),
                                                                  child: FlatButton(
                                                                      textColor: Colors.white,
                                                                      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.black, width: 1.5, style: BorderStyle.solid), borderRadius: BorderRadius.circular(50)),
                                                                      onPressed: () async {
                                                                        if (_is_editing_allowed_by_weekDay[
                                                                            index]) {
                                                                          Map _updatedMap =
                                                                              {
                                                                            "id":
                                                                                doctorsData.getWorkingHours[0].id,
                                                                            "doctor_ref_id":
                                                                                userData['national_code'],
                                                                            "edited_time":
                                                                                DateTime.now().microsecondsSinceEpoch.toString(),
                                                                            'day_$index': _submitedWorkingHours['day_$index'] != 'NA'
                                                                                ? _whResualt
                                                                                : 'NA'
                                                                          };
                                                                          EasyLoading.show(
                                                                              status: 'در حال ثبت تغییرات ...');
                                                                          await Provider.of<DoctorsListProvider>(context, listen: false)
                                                                              .updateWorkingHours(_updatedMap)
                                                                              .then((value) {
                                                                            _is_editing_allowed_by_weekDay[index] =
                                                                                false;
                                                                            setState(() {});
                                                                            EasyLoading.dismiss();
                                                                            EasyLoading.showSuccess('تغییرات با موفقیت ثبت شد');
                                                                          });
                                                                        }
                                                                      },
                                                                      child: Text('ثبت تغییرات')),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )),
                                            ),
                                            doctorsData.getWorkingHoursByDay
                                                        .length <
                                                    1
                                                ? FlatButton(
                                                    textColor: Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            side: BorderSide(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                width: 1.5,
                                                                style:
                                                                    BorderStyle
                                                                        .solid),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50)),
                                                    onPressed: () {
                                                      _submitedWorkingHours[
                                                              "doctor_ref_id"] =
                                                          userData[
                                                              'national_code'];
                                                      _submitedWorkingHours[
                                                          "edited_time"] = DateTime
                                                              .now()
                                                          .microsecondsSinceEpoch
                                                          .toString();
                                                      _submitedWorkingHours
                                                          .forEach(
                                                              (key, value) {
                                                        print(
                                                            'key=$key--value=$value');
                                                      });
                                                      EasyLoading.show(
                                                          status:
                                                              'در حال ثبت ساعت کاری ...');
                                                      Provider.of<DoctorsListProvider>(
                                                              context,
                                                              listen: false)
                                                          .uploadWorkingHours(
                                                              _submitedWorkingHours)
                                                          .then((value) {
                                                        setState(() {});
                                                        EasyLoading.dismiss();
                                                        EasyLoading.showSuccess(
                                                            'ساعت کاری با موفقیت ثبت شد');
                                                      });
                                                    },
                                                    child:
                                                        Text('ثبت ساعت کاری'))
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ));
                      }
                    }
                  }))
        ],
      ),
    );
  }
}
