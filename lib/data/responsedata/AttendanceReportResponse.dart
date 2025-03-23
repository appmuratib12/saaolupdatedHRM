class AttendanceReportResponse {
  String? month;
  List<Records>? records;
  String? totalWorkingHours;

  AttendanceReportResponse({this.month, this.records, this.totalWorkingHours});

  AttendanceReportResponse.fromJson(Map<String, dynamic> json) {
    month = json['month'];
    if (json['records'] != null) {
      records = <Records>[];
      json['records'].forEach((v) {
        records!.add(new Records.fromJson(v));
      });
    }
    totalWorkingHours = json['total_working_hours'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['month'] = this.month;
    if (this.records != null) {
      data['records'] = this.records!.map((v) => v.toJson()).toList();
    }
    data['total_working_hours'] = this.totalWorkingHours;
    return data;
  }
}

class Records {
  String? date;
  String? firstLogin;
  String? lastLogout;
  String? workingHours;

  Records({this.date, this.firstLogin, this.lastLogout, this.workingHours});

  Records.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    firstLogin = json['first_login'];
    lastLogout = json['last_logout'];
    workingHours = json['working_hours'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['first_login'] = this.firstLogin;
    data['last_logout'] = this.lastLogout;
    data['working_hours'] = this.workingHours;
    return data;
  }
}
