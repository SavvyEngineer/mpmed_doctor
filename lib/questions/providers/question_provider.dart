import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class QuestionUser {
  String? name;
  String? lastName;
  String? birthDate;
  String? nationalCode;

  QuestionUser({this.name, this.lastName, this.birthDate, this.nationalCode});

  QuestionUser.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    lastName = json['lastName'];
    birthDate = json['birthDate'];
    nationalCode = json['national_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['lastName'] = this.lastName;
    data['birthDate'] = this.birthDate;
    data['national_code'] = this.nationalCode;
    return data;
  }
}

class Question {
  int? questionId;
  String? content;
  String? time;
  String? sessionId;
  int? doctorAnswer;
  int? userAnswer;

  Question(
      {this.questionId,
      this.content,
      this.time,
      this.sessionId,
      this.doctorAnswer,
      this.userAnswer});

  Question.fromJson(Map<String, dynamic> json) {
    questionId = json['question_id'];
    content = json['content'];
    time = json['time'];
    sessionId = json['session_id'];
    doctorAnswer = json['doctor_answer'];
    userAnswer = json['user_answer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['question_id'] = this.questionId;
    data['content'] = this.content;
    data['time'] = this.time;
    data['session_id'] = this.sessionId;
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
              user.name!
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) |
              user.lastName!.toLowerCase().contains(enteredKeyword.toLowerCase())
              )
          .toList();

      _questionUsersData = [];
      _questionUsersData = _filteredList;
      // we use the toLowerCase() method to make it case-insensitive
    }

    notifyListeners();
  }

  Future<void> fetchAndSetQuestionUsersList(
      String doctor_ntcode) async {
    final Uri url = Uri.parse(
        'https://mpmed.ir/one_ques_app/v1/api.php?apicall=get_participents');

    List<dynamic> recivedData;
    List<QuestionUser> loadedData = [];
    Map map = new Map();

    map['doctor_ntcode'] = doctor_ntcode;
    map['ask_type'] = 'doc';

    try {
      final response = await http.post(url, body: map);
      recivedData = jsonDecode(response.body);

      for (var i = 0; i < recivedData.length; i++) {
        loadedData.add(QuestionUser(
          name: recivedData[i]['name'],
          lastName: recivedData[i]['lastName'],
          birthDate: recivedData[i]['birthDate'],
          nationalCode: recivedData[i]['national_code']
        ));
      }

      _questionUsersData = loadedData;
      notifyListeners();
    } catch (e) {}
  }

  Future<void> fetchAndSetUserQuestions(
      String doctor_ntcode,String user_ntCode) async {
    final Uri url = Uri.parse(
        'https://mpmed.ir/one_ques_app/v1/api.php?apicall=get_questions');

    List<dynamic> recivedData;
    List<Question> loadedData = [];
    Map map = new Map();

    map['doctor_ntcode'] = doctor_ntcode;
    map['user_ntcode'] = user_ntCode;

    try {
      final response = await http.post(url, body: map);
      recivedData = jsonDecode(response.body);

      for (var i = 0; i < recivedData.length; i++) {
        loadedData.add(Question(
          content: recivedData[i]['content'],
          time: recivedData[i]['time'],
          doctorAnswer: recivedData[i]['doctor_answer'],
          userAnswer: recivedData[i]['user_answer'],
          sessionId: recivedData[i]['session_id'],
          questionId: recivedData[i]['question_id']
        )
        );
      }

      _questionsData
       = loadedData;
      notifyListeners();
    } catch (e) {}
  }

  Future<void> createReview(
      String user_ntcode, String message, String doctor_nt_code) async {
    final Uri url = Uri.parse(
        'https://mpmed.ir/one_ques_app/v1/api.php?apicall=create_question');

    try {
      Map<String, dynamic> map = new Map();

      map['user_ntcode'] = user_ntcode;
      map['doctor_ntcode'] = doctor_nt_code;
      map['content'] = message;
      map['user_answer'] = '0';
      map['doctor_answer'] = "1";
      map['time'] = DateTime.now().millisecondsSinceEpoch.toString();

      final response = await http.post(url, body: map);
      Map recivedData = json.decode(response.body);

      if (recivedData['error'] == false) {
        fetchAndSetUserQuestions(doctor_nt_code, user_ntcode);
        // isGettingPatientReportLoading = false;
        // getReportsByUserId(userId);
        // _showSnackBar(Colors.green, 'report deleted successfully',
        //     patientReportScaffoldKey);
      } else {
        // isGettingPatientReportLoading = false;
        // _showSnackBar(
        //     Colors.red, 'Something went wrong', patientReportScaffoldKey);
      }
      if (response.statusCode! >= 400) {
        // isGettingPatientReportLoading = false;
        // _showSnackBar(
        //     Colors.red, 'Something went wrong', patientReportScaffoldKey);
      } else {
        // isGettingPatientReportLoading = false;
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
