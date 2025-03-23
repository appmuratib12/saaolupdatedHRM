class UserProfileResponse {
  bool? success;
  User? user;

  UserProfileResponse({this.success, this.user});

  UserProfileResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  int? umId;
  String? userUniqueId;
  String? firstName;
  String? lastName;
  String? email;
  String? mobileNo;
  String? designation;
  String? department;
  String? team;
  String? dateOfJoin;
  String? umImage;

  User(
      {this.umId,
        this.userUniqueId,
        this.firstName,
        this.lastName,
        this.email,
        this.mobileNo,
        this.designation,
        this.department,
        this.team,
        this.dateOfJoin,
        this.umImage});

  User.fromJson(Map<String, dynamic> json) {
    umId = json['um_id'];
    userUniqueId = json['user_unique_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    mobileNo = json['mobile_no'];
    designation = json['designation'];
    department = json['department'];
    team = json['team'];
    dateOfJoin = json['date_of_join'];
    umImage = json['um_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['um_id'] = this.umId;
    data['user_unique_id'] = this.userUniqueId;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['email'] = this.email;
    data['mobile_no'] = this.mobileNo;
    data['designation'] = this.designation;
    data['department'] = this.department;
    data['team'] = this.team;
    data['date_of_join'] = this.dateOfJoin;
    data['um_image'] = this.umImage;
    return data;
  }
}
