import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class Document {
  int id;
  String user_id;
  String name;
  String last_name;
  String date;
  String doctor_name;
  String reason;
  String lab_name;
  String exam_type;
  int is_reviewed;
  int is_seen;
  String review_doc_ntcode;

  Document(
      this.id,
      this.user_id,
      this.name,
      this.last_name,
      this.date,
      this.doctor_name,
      this.reason,
      this.lab_name,
      this.exam_type,
      this.is_reviewed,
      this.is_seen,
      this.review_doc_ntcode);
}

class DocumentMedia {
  int media_id;
  int doc_id;
  String doc_url;
  String doc_name;
  String doc_type;

  DocumentMedia(
      this.media_id, this.doc_id, this.doc_url, this.doc_name, this.doc_type);
}

class DocumentsProvider with ChangeNotifier {
  List<Document> _documents = [];
  List<DocumentMedia> _documentsMedia = [];
  List<Document> _userBasedDocuments = [];
  List<Document> _filteredByUser = [];

  List<Document> get getDocuments {
    return [..._documents];
  }

  List<Document> getDocumentsFilteredByUsers(String userId) {
    _filteredByUser = [];
    _documents.forEach((element) {
      if (element.user_id == userId) {
        _filteredByUser.add(element);
      }
    });
    return [..._filteredByUser];
  }

  List<Document> get usersWithDocument {
    // List<Document> _uniqueUsers = _documents;
    // for (var i = 0; i < _documents.length; i++) {
    //   if (!_uniqueUsers.contains(_documents[i].user_id)) {
    //     _uniqueUsers.add(_documents[i]);
    //   }
    // }

    // _uniqueUsers.forEach((element) {
    //   print(element.user_id.toString());
    // });
    return [..._userBasedDocuments];
  }

  List<DocumentMedia> get getDocumentsMedia {
    return [..._documentsMedia];
  }

  void runFilter(String enteredKeyword) {
    List<Document> _beforeSearchList = _filteredByUser;
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      // results = _allUsers;
      _beforeSearchList = _filteredByUser;
    } else {
      List<Document> _filteredList = _filteredByUser
          .where((user) =>
              user.reason.toLowerCase().contains(enteredKeyword.toLowerCase()) |
              user.doctor_name
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) |
              user.exam_type.contains(enteredKeyword) |
              user.lab_name.contains(enteredKeyword))
          .toList();

