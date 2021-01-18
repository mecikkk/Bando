import 'package:bando/core/utils/context_extensions.dart';
import 'package:bando/core/widgets/bando_snackbar.dart';
import 'package:bando/core/widgets/connectivity_bar.dart';
import 'package:bando/core/widgets/logo_loading.dart';
import 'package:bando/features/authorization/presentation/pages/login_form.dart';
import 'package:bando/features/authorization/presentation/pages/registration_form.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  ConnectivityBar _connectivityBar;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<LogoLoadingState> _logoLoadingKey = GlobalKey<LogoLoadingState>();
  final GlobalKey<LoginFormState> _loginFormKey = GlobalKey<LoginFormState>();
  final GlobalKey<RegistrationPageState> _registrationFormKey = GlobalKey<RegistrationPageState>();

  bool _connected;
  bool _showRegistrationForm = false;

  @override
  void initState() {
    _connectivityBar = ConnectivityBar(currentStatus: (isOnline) {
      _connected = isOnline;
      _loginFormKey.currentState?.onConnectivityStateChange(isOnline: _connected);
      _registrationFormKey.currentState
          ?.onConnectivityStateChange(isOnline: _connected);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      body: WillPopScope(
        onWillPop: () async {
          if (_showRegistrationForm) {
            setState(() {
              _showRegistrationForm = false;
            });
            return false;
          } else
            return true;
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 36.0,
              right: 16.0,
              child: FadeInImage(
                fadeInDuration: const Duration(milliseconds: 300),
                fadeInCurve: Curves.easeInCirc,
                placeholder: MemoryImage(kTransparentImage),
                image: AssetImage('assets/logo_transparent.png'),
                height: context.scale(300.0),
                width: context.scale(250.0),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 40.0, left: 32.0, right: 32.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: LogoLoading(key: _logoLoadingKey),
                  ),
                  SizedBox(height: 16.0),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 100),
                    child: !_showRegistrationForm
                        ? LoginForm(
                            key: _loginFormKey,
                            logoLoadingKey: _logoLoadingKey,
                            scaffoldKey: _scaffoldKey,
                            shakeConnectivityBar: () {
                              _connectivityBar.shake();
                            },
                            showMessage: (message) {
                              _showSnackBar(message);
                            },
                            showRegistrationForm: () {
                              setState(() {
                                _showRegistrationForm = true;
                              });
                            },
                          )
                        : RegistrationPage(
                            key: _registrationFormKey,
                            logoLoadingKey: _logoLoadingKey,
                            scaffoldKey: _scaffoldKey,
                            shakeConnectivityBar: () {
                              _connectivityBar.shake();
                            },
                            showMessage: (message) {
                              _showSnackBar(message);
                            },
                            initialConnectionState: _connected,
                          ),
                  ),
                ],
              ),
            ),
            Positioned(bottom: 24, left: 0.0, right: 0.0, child: _connectivityBar)
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (_scaffoldKey != null)
      _scaffoldKey.currentState.showSnackBar(BandoSnackBar.error(message: message).build(context));
  }
}
