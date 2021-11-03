import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mpmed_doctor/authOtp/stores/doctor_pojo.dart';
import 'package:http/http.dart' as http;

class DoctorsListProvider with ChangeNotifier {
  List<Profile> _doctorsList = [];

  List<Profile> get getDoctorsList {
    return [..._doctorsList];
  }

  void runFilter(String enteredKeyword) {
    List<Profile> _beforeSearchList = _doctorsList;
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      // results = _allUsers;
      _beforeSearchList = _doctorsList;
    } else {
      List<Profile> _filteredList = _doctorsList
          .where((doctor) => doctor.name!
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()) |
              doctor.lastName!.toLowerCase().contains(enteredKeyword.toLowerCase()) |
              doctor.specialty!.toLowerCase().contains(enteredKeyword.toLowerCase()) |
              doctor.wcity!.toLowerCase().contains(enteredKeyword.toLowerCase()) |
              doctor.wstate!.toLowerCase().contains(enteredKeyword.toLowerCase())
              )
          .toList();

      _doctorsList = [];
      _doctorsList= _filteredList;
      // we use the toLowerCase() method to make it case-insensitive
    }

    notifyListeners();
  }

  Future<void> fetchAndSetDoctorsList() async {
    final Uri url =
        Uri.parse('http://mpmed.ir/mp_app/v1/api.php?apicall=get_doctors_list');
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
            lastName: recivedData[i]['lastName'],
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
}
