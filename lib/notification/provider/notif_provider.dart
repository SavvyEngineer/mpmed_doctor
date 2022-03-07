import 'dart:convert';

import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;

class NotifProvider with ChangeNotifier {
  Future<void> registerToken(String token, String ntcode) async {
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://mpmed.ir/mp_app/v1/api.php?apicall=fcm_token_validator'));
    request.fields
        .addAll({'ntcode': ntcode, 'fcm_token': token, 'user_type': 'doc'});

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> getFcmTokenAndPush(String ntCode, String title, String body,
      String click_action, Map click_action_args) async {
    List<dynamic> recivedData;
    final Uri url = Uri.parse(
        'https://api.mpmed.ir/public/index.php/app/user/get/fcm-token/$ntCode');
    try {
      final response = await http.get(url);
      recivedData = jsonDecode(response.body);
      print(response.body.toString());
      if (response.statusCode == 200) {
        await sendNotificationToPatient(recivedData[0]['notif_token'], title,
            body, click_action, click_action_args);
      }
    } catch (e) {}
  }

  Future<void> sendNotificationToPatient(String r_token, String title,
      String body, String click_action, Map click_action_args) async {
    print('Send Notif to token=$r_token');
    var headers = {
      'Authorization':
          'key=AAAAx1OaUUo:APA91bGVkxKYWDG-MTFso9l-1oQyqG1e_abK1eMn3If221Xk8iFodhlSvabu1D37BEOzpSn6LhxixhsxpuzpC3qtu-S5Dm3yw6qhYtKYYDrDawz1h2avUmtJDJi40-FMpxZt4N1WgLRh',
      'Content-Type': 'application/json'
    };
    var request =
        http.Request('POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
    request.body = json.encode({
      "to": r_token,
      "notification": {"title": title, "body": body, "sound": "default"},
      "data": {"click_action": click_action, "arguments": click_action_args}
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }
}
