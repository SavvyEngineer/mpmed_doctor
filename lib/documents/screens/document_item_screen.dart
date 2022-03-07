import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mpmed_doctor/authOtp/theme.dart';
import 'package:mpmed_doctor/documents/provider/documents_provider.dart';
import 'package:mpmed_doctor/documents/review/model/review_model.dart';
import 'package:mpmed_doctor/documents/review/providers/review_provider.dart';
import 'package:mpmed_doctor/documents/screens/full_screen_image_page.dart';
import 'package:mpmed_doctor/documents/widgets/image_slider_widget.dart';
import 'package:mpmed_doctor/helper/get_data_from_ls.dart';
import 'package:mpmed_doctor/notification/notification_bloc.dart';
import 'package:mpmed_doctor/notification/provider/notif_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class DocumentItemScreen extends StatefulWidget {
  static const String routeName = '/document_item';

  @override
  _DocumentItemScreenState createState() => _DocumentItemScreenState();
}

class _DocumentItemScreenState extends State<DocumentItemScreen> {
  double _crossAxisSpacing = 4, _mainAxisSpacing = 1, _aspectRatio = 3;

  late Future? _reviewsListFuture;
  Future _documentsListFuture = null as Future;
  bool _isInit = true;
  late Stream<LocalNotification> _notificationsStream;

  int _crossAxisCount = 2;

  List<types.Message> _messages = [];
  int? id;
  String? patient_id;

  GetDataFromLs getDataFromLs = new GetDataFromLs();
  Map userData = {};
  var _user;
  var _currentIndex = 0;

