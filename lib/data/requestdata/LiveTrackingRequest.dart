class TrackingData {
  double? lat;
  double? long;
  String? dateTime;

  TrackingData({this.lat, this.long, this.dateTime});

  factory TrackingData.fromJson(Map<String, dynamic> json) {
    return TrackingData(
      lat: json['lat'],
      long: json['long'],
      dateTime: json['dateTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'long': long,
      'dateTime': dateTime,
    };
  }
}
