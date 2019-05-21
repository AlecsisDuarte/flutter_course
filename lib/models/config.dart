class Config {
  final String geocodingKey;

  Config({this.geocodingKey});

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      geocodingKey: json['geocodingKey'].toString(),
    );
  }
}
