import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:localstorage/localstorage.dart';
import 'package:mpmed_doctor/notification/notification_bloc.dart';
import 'package:mpmed_doctor/notification/provider/notif_provider.dart';
import 'package:mpmed_doctor/questions/providers/question_provider.dart';
import 'package:provider/provider.dart';

class QuestionItemScreen extends StatefulWidget {
  static const String routeName = '/question_item_screen';

  @override
  QuestionItemScreenState createState() => QuestionItemScreenState();
}

class QuestionItemScreenState extends State<QuestionItemScreen> {
  Future _questionsListFuture = null as Future;

  List<types.Message> _messages = [];
  String? user_refId;
  String? userFullName;
  String? userBirthDate;
  String? notifToken;

  late Stream<LocalNotification> _notificationsStream;

  bool _isInit = true;

  final LocalStorage storage = new LocalStorage('userData');
  Map userData = {};
  var _user;

  _getNtcodeFromLS() async {
    await storage.ready;
    userData = storage.getItem('profile');
    // map.forEach((key, value) {
    //   print('key=$key---value=$value');
    // });
    final arguments = ModalRoute.of(context)!.settings.arguments;

    Map recivedData;

    if (arguments.runtimeType.toString() != '_InternalLinkedHashMap<String, String?>') {
      recivedData = json.decode(arguments.toString());
    } else {
      recivedData = arguments as Map;
    }

    user_refId = recivedData['user_ref_id'];
    userFullName = recivedData['user_full_name'];
    userBirthDate = recivedData['user_birth_date'];
    notifToken = recivedData['notif_token'];
    _questionsListFuture = _obtainDoctorsListFuture();
    _user = types.User(
      id: userData['national_code'].toString(),
    );
  }

  @override
  void initState() {
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      _obtainDoctorsListFuture();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _getNtcodeFromLS();
    }
    _isInit = false;
  }

  Future _obtainDoctorsListFuture() {
    return Provider.of<QuestionsProviders>(context, listen: false)
        .fetchAndSetUserQuestions(
            userData['national_code'], user_refId.toString())
        .then((_) async {
      final questionData =
          Provider.of<QuestionsProviders>(context, listen: false);
      await _setQuestions(questionData);
    });
  }

  Future<void> _setQuestions(QuestionsProviders questionData) async {
    var author;
    List<Question> _questionsList =
        Provider.of<QuestionsProviders>(context, listen: false).getQuestionList;

    _questionsList.forEach((element) {
      if (element.doctorAnswer == 1) {
        author = _user;
      } else {
        author = types.User(
          id: user_refId.toString(),
        );
      }
      final textMessage = types.TextMessage(
          author: author,
          id: element.questionId.toString(),
          //createdAt: int.parse(element.time as String),
          text: element.content.toString(),
          status: types.Status.sent);

      _addMessage(textMessage);
    });
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    var status = types.Status.sending;
    final StringId = DateTime.now().millisecondsSinceEpoch;
    var textMessage = types.TextMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: StringId.toString(),
        text: message.text,
        status: status);
    _addMessage(textMessage);
    await Provider.of<QuestionsProviders>(context, listen: false)
        .createReview(user_refId.toString(), message.text.toString(),
            userData['national_code'], StringId.toString())
        .then((value) async {
      await Provider.of<NotifProvider>(context, listen: false)
          .sendNotificationToPatient(notifToken.toString(), 'پاسخ جدید',
              'پزشک ${userData['name']} ${userData['lastName']} متخصص ${userData['specialty']} برای سوال شما پاسخی ارسال کرده اند ',"question_screen",{
                'user_ref_id':userData['national_code'],
                'user_full_name':'${userData['name']} ${userData['lastName']}',
                'user_speciality':userData['specialty'],
                'notif_token':userData['notif_token'],
              });
      _messages.remove(textMessage);

      var updatedTextMessage = types.TextMessage(
          author: _user,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: StringId.toString(),
          text: message.text,
          status: types.Status.sent);
      _addMessage(updatedTextMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: double.infinity,
                color: Colors.green,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                                backgroundColor: Colors.lightGreen,
                                child: Icon(Icons.arrow_back)),
                          ),
                        )),
                    Text(userFullName.toString(),
                        style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text(userBirthDate.toString(),
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black))
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              flex: 8,
              child: SafeArea(
                bottom: false,
                child: FutureBuilder(
                  future: _questionsListFuture,
                  builder: (context, dataSnapShot) {
                    if (dataSnapShot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      if (dataSnapShot.error != null) {
                        return Center(
                          child: Text('An error occured'),
                        );
                      } else {
                        return Chat(
                          messages: _messages,
                          onSendPressed: _handleSendPressed,
                          user: _user,
                          l10n: const ChatL10nEn(
                              inputPlaceholder: 'پاسخ شما',
                              attachmentButtonAccessibilityLabel: '',
                              emptyChatPlaceholder:
                                  'برای شما پیامی ارسال نشده است',
                              fileButtonAccessibilityLabel: '',
                              sendButtonAccessibilityLabel: ''),
                        );
                      }
                    }
                  },
                ),
              ))
        ],
      ),
    );
  }
}
