class Config {
  final String geocodingKey;
  final String authKey;
  final Firebase firebaseData;

  Config({this.geocodingKey, this.authKey, this.firebaseData});

  factory Config.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> firebaseJson = json['firebase'];

    return Config(
      geocodingKey: json['geocodingKey'].toString(),
      authKey: json['authKey'].toString(),
      firebaseData: Firebase(
        baseURL: firebaseJson['baseURL'],
        storeImageFunctionURL: firebaseJson['storeImageFunctionURL'],
        fileName: firebaseJson['fileName'],
        projectId: firebaseJson['projectId'],
        bucketName: firebaseJson['bucketName'],
      ),
    );
  }
}

class Firebase {
  final String baseURL;
  final String storeImageFunctionURL;
  final String fileName;
  final String projectId;
  final String bucketName;

  Firebase({this.baseURL, this.storeImageFunctionURL, this.fileName, this.projectId, this.bucketName});
}
