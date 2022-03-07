import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class QuestionUser {
  String? name;
  String? lastName;
  String? birthDate;
  String? nationalCode;
  String? notifToken;

  QuestionUser(
      {this.name,
      this.lastName,
      this.birthDate,
      this.nationalCode,
      this.notifToken});

  QuestionUser.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    lastName = json['lastName'];
    birthDate = json['birthDate'];
    nationalCode = json['national_code'];
    notifToken = json['notif_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['lastName'] = this.lastName;
    data['birthDate'] = this.birthDate;
    data['national_code'] = this.nationalCode;
    data['notif_token'] = this.notifToken;
    return data;
  }
}

class Question {
  int? questionId;
  String? userRefId;
  String? content;
  String? time;
  String? doctorRefId;
  int? doctorAnswer;
  int? userAnswer;

  Question(
      {this.questionId,
      this.userRefId,
      this.content,
      this.time,
      this.doctorRefId,
      this.doctorAnswer,
      this.userAnswer});

  Question.fromJson(Map<String, dynamic> json) {
    questionId = json['question_id'];
    userRefId = json['user_ref_id'];
    content = json['content'];
    time = json['time'];
    doctorRefId = json['doctor_ref_id'];
    doctorAnswer = json['doctor_answer'];
    userAnswer = json['user_answer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['question_id'] = this.questionId;
    data['user_ref_id'] = this.userRefId;
    data['content'] = this.content;
    data['time'] = this.time;
    data['doctor_ref_id'] = this.doctorRefId;
    data['doctor_answer'] = this.doctorAnswer;
    data['user_answer'] = this.userAnswer;
    return data;
  }
}

class QuestionsProviders with ChangeNotifier {
  List<QuestionUser> _questionUsersData = [];
  List<Question> _questionsData = [];

  List<QuestionUser> get getQuestionUsersData {
    return [..._questionUsersData];
  }

  List<Question> get getQuestionList {
    return [..._questionsData];
  }

  void runFilter(String enteredKeyword) {
    List<QuestionUser> _beforeSearchList = _questionUsersData;
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      // results = _allUsers;
      _beforeSearchList = _questionUsersData;
    } else {
      List<QuestionUser> _filteredList = _questionUsersData
          .where((user) =>
              user.name!.toLowerCase().contains(enteredKeyword.toLowerCase()) |
              user.lastName!
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()))
          .toList();

      _questionUsersData = [];
      _questionUsersData = _filteredList;
      // we use the toLowerCase() method to make it case-insensitive
    }

    notifyListeners();
  }

  Future<void> fetchAndSetQuestionUsersList(String doctor_ntcode) async {
    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/general/one-question/get/participants/$doctor_ntcode/{user_ntcode}/doc');

    List<dynamic> recivedData;
    List<QuestionUser> loadedData = [];

    try {
      final response = await http.get(url);
      recivedData = jsonDecode(response.body);

      for (var i = 0; i < recivedData.length; i++) {
        loadedData.add(QuestionUser(
            name: recivedData[i][0]['name'],
            lastName: recivedData[i][0]['lastName'],
            birthDate: recivedData[i][0]['birthDate'],
            nationalCode: recivedData[i][0]['national_code'],
            notifToken: recivedData[i][0]['notif_token']));
      }

      _questionUsersData = loadedData;
      notifyListeners();
    } catch (e) {}
  }

  Future<void> fetchAndSetUserQuestions(
      String doctor_ntcode, String user_ntCode) async {
    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/general/one-question/get/$user_ntCode/$doctor_ntcode');

    List<dynamic> recivedData;
    List<Question> loadedData = [];

    try {
      final response = await http.get(url);
      recivedData = jsonDecode(response.body);

      for (var i = 0; i < recivedData.length; i++) {
        loadedData.add(Question(
            content: recivedData[i]['content'],
            doctorAnswer: recivedData[i]['doctor_answer'],
            doctorRefId: recivedData[i]['doctor_ref_id'],
            questionId: recivedData[i]['question_id'],
            time: recivedData[i]['time'],
            userAnswer: recivedData[i]['user_answer'],
            userRefId: recivedData[i]['user_ref_id']));
      }

      _questionsData = loadedData;
      notifyListeners();
    } catch (e) {}
  }

  Future<void> createReview(String user_ntcode, String message,
      String doctor_nt_code, String time) async {
    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/general/one-question/create');

    try {
      Map<String, dynamic> map = {
        "question_id": 0,
        "user_ref_id": user_ntcode,
        "doctor_ref_id": doctor_nt_code,
        "content": message,
        "time": time,
        "doctor_answer": 1,
        "user_answer": 0
      };

      final response = await http.post(url, body: json.encode(map));
      Map recivedData = json.decode(response.body);
      if (recivedData["success"]) {
        print('Question Submitted SuccessFully');
      }
    } catch (e) {
      print('Error while Submitting question Error: ${e.toString()}');
    }
  }
}