      _filteredByUser = [];
      _filteredByUser = _filteredList;
      // we use the toLowerCase() method to make it case-insensitive
    }

    notifyListeners();
  }

  void runFilterInusers(String enteredKeyword) {
    List<Document> _beforeSearchList = _userBasedDocuments;
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      // results = _allUsers;
      _beforeSearchList = _userBasedDocuments;
    } else {
      List<Document> _filteredList = _userBasedDocuments
          .where((user) =>
              user.name.toLowerCase().contains(enteredKeyword.toLowerCase()) |
              user.last_name
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) |
              user.user_id.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();

      _userBasedDocuments = [];
      _userBasedDocuments = _filteredList;
      // we use the toLowerCase() method to make it case-insensitive
    }

    notifyListeners();
  }

  // Future<void> fetchAndSetReviews(String doc_ntCode, String document_id) async {
  //   final Uri url = Uri.parse(
  //       'https://api.mpmed.ir/public/index.php/app/general/review-document/get/doctor/$document_id/$doc_ntCode/');
  //   List<dynamic> recivedData;
  //   _reviewList = [];

  //   try {
  //     final response = await http.get(url);
  //     recivedData = json.decode(response.body);
  //     // print(map['document_id'].toString());
  //      print(response.body.toString());

  //     for (var i = 0; i < recivedData.length; i++) {
  //       _reviewList.add(Review(
  //           reviewId: recivedData[i]['review_id'],
  //           content: recivedData[i]['content'],
  //           time: recivedData[i]['time'],
  //           doctorId: recivedData[i]['doctor_id'],
  //           doctorAnswer: recivedData[i]['doctor_answer'],
  //           userAnswer: recivedData[i]['user_answer']));
  //     }
  //     notifyListeners();
  //   } catch (e) {
  //     print('Error while fetching review ${e.toString()}');
  //   }
  // }

  Future<void> fetchAndSetDocuments(String doctorNtcode) async {
    _documents = [];
    _userBasedDocuments = [];
    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/doctor/access/get/$doctorNtcode');

    try {
      final response = await http.get(url);
      print(response.body.toString());

      List<dynamic> recivedData = json.decode(response.body) as List;

      for (var i = 0; i < recivedData.length; i++) {
        await _getAccessedDocuments(recivedData[i]["accessed_doc"].toString());
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _getAccessedDocuments(String docId) async {
    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/general/document/get/id/$docId');
    List<dynamic> recivedData;

    try {
      final response = await http.get(url);
      recivedData = json.decode(response.body);

      for (var i = 0; i < recivedData.length; i++) {
        _documents.add(Document(
            recivedData[i]["id"],
            recivedData[i]["user_id"],
            recivedData[i]["name"],
            recivedData[i]["last_name"],
            recivedData[i]["date"],
            recivedData[i]["doctor_name"],
            recivedData[i]["reason"],
            recivedData[i]["lab_name"],
            recivedData[i]["exam_type"],
            recivedData[i]["is_reviewed"],
            recivedData[i]["is_seen"],
            recivedData[i]["review_doc_ntcode"]));

        if (_userBasedDocuments.length != 0) {
          if (_userBasedDocuments[i].user_id != recivedData[i]["user_id"]) {
            _userBasedDocuments.add(Document(
                recivedData[i]["id"],
                recivedData[i]["user_id"],
                recivedData[i]["name"],
                recivedData[i]["last_name"],
                recivedData[i]["date"],
                recivedData[i]["doctor_name"],
                recivedData[i]["reason"],
                recivedData[i]["lab_name"],
                recivedData[i]["exam_type"],
                recivedData[i]["is_reviewed"],
                recivedData[i]["is_seen"],
                recivedData[i]["review_doc_ntcode"]));

            // print(recivedData[i]["user_id"]);
          }
        } else {
          _userBasedDocuments.add(Document(
              recivedData[i]["id"],
              recivedData[i]["user_id"],
              recivedData[i]["name"],
              recivedData[i]["last_name"],
              recivedData[i]["date"],
              recivedData[i]["doctor_name"],
              recivedData[i]["reason"],
              recivedData[i]["lab_name"],
              recivedData[i]["exam_type"],
              recivedData[i]["is_reviewed"],
              recivedData[i]["is_seen"],
              recivedData[i]["review_doc_ntcode"]));

          //print(recivedData[i]["user_id"]);
        }

        await _getDocumentsMedia(docId);
      }
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _getDocumentsMedia(String docId) async {
    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/general/document/media/get/id/$docId');
    List<dynamic> recivedData;

    try {
      final response = await http.get(url);
      recivedData = json.decode(response.body);

      for (var i = 0; i < recivedData.length; i++) {
        if (!_documentsMedia.contains(recivedData[i]['media_id'])) {
          _documentsMedia.add(DocumentMedia(
            recivedData[i]["media_id"],
            recivedData[i]["doc_id"],
            recivedData[i]["doc_url"],
            recivedData[i]["doc_name"],
            recivedData[i]["doc_type"],
          ));
        }
      }
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  // Future<void> createReview(
  //     String docId, String message, String doctor_nt_code) async {
  //   final Uri url = Uri.parse(
  //       'https://mpmed.ir/review_app/v1/api.php?apicall=createreview');

  //   try {
  //     Map<String, dynamic> map = new Map();

  //     map['document_id'] = docId;
  //     map['content'] = message;
  //     map['time'] = DateTime.now().millisecondsSinceEpoch.toString();
  //     map['doctor_id'] = doctor_nt_code;
  //     map['doctor_answer'] = "1";
  //     map['user_answer'] = "0";

  //     final response = await http.post(url, body: map);
  //     Map recivedData = json.decode(response.body);

  //     if (recivedData['error'] == false) {
  //       fetchAndSetReviews(doctor_nt_code, docId);
  //       // isGettingPatientReportLoading = false;
  //       // getReportsByUserId(userId);
  //       // _showSnackBar(Colors.green, 'report deleted successfully',
  //       //     patientReportScaffoldKey);
  //     } else {
  //       // isGettingPatientReportLoading = false;
  //       // _showSnackBar(
  //       //     Colors.red, 'Something went wrong', patientReportScaffoldKey);
  //     }
  //     if (response.statusCode! >= 400) {
  //       // isGettingPatientReportLoading = false;
  //       // _showSnackBar(
  //       //     Colors.red, 'Something went wrong', patientReportScaffoldKey);
  //     } else {
  //       // isGettingPatientReportLoading = false;
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }
}
