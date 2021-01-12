import 'package:bando/core/utils/constants.dart';
import 'package:bando/core/utils/context_extensions.dart';
import 'package:bando/core/utils/widget_extensions.dart';
import 'package:bando/core/widgets/bando_snackbar.dart';
import 'package:bando/core/widgets/connectivity_bar.dart';
import 'package:bando/core/widgets/gradient_button.dart';
import 'package:bando/core/widgets/loading_view.dart';
import 'package:bando/core/widgets/rounded_text_field.dart';
import 'package:bando/features/authorization/presentation/blocs/auth/auth_bloc.dart';
import 'package:bando/features/authorization/presentation/blocs/registration/registration_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koin_flutter/koin_flutter.dart';

class RegistrationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  ConnectivityBar _connectivityBar;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  RegistrationBloc _bloc;

  bool _connected;

  @override
  void initState() {
    _bloc = get<RegistrationBloc>();
    _connectivityBar = ConnectivityBar(currentStatus: (isOnline) {
      _connected = isOnline;
    });
    _usernameController.addListener(_onUsernameChanged);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
    super.initState();
  }

  @override
  void dispose() {
    debugPrint("Dispose registration page");
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegistrationBloc, RegistrationState>(
      cubit: _bloc,
      listener: (context, state) {
        if (state is RegistrationFailureState) _showSnackBar(state.failure.message);
        if (state is RegistrationSuccess) {
          debugPrint("Registration success | ${state.user}");
          get<AuthBloc>().add(SignedIn(user : state.user));
          Navigator.of(context).popUntil((route) => route.isFirst);
          // pushNamedReplace
        }
        if (state is RegistrationLoadingState) {
          Navigator.of(context).push(PageRouteBuilder(
              opaque: false,
              pageBuilder: (BuildContext context, _, __) =>
                  LoadingView()));
        }
      },
      child: BlocBuilder<RegistrationBloc, RegistrationState>(
        builder: (context, state) {
          return Scaffold(
            key: _scaffoldKey,
            body: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: 36.0,
                  right: 16.0,
                  child: Image(
                    image: AssetImage('assets/logo_transparent.png'),
                    height: context.scale(300.0),
                    width: context.scale(250.0),
                  ),
                ),
                Positioned(
                  top: 0.0,
                  bottom: 0,
                  right: 32.0,
                  left: 32.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(height: context.height / 10),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        context.translate(Texts.REGISTRATION),
                                        style: TextStyle(fontSize: context.scale(38.0)),
                                      )),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      context.translate(Texts.REGISTRATION_SUBTITLE),
                                      style: TextStyle(fontSize: context.scale(16.0)),
                                    ),
                                  ).paddingOnly(top: 8.0, bottom: context.scale(context.height / 10)),
                                ],
                              ),
                              RoundedTextField(
                                controller: _usernameController,
                                inputType: TextInputType.name,
                                labelText: context.translate(Texts.USERNAME),
                                icon: Icons.person_outline_rounded,
                                enableFocusNextFieldButton: true,
                                validator: (text) {
                                  if (state is UsernameVerifiedState)
                                    return (state.message != null) ? context.translate(state.message) : null;
                                  else
                                    return null;
                                },
                              ),
                              RoundedTextField.email(
                                controller: _emailController,
                                labelText: 'E-mail',
                                enableFocusNextFieldButton: true,
                                validator: (text) {
                                  if (state is EmailVerifiedState)
                                    return (state.message != null) ? context.translate(state.message) : null;
                                  else
                                    return null;
                                },
                              ).paddingOnly(top: context.scale(24.0), bottom: context.scale(24.0)),
                              RoundedTextField.password(
                                controller: _passwordController,
                                labelText: context.translate(Texts.PASSWORD),
                                validator: (text) {
                                  if (state is PasswordVerifiedState)
                                    return (state.message != null) ? context.translate(state.message) : null;
                                  else
                                    return null;
                                },
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: GradientButton(
                                  text: context.translate(Texts.REGISTER),
                                  height: context.scale(48.0),
                                  onPressed: _onRegisterClick,
                                ),
                              ).paddingOnly(top: context.height / 10, bottom: 16.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(bottom: 24, left: 0.0, right: 0.0, child: _connectivityBar)
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSnackBar(String message) {
    if (_scaffoldKey != null)
      _scaffoldKey.currentState.showSnackBar(BandoSnackBar.error(message: message).build(context));
  }

  void _onRegisterClick() {
    _bloc.add(RegisterWithEmailAndPasswordEvent(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
    ));
  }

  void _onEmailChanged() {
    _bloc.add(ValidateRegistrationEmailEvent(enteredText: _emailController.text));
  }

  void _onPasswordChanged() {
    _bloc.add(ValidateRegistrationPasswordEvent(enteredText: _passwordController.text));
  }

  void _onUsernameChanged() {
    _bloc.add(ValidateRegistrationUsernameEvent(enteredText: _usernameController.text));
  }
}
