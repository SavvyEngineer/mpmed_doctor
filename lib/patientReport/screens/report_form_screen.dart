import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mpmed_doctor/authOtp/theme.dart';
import 'package:mpmed_doctor/authOtp/widgets/loader_hud.dart';
import 'package:mpmed_doctor/patientReport/providers/patient_report_provider.dart';
import 'package:mpmed_doctor/textToSpeech/screens/speechScreen.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';

class ReportFormScreen extends StatefulWidget {
  static const String routeName = '/report_form_screen';
  @override
  _ReportFormScreenState createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  Map<String, dynamic> map = {};
  String label = 'تاریخ ثبت گزارش';
  bool _isInit = true;

  GlobalKey<FormState> _key = new GlobalKey();
  bool _isAddReport = false;
  bool _isReportEdit = false;
  bool _isAddUser = false;
  String _patientName = '';
  String _patientLastName = '';
  int _patient_offline_id = null as int;
  int _brief_id = null as int;
  String _content = '';
  String _editedTime = '';

  String _title = '';

  final _nameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _dateFocusNode = FocusNode();
  final _visitContentFocusNode = FocusNode();
  final _patientNtcodeFocusNode = FocusNode();

  TextEditingController _briefController = new TextEditingController();

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _dateFocusNode.dispose();
    _visitContentFocusNode.dispose();
    _patientNtcodeFocusNode.dispose();
    _briefController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final Map<String, dynamic> map =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      if (map != null) {
        _isAddReport = map["isAddReport"];
        _patientName = map["patientName"];
        _patientLastName = map["patientLastName"];
        _patient_offline_id = map["patientId"];
        _isReportEdit = map['isReportEdit'];
        _brief_id = map['brief_id'];
        _content = map['brief_content'];
        _editedTime = map['edited_time'];
      }
      if (_isAddReport) {
        _isAddUser = false;
        _title = 'شما در حال ثبت گزارش جدید برای بیمار';
      } else if (_isReportEdit) {
        _isAddUser = false;
        _title = 'شما در حال ویرایش گزارش ویزیت بیمار';
      } else {
        _isAddUser = true;
      }
      if (_isReportEdit) {
        label = _editedTime;
        _briefController.text = _content;
      }
    }
    _isInit = false;
  }

  _sendToServer() {
    _key.currentState!.save();
    if (_isAddReport) {
      map["offline_user_ref_id"] = _patient_offline_id;
      Provider.of<PatientReportProvider>(context, listen: false)
          .addReports(map, context);
    } else if (_isReportEdit) {
      map["offline_user_ref_id"] = _patient_offline_id;
      map["brief_id"] = _brief_id;
      map["content"] = _content;
      map["time"] = label;
      Provider.of<PatientReportProvider>(context, listen: false)
          .editReport(map, context);
    } else {
      Provider.of<PatientReportProvider>(context, listen: false)
          .setReports(map, context);
    }
  }

  Widget _TextReciver(
      {required String hinttext,
      required String key,
      required TextInputAction textInputAction,
      required TextInputType textInputType,
      required FocusNode focusNode,
      required FocusNode nextFocus,
      int maxLines = 1}) {
    return new TextFormField(
      minLines: 1,
      keyboardType: textInputType,
      textInputAction: textInputAction,
      focusNode: focusNode,
      maxLines: maxLines,
      onFieldSubmitted: (value) {
        if (textInputAction != TextInputAction.done) {
          FocusScope.of(context).requestFocus(nextFocus);
        }
      },
      decoration: InputDecoration(
        hintText: hinttext,
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      // validator: FormValidator().validateEmail,
      onSaved: (value) {
        map[key] = value.toString();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientReportProvider>(
        builder: (_, PatientReportProvider, __) {
      return Observer(
          builder: (_) => LoaderHUD(
              inAsyncCall: PatientReportProvider.isPatientReportLoading,
              child: Scaffold(
                key: PatientReportProvider.patientReportFormScaffoldKey,
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: ListTile(
                          leading: IconButton(
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
                          title: Text('گزارش ویزیت بیمار',style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      SafeArea(
                        child: Center(
                          child: Container(
                            child: Column(
                              children: [
                                if (!_isAddUser)
                                  Text(
                                      '$_title $_patientName $_patientLastName'),
                                Form(
                                    key: _key,
                                    child: Column(
                                      children: [
                                        new SizedBox(height: 15.0),
                                        if (_isAddUser)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .4,
                                                child: _TextReciver(
                                                    hinttext: 'نام',
                                                    key: 'user_name',
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    textInputType:
                                                        TextInputType.name,
                                                    focusNode: _nameFocusNode,
                                                    nextFocus:
                                                        _lastNameFocusNode),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        .5 -
                                                    10,
                                                child: _TextReciver(
                                                    hinttext: 'نام خانوادگی',
                                                    key: 'user_last_name',
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    textInputType:
                                                        TextInputType.text,
                                                    focusNode:
                                                        _lastNameFocusNode,
                                                    nextFocus:
                                                        _patientNtcodeFocusNode),
                                              ),
                                            ],
                                          ),
                                        new SizedBox(height: 15.0),
                                        if (_isAddUser)
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: _TextReciver(
                                                hinttext: 'کد ملی بیمار',
                                                key: 'user_ntcode',
                                                textInputAction:
                                                    TextInputAction.next,
                                                textInputType:
                                                    TextInputType.number,
                                                focusNode:
                                                    _patientNtcodeFocusNode,
                                                nextFocus: _dateFocusNode),
                                          ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton(
                                                focusNode: _dateFocusNode,
                                                onPressed: () async {
                                                  Jalali? picked =
                                                      await showPersianDatePicker(
                                                    context: context,
                                                    initialDate: _isReportEdit
                                                        ? Jalali(
                                                            int.parse(label
                                                                .split('-')[0]),
                                                            int.parse(label
                                                                .split('-')[1]),
                                                            int.parse(label
                                                                .split('-')[2]))
                                                        : Jalali.now(),
                                                    firstDate: Jalali(1200, 1),
                                                    lastDate: Jalali.now(),
                                                  );
                                                  if (picked != null) {
                                                    setState(() {
                                                      label = picked
                                                          .toJalaliDateTime()
                                                          .split(" ")[0];
                                                      map["time"] =
                                                          label.toString();
                                                    });
                                                  }
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          _visitContentFocusNode);
                                                },
                                                child: Text(label.toString())),
                                            Text(label.toString())
                                          ],
                                        ),
                                        new SizedBox(height: 15.0),
                                        Row(
                                          children: [
                                            ClipOval(
                                              child: Material(
                                                color:
                                                    Colors.blue, // Button color
                                                child: InkWell(
                                                  splashColor: Colors
                                                      .red, // Splash color
                                                  onTap: () async {
                                                    await Navigator.of(context)
                                                        .pushNamed(SpeechScreen
                                                            .routeName)
                                                        .then((value) {
                                                      setState(() {
                                                        if (value.toString() ==
                                                            "null") {
                                                          value =
                                                              "گزارش ویزیت بیمار";
                                                        }
                      
                                                        _briefController.text =
                                                            value.toString();
                                                      });
                                                    }) as Object;
                                                  },
                                                  child: SizedBox(
                                                      width: 46,
                                                      height: 46,
                                                      child: Icon(Icons.mic)),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                child: TextFormField(
                                                  controller: _briefController,
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  textInputAction:
                                                      TextInputAction.newline,
                                                  focusNode:
                                                      _visitContentFocusNode,
                                                  maxLines: 13,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        'گزارش ویزیت بیمار',
                                                    contentPadding:
                                                        EdgeInsets.fromLTRB(
                                                            20.0,
                                                            15.0,
                                                            20.0,
                                                            15.0),
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    32.0)),
                                                  ),
                                                  // validator: FormValidator().validateEmail,
                                                  onSaved: (value) {
                                                    if (_isReportEdit) {
                                                      _content =
                                                          value.toString();
                                                    } else {
                                                      map['content'] =
                                                          value.toString();
                                                    }
                                                  },
                                                ))
                                            //    _TextReciver(
                                            //       breifFromSpeech:
                                            //           briefText,
                                            //       hinttext: 'Type your brief ...',
                                            //       key: 'visit_content',
                                            //       textInputAction:
                                            //           TextInputAction.newline,
                                            //       textInputType:
                                            //           TextInputType.multiline,
                                            //       focusNode: _visitContentFocusNode,
                                            //       maxLines: 20,
                                            //       nextFocus: null as FocusNode),
                                            // ),
                                          ],
                                        ),
                                        ElevatedButton(
                                            onPressed: () {
                                              _sendToServer();
                                            },
                                            child: Text('ثبت'))
                                      ],
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )));
    });
  }
}
