import 'package:flutter/material.dart';
import 'package:mpmed_doctor/authOtp/theme.dart';

class ReportItemScreen extends StatelessWidget {
  static const String routeName = '/brief_item_screen';

  String _appBarTitle = '';
  String _content = '';
  String _editedTime = '';

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> map =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _appBarTitle = map['appBarTitle'];
    _content = map['content'];
    _editedTime = map['editedTime'];
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/img/yellow_note_bg.jpg'),
                  fit: BoxFit.cover)),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Text("Last edited time : $_editedTime")),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Text(_content,style: TextStyle(fontSize: 18),)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
