class AutoCheckoutResponse {
  String? message;
  String? totalWorkingTime;

  AutoCheckoutResponse({this.message, this.totalWorkingTime});

  AutoCheckoutResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    totalWorkingTime = json['total_working_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['total_working_time'] = this.totalWorkingTime;
    return data;
  }
}
