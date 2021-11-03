import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobx/mobx.dart';
import 'package:mpmed_doctor/patientReport/screens/patient_report_screen.dart';

part 'patient_report_provider.g.dart';

class OfflineUsers {
  int id;
  String fromDoctorId;
  String userName;
  String userLastName;
  String userNtcode;
  String time;

  OfflineUsers(
      {required this.id,
      required this.fromDoctorId,
      required this.userName,
      required this.userLastName,
      required this.userNtcode,
      required this.time});
}

class Reports {
  int id;
  String doctor_ref_id;
  String content;
  int offline_user_ref_id;
  String last_edited_time;

  Reports(
      {required this.id,
      required this.doctor_ref_id,
      required this.content,
      required this.offline_user_ref_id,
      required this.last_edited_time});
}

class PatientReportProvider = PatientReportProviderBase
    with _$PatientReportProvider;

abstract class PatientReportProviderBase with Store {
  @observable
  bool isPatientReportLoading = false;
  @observable
  bool isGettingPatientReportLoading = false;
  @observable
  GlobalKey<ScaffoldState> patientReportFormScaffoldKey =
      GlobalKey<ScaffoldState>();
  @observable
  GlobalKey<ScaffoldState> patientReportScaffoldKey =
      GlobalKey<ScaffoldState>();

  @observable
  GlobalKey<ScaffoldState> patientReportByUserScaffoldKey =
      GlobalKey<ScaffoldState>();
  final String doc_ntcode;
  PatientReportProviderBase(this.doc_ntcode);

  List<OfflineUsers> _offlineUsersList = [];
  List<Reports> _reportsList = [];

  List<OfflineUsers> get getOfflineUsers {
    return [..._offlineUsersList];
  }

  List<Reports> get getReports {
    return [..._reportsList];
  }

