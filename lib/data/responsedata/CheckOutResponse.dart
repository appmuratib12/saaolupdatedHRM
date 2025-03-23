class CheckOutResponse {
  String? message;
  num? distance;
  String? totalWorkingTime;
  String? centerLat;
  String? centerLong;

  CheckOutResponse(
      {this.message,
      this.distance,
      this.totalWorkingTime,
      this.centerLat,
      this.centerLong});


  CheckOutResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    distance = json['distance'];
    totalWorkingTime = json['total_working_time'];
    centerLat = json['center_lat'];
    centerLong = json['center_long'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['distance'] = this.distance;
    data['total_working_time'] = this.totalWorkingTime;
    data['center_lat'] = this.centerLat;
    data['center_long'] = this.centerLong;
    return data;
  }
}
