import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_course/models/config.dart';

class GlobalConfig {
  final String _configFile = 'assets/config.json';

  Config _config;
  Config get config => _config;

  GlobalConfig._privateConstructor();
  static final GlobalConfig _instance = GlobalConfig._privateConstructor();
  factory GlobalConfig() => _instance;

  Future loadConfiguration() async {
    try {
      final String configString = await rootBundle.loadString(_configFile);
      _config = Config.fromJson(json.decode(configString));
    } catch (error) {
      print('Couldn\'t open the config.json file');
      print(error);
    }
  }
}
