import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mpmed_doctor/appbar/universal_app_bar.dart';
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
  void initState() {
    super.initState();
    _getNtcodeFromLS();
    
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
      child: Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: UniversalRoundedAppBar(
          height: 100,
          uniKey: _usersListQuestionscaffoldKey,
          advancedDrawerController: _advancedDrawerController,
          isHome: false,
          headerWidget: Text(
            'سوالات بیماران',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700,color: Colors.white),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _obtainQuestionUsersList,
          child: FutureBuilder(
              future: _questionUserListFuture,
              builder: (context, dataSnapShot) {
                if (dataSnapShot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (dataSnapShot.error != null) {
                    return Center(child: Text('An error occured'));
                  } else {
                    return Consumer<QuestionsProviders>(
                        builder: (context, questionsUsersData, child) => Column(
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
                                                      userData['national_code']);
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
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25)),
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25)))),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 8,
                                  child: StaggeredGridView.countBuilder(
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
                                              'user_ref_id': questionsUsersData
                                                  .getQuestionUsersData[index]
                                                  .nationalCode,
                                              'user_full_name':
                                                  '${questionsUsersData.getQuestionUsersData[index].name} ${questionsUsersData.getQuestionUsersData[index].lastName}',
                                              'user_birth_date': questionsUsersData.getQuestionUsersData[index].birthDate   
                                            });
                                      },
                                      child: Card(
                                        elevation: 15,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15))),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child:ProfilePicture(
                                                          name:
                                                              '${questionsUsersData.getQuestionUsersData[index].lastName}',
                                                          radius: 31,
                                                          fontsize: 21,
                                                          random: true,
                                                        ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                  '${questionsUsersData.getQuestionUsersData[index].name} ${questionsUsersData.getQuestionUsersData[index].lastName}'),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(questionsUsersData
                                                  .getQuestionUsersData[index]
                                                  .birthDate
                                                  .toString()),
                                            ),
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
    );
  }
}
