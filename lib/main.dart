// @dart=2.9

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mpmed_doctor/authOtp/pages/home_page.dart';
import 'package:mpmed_doctor/authOtp/stores/login_store.dart';
import 'package:mpmed_doctor/doctorsList/provider/doctors_list_provider.dart';
import 'package:mpmed_doctor/doctorsList/screen/doctors_list_screen.dart';
import 'package:mpmed_doctor/documents/provider/documents_provider.dart';
import 'package:mpmed_doctor/documents/screens/document_item_screen.dart';
import 'package:mpmed_doctor/documents/screens/documents_by_user_screen.dart';
import 'package:mpmed_doctor/documents/screens/documents_screen.dart';
import 'package:mpmed_doctor/documents/screens/full_screen_image_page.dart';
import 'package:mpmed_doctor/patientReport/providers/patient_report_provider.dart';
import 'package:mpmed_doctor/patientReport/screens/patient_report_by_user_screen.dart';
import 'package:mpmed_doctor/patientReport/screens/patient_report_screen.dart';
import 'package:mpmed_doctor/patientReport/screens/report_form_screen.dart';
import 'package:mpmed_doctor/patientReport/screens/report_item_screen.dart';
import 'package:mpmed_doctor/profile/screens/doctor_profile_screen.dart';
import 'package:mpmed_doctor/questions/providers/question_provider.dart';
import 'package:mpmed_doctor/questions/screen/question_item_screen.dart';
import 'package:mpmed_doctor/questions/screen/users_list_screen.dart';
import 'package:mpmed_doctor/screens/home_screen.dart';
import 'package:mpmed_doctor/textToSpeech/screens/speechScreen.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:slide_drawer/slide_drawer.dart';

import 'authOtp/pages/splash_page.dart';
import 'documents/review/providers/review_provider.dart';
import 'notification/fcm_service.dart';
import 'notification/provider/notif_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
    .then((_) {
      runApp(new App());
    });
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final LocalStorage storage = new LocalStorage('userData');
  static Map userData = {};

  _getNtcodeFromLS() async {
    await storage.ready;
    userData = storage.getItem('profile');
    // map.forEach((key, value) {
    //   print('key=$key---value=$value');
    // });
        setupFcm();

  }

  @override
  void initState() {
    _getNtcodeFromLS();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: NotifProvider()),
        ChangeNotifierProvider.value(value: DoctorsListProvider()),
        ChangeNotifierProvider.value(value: DocumentsProvider()),
        ChangeNotifierProvider.value(value: ReviewProvider()),
        ChangeNotifierProvider.value(value: QuestionsProviders()),
        Provider<PatientReportProvider>(
            create: (_) => PatientReportProvider(userData['national_code'])),
        Provider<LoginStore>(
          create: (_) => LoginStore(),
        )
      ],
      child: MaterialApp(
        builder: EasyLoading.init(),
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          Locale("fa", "IR"), // OR Locale('ar', 'AE') OR Other RTL locales
        ],
        locale: Locale("fa", "IR"),
        theme: ThemeData(
          fontFamily: 'kalameh',
        ),
        home: SplashPage(),
        routes: {
          SplashPage.routeName: (ctx) => SplashPage(),
          SpeechScreen.routeName: (ctx) => SpeechScreen(),
          MyHomePage.routeName: (ctx) => MyHomePage(),
          DocumentsScreen.routeName: (ctx) => DocumentsScreen(),
          DocumentItemScreen.routeName: (ctx) => DocumentItemScreen(),
          PatientReport.routeName: (ctx) => PatientReport(),
          ReportFormScreen.routeName: (ctx) => ReportFormScreen(),
          PatientReportScreenByUser.routeName: (ctx) =>
              PatientReportScreenByUser(),
          SpeechScreen.routeName: (ctx) => SpeechScreen(),
          ReportItemScreen.routeName: (ctx) => ReportItemScreen(),
          DoctorsListScreen.routeName: (ctx) => DoctorsListScreen(),
          DoctorProfileScreen.routeName: (ctx) => DoctorProfileScreen(),
          UsersListQuestions.routeName: (ctx) => UsersListQuestions(),
          QuestionItemScreen.routeName: (ctx) => QuestionItemScreen(),
          DocumentsByUserScreen.routeName: (ctx) => DocumentsByUserScreen(),
          FullScreenImageViewer.routeName: (ctx) => FullScreenImageViewer()
        },
      ),
    );
  }
}
