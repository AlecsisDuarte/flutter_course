import 'package:flutter/material.dart';
import 'package:flutter_course/shared/adaptive_elevation.dart';
import 'package:flutter_course/widgets/ui_elements/adaptive_progress_indicator.dart';
import 'package:scoped_model/scoped_model.dart';

import '../widgets/ui_elements/height_spacing.dart';
import 'package:flutter_course/scoped_models/main_model.dart';
import '../models/auth.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
    'acceptTerms': false
  };
  final RegExp _emailRegex = RegExp(
      r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?");

  // final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();

  AuthMode _authMode = AuthMode.Login;

  AnimationController _controller;
  Animation<Offset> _slideAnimation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, -1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 760.0 ? 500.0 : deviceWidth * 0.95;
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        elevation: getAdaptiveElevation(context),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          alignment: Alignment.center,
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
            image: _buildBackgroundImage(),
          ),
          child: SingleChildScrollView(
            child: Center(
              child: Form(
                key: _formKey,
                child: Container(
                  width: targetWidth,
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    children: <Widget>[
                      _buildEmailTextField(),
                      HeightSpacing(),
                      _buildPasswordTextField(),
                      HeightSpacing(),
                      _buildPasswordConfirmTextField(),
                      _buildAcceptSwitch(),
                      HeightSpacing(),
                      FlatButton(
                        child: Text(
                            'Switch to ${_authMode == AuthMode.Login ? 'Signup' : 'Login'}'),
                        onPressed: () {
                          setState(() {
                            if (_authMode == AuthMode.Signup) {
                              _authMode = AuthMode.Login;
                              _controller.reverse();
                            } else {
                              _authMode = AuthMode.Signup;
                              _controller.forward();
                            }
                          });
                        },
                      ),
                      HeightSpacing(),
                      ScopedModelDescendant<MainModel>(
                        builder: (BuildContext context, Widget child,
                            MainModel model) {
                          return model.isLoading
                              ? AdaptiveProgressIndicator()
                              : RaisedButton(
                                  child: Text(_authMode == AuthMode.Login
                                      ? 'LOGIN'
                                      : 'SIGNUP'),
                                  color: Theme.of(context).accentColor,
                                  textColor: Theme.of(context)
                                      .accentTextTheme
                                      .button
                                      .color,
                                  onPressed: () =>
                                      _submitForm(model.authenticate),
                                );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void messageDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text('ACEPT'),
                onPressed: () => Navigator.pop(context),
              )
            ]);
      },
    );
  }

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
        colorFilter: ColorFilter.mode(Colors.black38, BlendMode.dstATop),
        fit: BoxFit.cover,
        image: AssetImage('assets/background.jpg'));
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      autofocus: true,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white70,
        labelText: 'E-mail',
        hintText: 'test@mail.ts',
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return 'E-mail is required';
        } else if (!_emailRegex.hasMatch(value)) {
          return 'E-mail is not valid';
        }
        return null;
      },
      onSaved: (String value) => _formData['email'] = value,
    );
  }

  // Widget _buildEmailConfirmTextField() {
  //   return TextFormField(
  //     autofocus: true,
  //     keyboardType: TextInputType.emailAddress,
  //     decoration: InputDecoration(
  //       filled: true,
  //       fillColor: Colors.white70,
  //       labelText: 'Confirm E-mail',
  //       hintText: 'test@mail.ts',
  //     ),
  //     controller: _emailTextController,
  //     validator: (String value) {
  //       return null;
  //     },
  //   );
  // }

  Widget _buildPasswordTextField() {
    return TextFormField(
      obscureText: true,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white70,
        labelText: 'Password',
      ),
      controller: _passwordTextController,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Password is required';
        } else if (value.length < 5) {
          return 'Password should be 5+ characters long';
        }
        return null;
      },
      onSaved: (String value) => _formData['password'] = value,
    );
  }

  Widget _buildPasswordConfirmTextField() {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _controller,
          curve: Interval(0.0, 1.0, curve: Curves.easeOut),
        ),
        child: TextFormField(
          obscureText: true,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white70,
            labelText: 'Confirm Password',
          ),
          validator: (String value) {
            if (_passwordTextController.text != value &&
                _authMode == AuthMode.Signup) {
              return 'The passwords do not match';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildAcceptSwitch() {
    return SwitchListTile(
        value: _formData['acceptTerms'],
        onChanged: (bool value) =>
            setState(() => _formData['acceptTerms'] = value),
        title: Text("Accept Terms"));
  }

  void _submitForm(Function authenticate) async {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();
    if (!_formData['acceptTerms']) {
      messageDialog(context, 'Accept Terms',
          'In order to continue you must accept the terms');
      return;
    }
    Map<String, dynamic> response = await authenticate(
        _formData['email'], _formData['password'], _authMode);

    if (response['success']) {
      // Navigator.pushReplacementNamed(context, '/');
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('An Error Ocurred'),
              content: Text(response['message']),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            );
          });
    }
  }
}