  _showSnackBar(Color color, String message, GlobalKey<ScaffoldState> key) {
    isPatientReportLoading = false;
    key.currentState!.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
      content: Text(
        message.toString(),
        style: TextStyle(color: Colors.white),
      ),
    ));
  }

  @action
  Future<void> setReports(
      Map<String, dynamic> map, BuildContext context) async {
    isPatientReportLoading = true;
    final url = 'https://mpmed.ir/offline_user_app';

    map['doctor_ntcode'] = doc_ntcode;

    try {
      map.forEach((key, value) {
        print('key $key===$value');
      });

      FormData formData = new FormData.fromMap(map);
      var dio = Dio()..options.baseUrl = url;
      final response =
          await dio.post('/v1/api.php?apicall=create_user', data: formData);
      Map<String, dynamic> decodedResponse = json.decode(response.data);
      if (decodedResponse['error'] == false) {
        getUsers();
        isPatientReportLoading = false;
        _showSnackBar(
            Colors.green, 'Report Submited', patientReportFormScaffoldKey);
        //Navigator.of(context).popAndPushNamed(PatientReport.routeName);
        Navigator.of(context).pop();
      } else {
        isPatientReportLoading = false;
        _showSnackBar(Colors.red, 'Something went wrong please try again',
            patientReportFormScaffoldKey);
      }
      print(response.data.toString());
    } catch (e) {
      isPatientReportLoading = false;
      _showSnackBar(Colors.red, 'Something went wrong please try again',
          patientReportFormScaffoldKey);
      print(e.toString());
    }
  }

  @action
  Future<void> addReports(
      Map<String, dynamic> map, BuildContext context) async {
    isPatientReportLoading = true;
    final url = 'https://mpmed.ir/visit_brief_app';

    map['doctor_nt_code'] = doc_ntcode;

    try {
      map.forEach((key, value) {
        print('key $key===$value');
      });

      FormData formData = new FormData.fromMap(map);
      var dio = Dio()..options.baseUrl = url;
      final response =
          await dio.post('/v1/api.php?apicall=create_brief', data: formData);
      print(json.decode(response.data).toString());
      Map<String, dynamic> decodedResponse = json.decode(response.data);
      if (decodedResponse['error'] == false) {
        isPatientReportLoading = false;
        getReportsByUserId(map["offline_user_ref_id"]);
        _showSnackBar(
            Colors.green, 'Report Submited', patientReportFormScaffoldKey);
        //Navigator.of(context).popAndPushNamed(PatientReport.routeName);
        Navigator.of(context).pop();
      } else {
        isPatientReportLoading = false;
        _showSnackBar(Colors.red, 'Something went wrong please try again',
            patientReportFormScaffoldKey);
      }
      print(response.data.toString());
    } catch (e) {
      print(e.toString());
      isPatientReportLoading = false;
      _showSnackBar(Colors.red, 'Something went wrong please try again',
          patientReportFormScaffoldKey);
      print(e.toString());
    }
  }

  @action
  Future<void> editReport(
      Map<String, dynamic> map, BuildContext context) async {
    isPatientReportLoading = true;
    final url = 'https://mpmed.ir/visit_brief_app';


    try {
      map.forEach((key, value) {
        print('key $key===$value');
      });

      FormData formData = new FormData.fromMap(map);
      var dio = Dio()..options.baseUrl = url;
      final response =
          await dio.post('/v1/api.php?apicall=update_brief', data: formData);
      Map<String, dynamic> decodedResponse = json.decode(response.data);
      if (decodedResponse['error'] == false) {
        getReportsByUserId(map["offline_user_ref_id"]);
        isPatientReportLoading = false;
        _showSnackBar(Colors.green, 'Report edited Successfully',
            patientReportFormScaffoldKey);
        //Navigator.of(context).popAndPushNamed(PatientReport.routeName);
        Navigator.of(context).pop();
      } else {
        isPatientReportLoading = false;
        _showSnackBar(Colors.red, 'Something went wrong please try again',
            patientReportFormScaffoldKey);
      }
      print(response.data.toString());
    } catch (e) {
      isPatientReportLoading = false;
      _showSnackBar(Colors.red, 'Something went wrong please try again',
          patientReportFormScaffoldKey);
      print(e.toString());
    }
  }

  @action
  Future<void> getUsers() async {
    isPatientReportLoading = true;
    _offlineUsersList = [];
    final url =
        'https://mpmed.ir/offline_user_app/v1/api.php?apicall=get_users';

    try {
      var map = new Map<String, dynamic>();
      map['doctor_ntcode'] = doc_ntcode;

      final response = await http.post(Uri.parse(url), body: map);
      List<dynamic> recievedDataList = json.decode(response.body);

      for (var i = 0; i < recievedDataList.length; i++) {
        _offlineUsersList.add(OfflineUsers(
            id: recievedDataList[i]["id"],
            fromDoctorId: recievedDataList[i]["from_doctor_id"],
            userName: recievedDataList[i]["user_name"],
            userLastName: recievedDataList[i]["user_last_name"],
            userNtcode: recievedDataList[i]["user_ntcode"],
            time: recievedDataList[i]["time"]));
      }

      if (response.statusCode >= 400) {
        isPatientReportLoading = false;
        _showSnackBar(
            Colors.red, 'Something went wrong', patientReportByUserScaffoldKey);
      } else {
        isPatientReportLoading = false;
      }
    } catch (e) {
      _showSnackBar(
          Colors.red, 'Something went wrong', patientReportByUserScaffoldKey);
      isPatientReportLoading = false;
    }
  }

  @action
  Future<void> getReportsByUserId(int userId) async {
    _reportsList = [];
    isGettingPatientReportLoading = true;

    final url = 'https://mpmed.ir/visit_brief_app/';
    List<dynamic> recivedData;
    Map<String, dynamic> map = new Map();
    map['doctor_ntcode'] = doc_ntcode;
    map['offline_visit_user_id'] = userId;
    try {
      FormData formData = new FormData.fromMap(map);
      var dio = Dio()..options.baseUrl = url;

      final response =
          await dio.post('v1/api.php?apicall=get_briefs', data: formData);
      recivedData = jsonDecode(response.data);

      //print(recivedData.toString());
      // print(userId.toString());

      for (var i = 0; i < recivedData.length; i++) {
        _reportsList.add(Reports(
            id: recivedData[i]["id"],
            doctor_ref_id: recivedData[i]["doctor_ref_id"],
            content: recivedData[i]["content"],
            offline_user_ref_id: recivedData[i]["offline_user_ref_id"],
            last_edited_time: recivedData[i]["last_edited_time"]));
      }
      if (response.statusCode! >= 400) {
        isGettingPatientReportLoading = false;
        _showSnackBar(
            Colors.red, 'Something went wrong', patientReportScaffoldKey);
      } else {
        isGettingPatientReportLoading = false;
      }
    } catch (e) {
      _showSnackBar(
          Colors.red, 'Something went wrong', patientReportScaffoldKey);
      print(e.toString());
      isGettingPatientReportLoading = false;
    }
  }

  @action
  Future<void> deleteReport(int reportId, int userId) async {
    final url = 'https://mpmed.ir/visit_brief_app/';

    isGettingPatientReportLoading = true;

    Map<String, dynamic> map = new Map();
    map['brief_id'] = reportId;

    try {
      FormData formData = new FormData.fromMap(map);
      var dio = Dio()..options.baseUrl = url;

      final response =
          await dio.post('v1/api.php?apicall=delete_brief', data: formData);
      Map<String, dynamic> recivedData = jsonDecode(response.data);

      // print(userId.toString());
      if (recivedData['error'] == false) {
        isGettingPatientReportLoading = false;
        getReportsByUserId(userId);
        _showSnackBar(Colors.green, 'report deleted successfully',
            patientReportScaffoldKey);
      } else {
        isGettingPatientReportLoading = false;
        _showSnackBar(
            Colors.red, 'Something went wrong', patientReportScaffoldKey);
      }
      if (response.statusCode! >= 400) {
        isGettingPatientReportLoading = false;
        _showSnackBar(
            Colors.red, 'Something went wrong', patientReportScaffoldKey);
      } else {
        isGettingPatientReportLoading = false;
      }
    } catch (e) {
      _showSnackBar(
          Colors.red, 'Something went wrong', patientReportScaffoldKey);
      print(e.toString());
      isGettingPatientReportLoading = false;
    }
  }

  @action
  void runFilter(String enteredKeyword) {
    List<OfflineUsers> _beforeSearchList = _offlineUsersList;
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      // results = _allUsers;
      _beforeSearchList = _offlineUsersList;
    } else {
      List<OfflineUsers> _filteredList = _offlineUsersList
          .where((offlineUsers) =>
              offlineUsers.userName
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) |
              offlineUsers.userLastName.toLowerCase().contains(enteredKeyword.toLowerCase()) |
              offlineUsers.userNtcode.contains(enteredKeyword) |
              offlineUsers.time.contains(enteredKeyword)
              )
          .toList();

      _offlineUsersList = [];
      _offlineUsersList = _filteredList;
      // we use the toLowerCase() method to make it case-insensitive
    }
  }
}
