class CheckInActivityResponse {
  String? firstLoginTime;
  List<UserActivity>? userActivity;
  String? totalWorkingHours;

  CheckInActivityResponse(
      {this.firstLoginTime, this.userActivity, this.totalWorkingHours});

  CheckInActivityResponse.fromJson(Map<String, dynamic> json) {
    firstLoginTime = json['first_login_time'];
    if (json['user_activity'] != null) {
      userActivity = <UserActivity>[];
      json['user_activity'].forEach((v) {
        userActivity!.add(new UserActivity.fromJson(v));
      });
    }
    totalWorkingHours = json['total_working_hours'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first_login_time'] = this.firstLoginTime;
    if (this.userActivity != null) {
      data['user_activity'] =
          this.userActivity!.map((v) => v.toJson()).toList();
    }
    data['total_working_hours'] = this.totalWorkingHours;
    return data;
  }
}

class UserActivity {
  String? loginTime;
  String? logoutTime;
  String? workingHours;

  UserActivity({this.loginTime, this.logoutTime, this.workingHours});

  UserActivity.fromJson(Map<String, dynamic> json) {
    loginTime = json['login_time'];
    logoutTime = json['logout_time'];
    workingHours = json['working_hours'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['login_time'] = this.loginTime;
    data['logout_time'] = this.logoutTime;
    data['working_hours'] = this.workingHours;
    return data;
  }
}

