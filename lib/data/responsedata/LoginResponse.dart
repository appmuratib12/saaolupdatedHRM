class LoginResponse {
  String? accessToken;
  String? longLivedToken;
  String? tokenType;
  int? expiresIn;
  String? centerLat;
  String? centerLong;

  LoginResponse(
      {this.accessToken,
        this.longLivedToken,
        this.tokenType,
        this.expiresIn,
        this.centerLat,
        this.centerLong});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    longLivedToken = json['long_lived_token'];
    tokenType = json['token_type'];
    expiresIn = json['expires_in'];
    centerLat = json['center_lat'];
    centerLong = json['center_long'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['access_token'] = this.accessToken;
    data['long_lived_token'] = this.longLivedToken;
    data['token_type'] = this.tokenType;
    data['expires_in'] = this.expiresIn;
    data['center_lat'] = this.centerLat;
    data['center_long'] = this.centerLong;
    return data;
  }
}
