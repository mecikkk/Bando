import 'package:bando/core/utils/constants.dart';
import 'package:bando/core/utils/context_extensions.dart';
import 'package:bando/core/utils/widget_extensions.dart';
import 'package:bando/core/widgets/bando_dialog.dart';
import 'package:bando/core/widgets/bando_snackbar.dart';
import 'package:bando/core/widgets/gradient_button.dart';
import 'package:bando/core/widgets/logo_loading.dart';
import 'package:bando/core/widgets/rounded_text_field.dart';
import 'package:bando/features/authorization/presentation/blocs/auth/auth_bloc.dart';
import 'package:bando/features/authorization/presentation/blocs/login/login_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:koin_flutter/koin_flutter.dart';

class LoginForm extends StatefulWidget {
  final Function(String message) showMessage;
  final GlobalKey<LogoLoadingState> logoLoadingKey;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function showRegistrationForm;
  final Function shakeConnectivityBar;

  LoginForm({
    Key key,
    @required this.showMessage,
    @required this.logoLoadingKey,
    @required this.showRegistrationForm,
    @required this.shakeConnectivityBar,
    @required this.scaffoldKey,
  }) : super (key: key);

  @override
  State<StatefulWidget> createState() {
    return LoginFormState();
  }
}

class LoginFormState extends State<LoginForm> {
  LoginBloc _bloc;
  bool _connected = true;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final GlobalKey<RoundedTextFieldState> _emailKey = GlobalKey<RoundedTextFieldState>();
  final GlobalKey<RoundedTextFieldState> _passwordKey = GlobalKey<RoundedTextFieldState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _bloc = get<LoginBloc>();
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _bloc = get<LoginBloc>();

