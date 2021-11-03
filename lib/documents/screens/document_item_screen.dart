import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mpmed_doctor/authOtp/theme.dart';
import 'package:mpmed_doctor/documents/provider/documents_provider.dart';
import 'package:mpmed_doctor/documents/widgets/image_slider_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class DocumentItemScreen extends StatefulWidget {
  static const String routeName = '/document_item';

  @override
  _DocumentItemScreenState createState() => _DocumentItemScreenState();
}

class _DocumentItemScreenState extends State<DocumentItemScreen> {
  double _crossAxisSpacing = 4, _mainAxisSpacing = 1, _aspectRatio = 3;

  Future _reviewsListFuture = null as Future;
  bool _isInit = true;

  int _crossAxisCount = 2;

  List<types.Message> _messages = [];
  int? id;

  final LocalStorage storage = new LocalStorage('userData');
  Map userData = {};
  var _user;

  _getNtcodeFromLS() async {
    await storage.ready;
    userData = storage.getItem('profile');
    // map.forEach((key, value) {
    //   print('key=$key---value=$value');
    // });
    _user = types.User(
      id: userData['national_code'].toString(),
    );

    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    id = arguments['itemId'];
    _reviewsListFuture = _obtainDoctorsListFuture();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _getNtcodeFromLS();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future _obtainDoctorsListFuture() {
    return Provider.of<DocumentsProvider>(context, listen: false)
        .fetchAndSetReviews(userData['national_code'], id.toString())
        .then((_) async {
      final documentData =
          Provider.of<DocumentsProvider>(context, listen: false);
      await _setReviews(documentData);
    });
  }

  Future<void> _setReviews(DocumentsProvider documentData) async {
    var author;
    List<Review> _reviewList =
        Provider.of<DocumentsProvider>(context, listen: false).getReviews;

    final documentElement =
        documentData.getDocuments.firstWhere((element) => element.id == id);

    _reviewList.forEach((element) {
      if (element.doctorAnswer == 1) {
        author = _user;
      } else {
        author = types.User(
          id: documentElement.user_id,
        );
      }
      final textMessage = types.TextMessage(
          author: author,
          createdAt: int.parse(element.time),
          id: element.reviewId.toString(),
          text: element.content,
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
    await Provider.of<DocumentsProvider>(context, listen: false)
        .createReview(
            id.toString(), message.text.toString(), userData['national_code'])
        .then((value) {
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
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    int id = arguments['itemId'];
    final mediaQuery = MediaQuery.of(context).size;

    final documentData = Provider.of<DocumentsProvider>(context, listen: false);
    final documentElement =
        documentData.getDocuments.firstWhere((element) => element.id == id);

    var width =
        (mediaQuery.width - ((_crossAxisCount - 1) * _crossAxisSpacing)) /
            _crossAxisCount;
    var height = width / _aspectRatio;

    return Scaffold(
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
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Material(
              color: Colors.transparent,
              elevation: 15,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15)),
                child: GlassContainer.clearGlass(
                  height: mediaQuery.height * 0.4,
                  width: mediaQuery.width,
                  child: image_slider_widget(
                    id: documentElement.id,
                    mediaData: documentData.getDocumentsMedia,
                    changeDirection: Axis.vertical,
                    imageScale: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: ClipRRect(
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
          ),
          Expanded(
            flex: 4,
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
                      subtitle: Text(documentElement.last_name),
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
                          subtitle: Text(documentElement.doctor_name),
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
                      subtitle: Text(documentElement.lab_name),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text("نوع آزمایش"),
                      subtitle: Text(documentElement.exam_type),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
