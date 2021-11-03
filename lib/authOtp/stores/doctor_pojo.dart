class Profile {
  String? mdCode;
  String? specialty;
  String? name;
  String? email;
  String? mobile;
  String? apikey;
  int? status;
  String? createdAt;
  String? lastName;
  String? fatherName;
  String? birthDate;
  String? wcity;
  String? wstate;
  String? nationalCode;
  int? isApproved;
  int? usedMdApp;
  String? profilePic;
  String? notifToken;

  Profile(
      {required this.mdCode,
      required this.specialty,
      required this.name,
      required this.email,
      required this.mobile,
      required this.apikey,
      required this.status,
      required this.createdAt,
      required this.lastName,
      required this.fatherName,
      required this.birthDate,
      required this.wcity,
      required this.wstate,
      required this.nationalCode,
      required this.isApproved,
      required this.usedMdApp,
      required this.profilePic,
      required this.notifToken});

  Profile.fromJson(Map<String, dynamic> json) {
    if (json!=null) {
      mdCode = json['md_code'];
    specialty = json['specialty'];
    name = json['name'];
    email = json['email'];
    mobile = json['mobile'];
    apikey = json['apikey'];
    status = json['status'];
    createdAt = json['created_at'];
    lastName = json['lastName'];
    fatherName = json['fatherName'];
    birthDate = json['birthDate'];
    wcity = json['wcity'];
    wstate = json['wstate'];
    nationalCode = json['national_code'];
    isApproved = json['is_approved'];
    usedMdApp = json['used_md_app'];
    profilePic = json['profile_pic'];
    notifToken = json['notif_token'];
    }
    
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['md_code'] = this.mdCode;
    data['specialty'] = this.specialty;
    data['name'] = this.name;
    data['email'] = this.email;
    data['mobile'] = this.mobile;
    data['apikey'] = this.apikey;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['lastName'] = this.lastName;
    data['fatherName'] = this.fatherName;
    data['birthDate'] = this.birthDate;
    data['wcity'] = this.wcity;
    data['wstate'] = this.wstate;
    data['national_code'] = this.nationalCode;
    data['is_approved'] = this.isApproved;
    data['used_md_app'] = this.usedMdApp;
    data['profile_pic'] = this.profilePic;
    data['notif_token'] = this.notifToken;
    return data;
  }
}