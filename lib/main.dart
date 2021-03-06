import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_course/shared/adaptive_theme.dart';
import 'package:flutter_course/shared/global_config.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:flutter_course/pages/auth.dart';
import 'package:flutter_course/scoped_models/main_model.dart';

import 'package:flutter_course/pages/product.dart';
import 'package:flutter_course/pages/products.dart';
import 'package:flutter_course/pages/products_admin.dart';
import 'widgets/helpers/custom_route.dart';

void main() {
  // debugPaintSizeEnabled = false;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MethodChannel _platformChannel =
      MethodChannel('flutter-course.com/battery');
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;

  Future<Null> _getBatteryPercentage() async {
    String batteryPercentage;
    try {
      final int result =
          await _platformChannel.invokeMethod<int>('getBatteryPercentage');
      batteryPercentage = 'Battery percentage is %$result';
    } catch (error) {
      batteryPercentage = 'Error while getting the battery percentage';
    }
    print(batteryPercentage);
  }

  @override
  void initState() {
    _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() => _isAuthenticated = isAuthenticated);
    });

    //We load the config.json
    GlobalConfig config = GlobalConfig();
    config.loadConfiguration();
    _getBatteryPercentage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print('Building main page');
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        title: 'ProductsList',
        theme: getAdaptiveThemeData(context),
        routes: {
          '/': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : ProductsPage(_model),
          '/admin': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : ProductsAdminPage(_model),
        },
        onGenerateRoute: (RouteSettings settings) {
          if (!_isAuthenticated) {
            return MaterialPageRoute<bool>(
                builder: (BuildContext context) => AuthPage());
          }
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') return null;
          if (pathElements[1] == 'product') {
            final String id = pathElements[2];
            _model.selectProduct(id);
            return CustomRoute<bool>(
                builder: (BuildContext context) =>
                    !_isAuthenticated ? AuthPage() : ProductPage());
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) =>
                  !_isAuthenticated ? AuthPage() : ProductsPage(_model));
        },
      ),
    );
  }
}
