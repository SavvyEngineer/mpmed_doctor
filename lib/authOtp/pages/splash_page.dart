import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mpmed_doctor/authOtp/pages/sign_up_page.dart';
import 'package:mpmed_doctor/notification/model/push_notifiication_pojo.dart';
import 'package:mpmed_doctor/screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../stores/login_store.dart';
import '../theme.dart';

class SplashPage extends StatefulWidget {
  static const String routeName = '/welcome_page';
  const SplashPage({Key? key}) : super(key: key);
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final FirebaseMessaging _messaging;
  String _notifToken = '';

  @override
  void initState() {
    super.initState();
    Provider.of<LoginStore>(context, listen: false)
        .isAlreadyAuthenticated()
        .then((result) async {
      await registerNotification();
      if (result) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => MyHomePage()),
            (Route<dynamic> route) => false);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (Route<dynamic> route) => false);
      }
    });
  }

  Future<void> registerNotification() async {
    // 1. Initialize the Firebase app
    await Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    // return FutureBuilder(
    //   // Initialize FlutterFire
    //   future: Firebase.initializeApp(),
    //   builder: (context, snapshot) {
    //     // Check for errors
    //     if (snapshot.hasError) {
    //       print(snapshot.hasError.toString());
    //     }

    //     // Once complete, show your application
    //     if (snapshot.connectionState == ConnectionState.done) {
    //       // messaging = FirebaseMessaging.instance;
    //       // messaging.getToken().then((value) async {

    //       //   //  await Provider.of<LoginStore>(context, listen: false)
    //       //   //     .setUpNotifToken(value!);
    //       // });

    //       // Provider.of<LoginStore>(context, listen: false)
    //       //     .setUpNotifToken(messaging.onTokenRefresh.toString());

    //       // FirebaseMessaging.onMessage.listen((RemoteMessage event) {
    //       //   print("message recieved");
    //       //   print(event.notification!.body);
    //       // });
    //       // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //       //   print('Message clicked!');
    //       // });

    //     }

    // Otherwise, show something whilst waiting for initialization to complete
    return Scaffold(
      body: Column(
        children: [
          Spacer(),
          Container(
              alignment: Alignment.center,
              child: Image.asset('assets/img/drawer_logo.png')),
          Spacer(),
          Container(
              margin: EdgeInsets.all(16),
              alignment: Alignment.bottomCenter,
              child: CircularProgressIndicator())
        ],
      ),
    );
    //  },
    //  );
  }
}
