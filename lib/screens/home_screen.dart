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
import 'package:shared_preferences/shared_preferences.dart';

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class MyHomePage extends StatefulWidget {
  static const String routeName = '/home_screen';

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isInit = true;
  late FirebaseMessaging _messaging;
  late int _totalNotifications;
  PushNotification? _notificationInfo;
  final _advancedDrawerController = AdvancedDrawerController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _totalNotifications = 0;
    registerNotification();
    checkForInitialMessage();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );

      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    });
    checkForInitialMessage();
    super.initState();
  }

  @override
  void dispose() {
    _advancedDrawerController.dispose();
    super.dispose();
  }

  // @override
  // void didChangeDependencies() {
  //   if (_isInit) {
  //     _messaging = FirebaseMessaging.instance;
  //     _messaging.getToken().then((value) async {
  //       await Provider.of<LoginStore>(context, listen: false)
  //           .setUpNotifToken(value!);
  //     });
  //   }
  //   _isInit = false;
  //   super.didChangeDependencies();
  // }

  checkForInitialMessage() async {
    await Firebase.initializeApp();
    _messaging.getToken().then((value) => print(value));
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      Map<String, dynamic> map = initialMessage!.data;
      PushNotification notification = PushNotification(
        title: map['title'],
        body: map['body'],
      );
      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    }
  }

  void registerNotification() async {
    // 1. Initialize the Firebase app
    await Firebase.initializeApp();

    // 2. Instantiate Firebase Messaging
    _messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      // For handling the received notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Parse the message received
        Map<String, dynamic> map = message.data;
        PushNotification notification = PushNotification(
          title: map['title'],
          body: map['body'],
        );
        setState(() {
          _notificationInfo = notification;
          _totalNotifications++;
        });
        if (_notificationInfo != null) {
          // For displaying the notification as an overlay
          showSimpleNotification(
            Text(_notificationInfo!.title!),
            leading: NotificationBadge(totalNotifications: _totalNotifications),
            subtitle: Text(_notificationInfo!.body!),
            background: Colors.cyan.shade700,
            duration: Duration(seconds: 2),
          );
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 20,
                            height: MediaQuery.of(context).size.height / 5,
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/img/online_chat.png'),
                                      fit: BoxFit.cover)),
                            )),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        margin: EdgeInsets.all(10),
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
                              width: MediaQuery.of(context).size.width / 2 - 20,
                              height: MediaQuery.of(context).size.height / 5,
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
                    ],
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
