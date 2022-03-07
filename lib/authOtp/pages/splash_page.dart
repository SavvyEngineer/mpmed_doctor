import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mpmed_doctor/authOtp/pages/sign_up_page.dart';
import 'package:mpmed_doctor/notification/fcm_service.dart';
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
  late Future _initialRouteFuture;
  @override
  void initState() {
    super.initState();

    _initialRouteFuture = _setupInitialRoute();
  }

  Future<void> _setupInitialRoute() async {
    await Provider.of<LoginStore>(context, listen: false)
        .isAlreadyAuthenticated()
        .then((result) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: _initialRouteFuture,
            builder: (context, dataSnapShot) {
              if (dataSnapShot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (dataSnapShot.error != null) {
                  return Center(
                    child: Text('An error occured'),
                  );
                } else {
                  return Column(
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
                  );
                }
              }
            }));
    //  },
    //  );
  }
}