  @override
  void initState() {
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      _obtainReviewListFuture();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _documentsListFuture = _obtainDocumentsFuture();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future _obtainReviewListFuture() {
    return Provider.of<ReviewProvider>(context, listen: false)
        .fetchAndSetReview(userData['national_code'], id.toString())
        .then((_) {
      _setReviews();
    });
  }

  Future _obtainDocumentsFuture() async {
    await getDataFromLs.getProfileData().then((value) {
      userData = value;
    });
    _user = types.User(
      id: userData['national_code'].toString(),
    );
    final arguments = ModalRoute.of(context)!.settings.arguments;

    Map recivedData;

    if (arguments.runtimeType.toString() !=
        '_InternalLinkedHashMap<String, Object>') {
      recivedData = json.decode(arguments.toString());
    } else {
      recivedData = arguments as Map;
    }
    id = recivedData['itemId'];
    patient_id = recivedData['patient_id'];
    _currentIndex = recivedData['page_index'];

    print('from Notif $id,$patient_id');
    _reviewsListFuture = _obtainReviewListFuture();
    return Provider.of<DocumentsProvider>(context, listen: false)
        .fetchAndSetDocuments(userData['national_code']);
  }

  Future<void> _setReviews() async {
    List<ReviewModel> _reviewList = [];
    var author;
    _reviewList =
        Provider.of<ReviewProvider>(context, listen: false).getReviews;
    _messages.clear();
    [
      ...{..._reviewList}
    ].forEach((element) {
      if (element.doctorAnswer == 1) {
        author = _user;
      } else {
        author = types.User(
          id: patient_id.toString(),
        );
      }
      final textMessage = types.TextMessage(
          author: author,
          createdAt: int.parse(element.time.toString()),
          id: element.reviewId.toString(),
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
    if (_messages.length == 0) {
      EasyLoading.showError('لطفآ منتظر پیام از بیمارتان بمانید');
    } else {
      var status = types.Status.sending;
      final StringId = DateTime.now().millisecondsSinceEpoch;
      var textMessage = types.TextMessage(
          author: _user,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: StringId.toString(),
          text: message.text,
          status: status);
      _addMessage(textMessage);
      await Provider.of<ReviewProvider>(context, listen: false)
          .createReview(
              id.toString(), message.text.toString(), userData['national_code'])
          .then((value) async {
        await Provider.of<NotifProvider>(context, listen: false).getFcmTokenAndPush(
            patient_id.toString(),
            "پیام جدید",
            'پزشک ${userData['name']} ${userData['lastName']} متخصص ${userData['specialty']} پیامی جدید برای شما ارسال کرده است',
            "review_screen", {
          'itemId': id,
          'doctor_ntcode': userData['national_code'],
          'doc_notif_token': userData['notif_token'],
          'page_index': 1
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SalomonBottomBar(
        margin: EdgeInsets.only(left: 40, top: 8, bottom: 8, right: 40),
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          SalomonBottomBarItem(
              icon: Icon(Icons.document_scanner), title: Text('مدارک')),
          SalomonBottomBarItem(
              icon: Icon(Icons.chat), title: Text('گفتگو با بیمار'))
        ],
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: MyColors.primaryColorLight.withAlpha(20),
            ),
            child: Icon(
              Icons.arrow_back_ios,
              color: MyColors.primaryColor,
              size: 16,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Color(0x44000000),
        elevation: 0,
      ),
      body: _currentIndex == 0
          ? FutureBuilder(
              future: _documentsListFuture,
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
                    return Consumer<DocumentsProvider>(
                      builder: (context, documentData, child) {
                        var documentElement = documentData.getDocuments
                            .firstWhere((element) => element.id == id);
                        return Column(
                          children: [
                            Expanded(
                              flex: 8,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        FullScreenImageViewer.routeName,
                                        arguments: {
                                          'documentId': documentElement.id,
                                          'documentMediaList':
                                              documentData.getDocumentsMedia
                                        });
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
                                        .75,
                                    child: image_slider_widget(
                                      id: documentElement.id,
                                      mediaData: documentData.getDocumentsMedia,
                                      changeDirection: Axis.horizontal,
                                      imageScale: BoxFit.contain,
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .75,
                                      is_full_screen: true,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Divider(),
                            Expanded(
                              flex: 2,
                              child: SingleChildScrollView(
                                child: GridView.count(
                                  crossAxisCount: _crossAxisCount,
                                  crossAxisSpacing: _crossAxisSpacing,
                                  mainAxisSpacing: _mainAxisSpacing,
                                  childAspectRatio: _aspectRatio,
                                  padding: EdgeInsets.zero,
                                  physics: ScrollPhysics(),
                                  shrinkWrap: true,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text("نام"),
                                        subtitle: Text(documentElement.name),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text("نام خانوادگی"),
                                        subtitle:
                                            Text(documentElement.last_name),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text("تاریخ"),
                                        subtitle: Text(documentElement.date),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          height: 20,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: Text("پزشک معالج"),
                                            subtitle: Text(
                                                documentElement.doctor_name),
                                          )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text("دلیل مراجعه"),
                                        subtitle: Text(documentElement.reason),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text("آزمایشگاه"),
                                        subtitle:
                                            Text(documentElement.lab_name),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text("نوع آزمایش"),
                                        subtitle:
                                            Text(documentElement.exam_type),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    );
                  }
                }
              })
          : ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              child: Card(
                elevation: 15,
                child: FutureBuilder(
                    future: _reviewsListFuture,
                    builder: (context, dataSnapShot) {
                      if (dataSnapShot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        if (dataSnapShot.error != null) {
                          print(dataSnapShot.error.toString());
                          return Center(
                            child: Text('An error occured'),
                          );
                        } else {
                          return SafeArea(
                            bottom: false,
                            child: Chat(
                                messages: _messages,
                                onSendPressed: _handleSendPressed,
                                user: _user,
                                l10n: const ChatL10nEn(
                                    inputPlaceholder: 'پاسخ شما',
                                    attachmentButtonAccessibilityLabel: '',
                                    emptyChatPlaceholder:
                                        'برای شما پیامی ارسال نشده است',
                                    fileButtonAccessibilityLabel: '',
                                    sendButtonAccessibilityLabel: '')),
                          );
                        }
                      }
                    } //
                    ),
                // Text("no chat yet"),
              ),
            ),
    );
  }
}
