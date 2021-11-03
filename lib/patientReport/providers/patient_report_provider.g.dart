// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_report_provider.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$PatientReportProvider on PatientReportProviderBase, Store {
  final _$isPatientReportLoadingAtom =
      Atom(name: 'PatientReportProviderBase.isPatientReportLoading');

  @override
  bool get isPatientReportLoading {
    _$isPatientReportLoadingAtom.reportRead();
    return super.isPatientReportLoading;
  }

  @override
  set isPatientReportLoading(bool value) {
    _$isPatientReportLoadingAtom
        .reportWrite(value, super.isPatientReportLoading, () {
      super.isPatientReportLoading = value;
    });
  }

  final _$isGettingPatientReportLoadingAtom =
      Atom(name: 'PatientReportProviderBase.isGettingPatientReportLoading');

  @override
  bool get isGettingPatientReportLoading {
    _$isGettingPatientReportLoadingAtom.reportRead();
    return super.isGettingPatientReportLoading;
  }

  @override
  set isGettingPatientReportLoading(bool value) {
    _$isGettingPatientReportLoadingAtom
        .reportWrite(value, super.isGettingPatientReportLoading, () {
      super.isGettingPatientReportLoading = value;
    });
  }

  final _$patientReportFormScaffoldKeyAtom =
      Atom(name: 'PatientReportProviderBase.patientReportFormScaffoldKey');

  @override
  GlobalKey<ScaffoldState> get patientReportFormScaffoldKey {
    _$patientReportFormScaffoldKeyAtom.reportRead();
    return super.patientReportFormScaffoldKey;
  }

  @override
  set patientReportFormScaffoldKey(GlobalKey<ScaffoldState> value) {
    _$patientReportFormScaffoldKeyAtom
        .reportWrite(value, super.patientReportFormScaffoldKey, () {
      super.patientReportFormScaffoldKey = value;
    });
  }

  final _$patientReportScaffoldKeyAtom =
      Atom(name: 'PatientReportProviderBase.patientReportScaffoldKey');

  @override
  GlobalKey<ScaffoldState> get patientReportScaffoldKey {
    _$patientReportScaffoldKeyAtom.reportRead();
    return super.patientReportScaffoldKey;
  }

  @override
  set patientReportScaffoldKey(GlobalKey<ScaffoldState> value) {
    _$patientReportScaffoldKeyAtom
        .reportWrite(value, super.patientReportScaffoldKey, () {
      super.patientReportScaffoldKey = value;
    });
  }

  final _$patientReportByUserScaffoldKeyAtom =
      Atom(name: 'PatientReportProviderBase.patientReportByUserScaffoldKey');

  @override
  GlobalKey<ScaffoldState> get patientReportByUserScaffoldKey {
    _$patientReportByUserScaffoldKeyAtom.reportRead();
    return super.patientReportByUserScaffoldKey;
  }

  @override
  set patientReportByUserScaffoldKey(GlobalKey<ScaffoldState> value) {
    _$patientReportByUserScaffoldKeyAtom
        .reportWrite(value, super.patientReportByUserScaffoldKey, () {
      super.patientReportByUserScaffoldKey = value;
    });
  }

  final _$setReportsAsyncAction =
      AsyncAction('PatientReportProviderBase.setReports');

  @override
  Future<void> setReports(Map<String, dynamic> map, BuildContext context) {
    return _$setReportsAsyncAction.run(() => super.setReports(map, context));
  }

  final _$addReportsAsyncAction =
      AsyncAction('PatientReportProviderBase.addReports');

  @override
  Future<void> addReports(Map<String, dynamic> map, BuildContext context) {
    return _$addReportsAsyncAction.run(() => super.addReports(map, context));
  }

  final _$editReportAsyncAction =
      AsyncAction('PatientReportProviderBase.editReport');

  @override
  Future<void> editReport(Map<String, dynamic> map, BuildContext context) {
    return _$editReportAsyncAction.run(() => super.editReport(map, context));
  }

  final _$getUsersAsyncAction =
      AsyncAction('PatientReportProviderBase.getUsers');

  @override
  Future<void> getUsers() {
    return _$getUsersAsyncAction.run(() => super.getUsers());
  }

  final _$getReportsByUserIdAsyncAction =
      AsyncAction('PatientReportProviderBase.getReportsByUserId');

  @override
  Future<void> getReportsByUserId(int userId) {
    return _$getReportsByUserIdAsyncAction
        .run(() => super.getReportsByUserId(userId));
  }

  final _$deleteReportAsyncAction =
      AsyncAction('PatientReportProviderBase.deleteReport');

  @override
  Future<void> deleteReport(int reportId, int userId) {
    return _$deleteReportAsyncAction
        .run(() => super.deleteReport(reportId, userId));
  }

  final _$PatientReportProviderBaseActionController =
      ActionController(name: 'PatientReportProviderBase');

  @override
  void runFilter(String enteredKeyword) {
    final _$actionInfo = _$PatientReportProviderBaseActionController
        .startAction(name: 'PatientReportProviderBase.runFilter');
    try {
      return super.runFilter(enteredKeyword);
    } finally {
      _$PatientReportProviderBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isPatientReportLoading: ${isPatientReportLoading},
isGettingPatientReportLoading: ${isGettingPatientReportLoading},
patientReportFormScaffoldKey: ${patientReportFormScaffoldKey},
patientReportScaffoldKey: ${patientReportScaffoldKey},
patientReportByUserScaffoldKey: ${patientReportByUserScaffoldKey}
    ''';
  }
}
