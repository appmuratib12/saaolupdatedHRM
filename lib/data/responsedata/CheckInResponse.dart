class CheckInResponse {
  String? message;
  double? distance;
  String? totalWorkingTime;
  String? centerLat;
  String? centerLong;
  String? sessionEndTime;

  CheckInResponse(
      {this.message,
      this.distance,
      this.totalWorkingTime,
      this.centerLat,
      this.centerLong,
      this.sessionEndTime});

  CheckInResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    distance = json['distance'];
    totalWorkingTime = json['total_working_time'];
    centerLat = json['center_lat'];
    centerLong = json['center_long'];
    sessionEndTime = json['session_end_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['distance'] = this.distance;
    data['total_working_time'] = this.totalWorkingTime;
    data['center_lat'] = this.centerLat;
    data['center_long'] = this.centerLong;
    data['session_end_time'] = this.sessionEndTime;
    return data;
  }
}
