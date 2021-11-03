import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mpmed_doctor/appbar/universal_app_bar.dart';
import 'package:mpmed_doctor/profile/widgets/time_picker_widget.dart';
import 'package:mpmed_doctor/widgets/app_drawer.dart';
import 'package:time_range_picker/time_range_picker.dart';

class DoctorProfileScreen extends StatefulWidget {
  static const String routeName = '/doctor_profile_screen';

  @override
  _DoctorProfileScreenState createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final LocalStorage storage = new LocalStorage('userData');
  final _advancedDrawerController = AdvancedDrawerController();
  GlobalKey<ScaffoldState> _docProfileScaffoldKey = GlobalKey<ScaffoldState>();
  List<String> _weekDays = [
    'shanbe',
    '1shanbe',
    '2shanbe',
    '3shanbe',
    '4shanbe',
    '5shanbe',
    'jome'
  ];

  Map _userData = new Map();

  _getUserData() async {
    await storage.ready;
    setState(() {
      _userData = storage.getItem('profile');
    });
    _userData.forEach((key, value) {
      print('$key --- $value');
    });
  }

  @override
  void initState() {
    _getUserData();
    print(_userData['profile_pic'].toString());
    super.initState();
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
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: UniversalRoundedAppBar(
            height: 100,
            uniKey: _docProfileScaffoldKey,
            advancedDrawerController: _advancedDrawerController,
            isHome: false,
            headerWidget: Text('ویرایش حساب کاربری', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700,color: Colors.white),),
            ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
              child: Container(
                height: MediaQuery.of(context).size.height / 3 + 100,
                width: MediaQuery.of(context).size.width,
                color: Colors.amber,
                padding: EdgeInsets.only(bottom: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(70)),
                        child: Image.network(
                          _userData['profile_pic'].toString(),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      '${_userData['name']} ${_userData['lastName']}',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )
                  ],
                ),
              ),
            ),
            Text('Working Hours'),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2,
              child: StaggeredGridView.countBuilder(
                crossAxisCount: 4,
                itemCount: 7,
                itemBuilder: (BuildContext context, int index) => new Center(
                  child: Card(
                    elevation: 15,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_weekDays[index]),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                              onPressed: () async {
                                TimeRange result = await showTimeRangePicker(
                                  context: context,
                                  start: TimeOfDay(hour: 22, minute: 9),
                                  onStartChange: (start) {
                                    print("start time " + start.toString());
                                  },
                                  onEndChange: (end) {
                                    print("end time " + end.toString());
                                  },
                                  interval: Duration(minutes: 30),
                                  use24HourFormat: false,
                                  padding: 30,
                                  strokeWidth: 20,
                                  handlerRadius: 14,
                                  strokeColor: Colors.orange,
                                  handlerColor: Colors.orange[700],
                                  selectedColor: Colors.amber,
                                  backgroundColor:
                                      Colors.black.withOpacity(0.3),
                                  ticks: 12,
                                  ticksColor: Colors.white,
                                  snap: true,
                                  labels: [
                                    "12 pm",
                                    "3 am",
                                    "6 am",
                                    "9 am",
                                    "12 am",
                                    "3 pm",
                                    "6 pm",
                                    "9 pm"
                                  ].asMap().entries.map((e) {
                                    return ClockLabel.fromIndex(
                                        idx: e.key, length: 8, text: e.value);
                                  }).toList(),
                                  labelOffset: -30,
                                  labelStyle: TextStyle(
                                      fontSize: 22,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                  timeTextStyle: TextStyle(
                                      color: Colors.orange[700],
                                      fontSize: 24,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold),
                                  activeTimeTextStyle: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 26,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold),
                                );

                                print(
                                    'final result = ${result.startTime} - ${result.endTime}');
                              },
                              child: Text('touch to change')),
                        )
                      ],
                    ),
                  ),
                ),
                staggeredTileBuilder: (int index) =>
                    new StaggeredTile.count(2, index.isEven ? 2 : 3),
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
              ),
            )
          ],
        ),
      ),
    );
  }
}