    return BlocListener<LoginBloc, LoginState>(
      cubit: _bloc,
      listener: (context, state) {
        if (state is EmailFieldChangedState) _emailKey.currentState.updateValidState(_bloc.emailValid);
        if (state is PasswordFieldChangedState) _passwordKey.currentState.updateValidState(_bloc.passwordValid);
        if (state is Error) {
          widget.showMessage(state.message);
          widget.logoLoadingKey.currentState.stopAnim();
        }

        if (state is WrongEmailOrPasswordState ||
            state is GoogleAuthCanceledState ||
            state is ResetPasswordFailureState) widget.logoLoadingKey.currentState.stopAnim();

        if (state is LoggingInSuccessState) {
          widget.logoLoadingKey.currentState.stopAnim();
          get<AuthBloc>()..add(SignedIn(user: state.user));
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        cubit: _bloc,
        builder: (context, state) {
          return Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Bando',
                  style: TextStyle(fontSize: context.scale(38.0)),
                ),
              ).showFromBottomAnimation(1),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  context.translate(Texts.SPLASH_SUBTITLE),
                  style: TextStyle(fontSize: context.scale(18.0)),
                ),
              ).showFromBottomAnimation(2),
              RoundedTextField.email(
                key: _emailKey,
                controller: _emailController,
                labelText: 'E-mail',
                enableFocusNextFieldButton: true,
                validator: (text) {
                  if (state is EmailFieldChangedState)
                    return (state.message != null) ? context.translate(state.message) : null;
                  else
                    return null;
                },
              ).paddingOnly(top: 24.0, bottom: 25.0).showFromBottomAnimation(3),
              RoundedTextField.password(
                key: _passwordKey,
                controller: _passwordController,
                labelText: context.translate(Texts.PASSWORD),
                validator: (text) {
                  if (state is PasswordFieldChangedState)
                    return (state.message != null) ? context.translate(state.message) : null;
                  else
                    return null;
                },
              ).showFromBottomAnimation(4),
              Align(
                alignment: Alignment.centerRight,
                child: FlatButton(
                  onPressed: () {
                    if (_bloc.emailValid && _emailController.text.isNotEmpty) {
                      FocusScope.of(context).unfocus();
                      _showMaterialDialog();
                    } else {
                      _showSnackBar(Texts.ENTER_EMAIL_ADDRESS);
                    }
                  },
                  child: Text(
                    'Forgot password',
                    style: TextStyle(color: context.colors.accent, fontSize: 14.0),
                  ),
                ),
              ).showFromBottomAnimation(5),
              GradientButton(
                text: context.translate(Texts.SIGN_IN),
                height: context.scale(45.0),
                onPressed: (_bloc.passwordValid && _bloc.emailValid) ? _onSignInClick : null,
              )
                  .paddingOnly(
                    top: context.scale(10.0),
                    bottom: context.scale(30.0),
                  )
                  .showFromBottomAnimation(6),
              _buildDivider(context).showFromBottomAnimation(7),
              Row(
                children: [
                  Expanded(
                    flex: 10,
                    child: RaisedButton.icon(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: BorderSide(color: Colors.black.withOpacity(0.1))),
                      icon: SvgPicture.asset(
                        "assets/google_g.svg",
                        height: 22,
                      ),
                      onPressed: _onSignInWithGoogleClick,
                      label: Text(
                          (context.shortestSideSize > 480)
                              ? context.translate(Texts.SIGN_IN_GOOGLE)
                              : context.translate(Texts.GOOGLE),
                          style: TextStyle(color: context.textColor)),
                      color: context.bgColor,
                    ),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Expanded(
                    flex: 10,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        primary: context.colors.accent,
                        shape: StadiumBorder(),
                        side: BorderSide(color: context.textColor),
                      ),
                      onPressed: () {
                        // Navigator.of(context).pushNamed(Pages.REGISTRATION);
                        widget.showRegistrationForm();
                      },
                      child: Text(
                        context.translate(Texts.CREATE_ACCOUNT).toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.textColor,
                          fontSize: context.scale(14.0),
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  .paddingOnly(
                    top: context.scale(20.0),
                    bottom: context.scale(50.0),
                  )
                  .showFromBottomAnimation(8),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDivider(BuildContext context) => Row(
        children: [
          Flexible(
            child: Divider(
              color: context.textColor,
              height: 10.0,
              thickness: 1.0,
              indent: 0.0,
              endIndent: 25.0,
            ),
          ),
          Text(
            context.translate(Texts.OR),
            style: TextStyle(fontSize: context.scale(16.0)),
          ),
          Flexible(
            child: Divider(
              color: context.textColor,
              height: 10.0,
              thickness: 1.0,
              indent: 25.0,
              endIndent: 0.0,
            ),
          ),
        ],
      );

  onConnectivityStateChange({bool isOnline}) {
    _connected = isOnline;
  }

  void _showSnackBar(String message) {
    if (_scaffoldKey != null)
      widget.scaffoldKey.currentState.showSnackBar(BandoSnackBar.error(message: message).build(context));
  }

  void _onEmailChanged() {
    _bloc.add(EmailTextFieldChanged(enteredText: _emailController.text));
  }

  void _onPasswordChanged() {
    _bloc.add(PasswordTextFieldChanged(enteredText: _passwordController.text));
  }

  void _onSignInClick() {
    if (!_connected)
      widget.shakeConnectivityBar();
    else {
      widget.logoLoadingKey.currentState.startAnim();
      _bloc.add(SignInWithEmailAndPasswordEvent(email: _emailController.text, password: _passwordController.text));
    }
  }

  void _onSignInWithGoogleClick() {
    if (!_connected)
      widget.shakeConnectivityBar();
    else {
      widget.logoLoadingKey.currentState.startAnim();
      _bloc.add(SignInWithGoogleEvent());
    }
  }

  _showMaterialDialog() {
    showDialog(
        context: context,
        builder: (_) => new BandoDialog(
              title: context.translate(Texts.RESET_PASSWORD),
              content: Container(
                height: 80.0,
                child: Column(
                  children: [
                    new Text(context.translate(Texts.RESET_PASSWORD_DESCRIPTION)),
                    new Text(
                      "${_emailController.text}",
                      style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.first),
                    ),
                  ],
                ),
              ),
              confirmActionLabel: context.translate(Texts.CONFIRM),
              cancelActionLabel: context.translate(Texts.CANCEL),
              onConfirmClick: () {
                _bloc.add(ResetPasswordEvent(email: _emailController.text));
                widget.logoLoadingKey.currentState.startAnim();
              },
            ));
  }
}
