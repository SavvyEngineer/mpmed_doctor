import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mpmed_doctor/appbar/universal_app_bar.dart';
import 'package:mpmed_doctor/documents/widgets/empty_docs_widget.dart';
import 'package:mpmed_doctor/notification/notification_bloc.dart';
import 'package:mpmed_doctor/questions/providers/question_provider.dart';
import 'package:mpmed_doctor/questions/screen/question_item_screen.dart';
import 'package:mpmed_doctor/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

class UsersListQuestions extends StatefulWidget {
  static const String routeName = '/one_question_users_screen';

  @override
  _UsersListQuestionsState createState() => _UsersListQuestionsState();
}

class _UsersListQuestionsState extends State<UsersListQuestions> {
  GlobalKey<ScaffoldState> _usersListQuestionscaffoldKey =
      GlobalKey<ScaffoldState>();

  final _advancedDrawerController = AdvancedDrawerController();

  Future _questionUserListFuture = null as Future;

  final LocalStorage storage = new LocalStorage('userData');
  Map userData = {};
  late Stream<LocalNotification> _notificationsStream;

  @override
  void initState() {
    _getNtcodeFromLS();
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      _obtainQuestionUsersList();
    });
    super.initState();
  }

  _getNtcodeFromLS() async {
    await storage.ready;
    userData = storage.getItem('profile');
    // map.forEach((key, value) {
    //   print('key=$key---value=$value');
    // });
    _questionUserListFuture = _obtainQuestionUsersList();
  }

  Future _obtainQuestionUsersList() {
    return Provider.of<QuestionsProviders>(context, listen: false)
        .fetchAndSetQuestionUsersList(userData['national_code']);
  }
    

  @override
  void dispose() {
    _advancedDrawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdropColor: Colors.blueGrey,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: true,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
          // NOTICE: Uncomment if you want to add shadow behind the page.
          // Keep in mind that it may cause animation jerks.
          // boxShadow: <BoxShadow>[
          //   BoxShadow(
          //     color: Colors.black12,
          //     blurRadius: 0.0,
          //   ),
          // ],
          borderRadius: const BorderRadius.all(Radius.circular(16))),
      drawer: AppDrawer(),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment
                    .bottomRight, // 10% of the width, so there are ten blinds.
                colors: <Color>[
                  Color(0xff606060),
                  Color(0xff295f6e),
                  Color(0xffd81a60)
                ], // red to yellow
                tileMode:
                    TileMode.repeated, // repeats the gradient over the canvas
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: UniversalRoundedAppBar(
              height: 100,
              uniKey: _usersListQuestionscaffoldKey,
              advancedDrawerController: _advancedDrawerController,
              isHome: false,
              headerWidget: Text(
                'سوالات بیماران',
                style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: _obtainQuestionUsersList,
              child: FutureBuilder(
                  future: _questionUserListFuture,
                  builder: (context, dataSnapShot) {
                    if (dataSnapShot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      if (dataSnapShot.error != null) {
                        return Center(child: Text('An error occured'));
                      } else {
                        return Consumer<QuestionsProviders>(
                            builder: (context, questionsUsersData, child) =>
                            
                                Column(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Center(
                                          child: TextField(
                                              onChanged: (keyChanged) {
                                                if (keyChanged == '') {
                                                  questionsUsersData
                                                      .fetchAndSetQuestionUsersList(
                                                          userData[
                                                              'national_code']);
                                                } else {
                                                  questionsUsersData
                                                      .runFilter(keyChanged);
                                                }
                                              },
                                              decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  prefixIcon: Icon(
                                                    Icons.search,
                                                    color: Colors.black38,
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      25)),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      25)))),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 8,
                                      child:
                                      questionsUsersData.getQuestionUsersData.length <1 
                                    ? Center(child: CircularProgressIndicator())
                                    :questionsUsersData
                                            .getQuestionUsersData.length == 0 ? empty_docs_widget(
                                                    "هنوز ازتون سوالی پرسیده نشده")
                                                : StaggeredGridView.countBuilder(
                                        itemCount: questionsUsersData
                                            .getQuestionUsersData.length,
                                        crossAxisCount: 4,
                                        itemBuilder:
                                            (BuildContext context, int index) =>
                                                InkWell(
                                          onTap: () {
                                            Navigator.of(context).pushNamed(
                                                QuestionItemScreen.routeName,
                                                arguments: {
                                                  'user_ref_id':
                                                      questionsUsersData
                                                          .getQuestionUsersData[
                                                              index]
                                                          .nationalCode,
                                                  'user_full_name':
                                                      '${questionsUsersData.getQuestionUsersData[index].name} ${questionsUsersData.getQuestionUsersData[index].lastName}',
                                                  'user_birth_date':
                                                      questionsUsersData
                                                          .getQuestionUsersData[
                                                              index]
                                                          .birthDate,
                                                  'notif_token':
                                                      questionsUsersData
                                                          .getQuestionUsersData[
                                                              index]
                                                          .notifToken
                                                });
                                          },
                                          child: GlassContainer(
                                            isFrostedGlass: true,
                                            frostedOpacity: 0.05,
                                            borderColor: Colors.transparent,
                                            blur: 20,
                                            elevation: 15,
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.25),
                                                Colors.white.withOpacity(0.05),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderGradient: LinearGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.60),
                                                Colors.white.withOpacity(0.0),
                                                Colors.white.withOpacity(0.0),
                                                Colors.white.withOpacity(0.60),
                                              ],
                                              stops: [0.0, 0.45, 0.55, 1.0],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            height: 130,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.5,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: ProfilePicture(
                                                    name:
                                                        '${questionsUsersData.getQuestionUsersData[index].lastName}',
                                                    radius: 31,
                                                    fontsize: 21,
                                                    random: true,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      '${questionsUsersData.getQuestionUsersData[index].name} ${questionsUsersData.getQuestionUsersData[index].lastName}',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                // Padding(
                                                //   padding:
                                                //       const EdgeInsets.all(
                                                //           8.0),
                                                //   child: Text(questionsUsersData
                                                //       .getQuestionUsersData[
                                                //           index]
                                                //       .birthDate
                                                //       .toString()),
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        staggeredTileBuilder: (int index) =>
                                            new StaggeredTile.fit(2),
                                        mainAxisSpacing: 8.0,
                                        crossAxisSpacing: 8.0,
                                      ),
                                    ),
                                  ],
                                ));
                      }
                    }
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
