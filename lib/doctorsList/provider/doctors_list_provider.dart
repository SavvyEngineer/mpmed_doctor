import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mpmed_doctor/authOtp/stores/doctor_pojo.dart';
import 'package:http/http.dart' as http;

class WorkingHourModel {
  int? id;
  String? doctorRefId;
  String? editedTime;
  String? day0;
  String? day1;
  String? day2;
  String? day3;
  String? day4;
  String? day5;
  String? day6;

  WorkingHourModel(
      {this.id,
      this.doctorRefId,
      this.editedTime,
      this.day0,
      this.day1,
      this.day2,
      this.day3,
      this.day4,
      this.day5,
      this.day6});

  WorkingHourModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doctorRefId = json['doctor_ref_id'];
    editedTime = json['edited_time'];
    day0 = json['day_0'];
    day1 = json['day_1'];
    day2 = json['day_2'];
    day3 = json['day_3'];
    day4 = json['day_4'];
    day5 = json['day_5'];
    day6 = json['day_6'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['doctor_ref_id'] = this.doctorRefId;
    data['edited_time'] = this.editedTime;
    data['day_0'] = this.day0;
    data['day_1'] = this.day1;
    data['day_2'] = this.day2;
    data['day_3'] = this.day3;
    data['day_4'] = this.day4;
    data['day_5'] = this.day5;
    data['day_6'] = this.day6;
    return data;
  }
}

class DoctorsListProvider with ChangeNotifier {
  List<Profile> _doctorsList = [];
  List<WorkingHourModel> _workingHourModel = [];
  List<String> _workingHourByDay = [];

  List<Profile> get getDoctorsList {
    return [..._doctorsList];
  }

  List<String> get getWorkingHoursByDay {
    return [..._workingHourByDay];
  }

  List<WorkingHourModel> get getWorkingHours {
    return [..._workingHourModel];
  }

  void runFilter(String enteredKeyword) {
    List<Profile> _beforeSearchList = _doctorsList;
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      // results = _allUsers;
      _beforeSearchList = _doctorsList;
    } else {
      List<Profile> _filteredList = _doctorsList
          .where((doctor) =>
              doctor.name!
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) |
              doctor.lastName!
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) |
              doctor.specialty!
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) |
              doctor.wcity!
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) |
              doctor.wstate!
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()))
          .toList();

      _doctorsList = [];
      _doctorsList = _filteredList;
      // we use the toLowerCase() method to make it case-insensitive
    }

    notifyListeners();
  }

  Future<void> fetchAndSetDoctorsList() async {
    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/general/doctors/list/get');
    List<dynamic> recivedData;
    List<Profile> loadedData = [];

    try {
      final response = await http.get(url);
      recivedData = jsonDecode(response.body);

      for (var i = 0; i < recivedData.length; i++) {
        loadedData.add(Profile(
            mdCode: recivedData[i]['md_code'],
            specialty: recivedData[i]['specialty'],
            name: recivedData[i]['name'],
            email: recivedData[i]['email'],
            mobile: recivedData[i]['mobile'],
            apikey: recivedData[i]['apikey'],
            status: recivedData[i]['status'],
            createdAt: recivedData[i]['created_at'],
            lastName: recivedData[i]['lastname'],
            fatherName: recivedData[i]['fatherName'],
            birthDate: recivedData[i]['birthDate'],
            wcity: recivedData[i]['wcity'],
            wstate: recivedData[i]['wstate'],
            nationalCode: recivedData[i]['national_code'],
            isApproved: recivedData[i]['is_approved'],
            usedMdApp: recivedData[i]['used_md_app'],
            profilePic: recivedData[i]['profile_pic'],
            notifToken: recivedData[i]['notif_token']));
      }
      _doctorsList = loadedData;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> uploadWorkingHours(Map map) async {
    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/doctor/working-hours');

    try {
      final response = await http.post(url, body: json.encode(map));
      print(response.body.toString());
      Map responseData = jsonDecode(response.body);
      if (responseData["success"]) {
        print('Working Hours Uploaded');
        fetchAndSetWorkingHours(map["doctor_ref_id"]);
      } else {
        print('SomeThing Went Wrong');
      }
    } catch (e) {}
  }

  Future<void> updateWorkingHours(Map map) async {
    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/doctors/working_hour/${map["doctor_ref_id"]}');

    try {
      final response = await http.put(url, body: json.encode(map));
      print(response.body.toString());
      Map responseData = jsonDecode(response.body);
      if (responseData["success"]) {
        print('Working Hours Updated');
        fetchAndSetWorkingHours(map["doctor_ref_id"]);
      } else {
        print('SomeThing Went Wrong');
      }
    } catch (e) {}
  }


  Future<void> fetchAndSetWorkingHours(String doctor_ntcode) async {
    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/doctors/working_hour/$doctor_ntcode');

    List<dynamic> recivedData;
    List<WorkingHourModel> loadedData = [];
    _workingHourByDay = [];

    try {
      final response = await http.get(url);
      recivedData = jsonDecode(response.body);

      for (var i = 0; i < recivedData.length; i++) {
        loadedData.add(WorkingHourModel(
          id: recivedData[i]['id'],
          doctorRefId: recivedData[i]['doctor_ref_id'],
          editedTime: recivedData[i]['edited_time'],
          day0: recivedData[i]['day_0'],
          day1: recivedData[i]['day_1'],
          day2: recivedData[i]['day_2'],
          day3: recivedData[i]['day_3'],
          day4: recivedData[i]['day_4'],
          day5: recivedData[i]['day_5'],
          day6: recivedData[i]['day_6'],
        ));

        _workingHourByDay = [
          recivedData[i]['day_0'],
          recivedData[i]['day_1'],
          recivedData[i]['day_2'],
          recivedData[i]['day_3'],
          recivedData[i]['day_4'],
          recivedData[i]['day_5'],
          recivedData[i]['day_6'],
        ];
      }
      _workingHourModel = loadedData;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

}
