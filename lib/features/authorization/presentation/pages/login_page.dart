import 'package:bando/core/utils/constants.dart';
import 'package:bando/core/utils/context_extensions.dart';
import 'package:bando/core/utils/generate_screen.dart';
import 'package:bando/core/widgets/bando_dialog.dart';
import 'package:bando/core/widgets/bando_snackbar.dart';
import 'package:bando/core/widgets/connectivity_bar.dart';
import 'package:bando/core/widgets/gradient_button.dart';
import 'package:bando/core/widgets/logo_loading.dart';
import 'package:bando/core/widgets/rounded_text_field.dart';
import 'package:bando/features/authorization/presentation/blocs/login/login_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:koin_flutter/koin_flutter.dart';
import 'package:transparent_image/transparent_image.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  LoginBloc _bloc;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  ConnectivityBar _connectivityBar;

  final GlobalKey<RoundedTextFieldState> _emailKey = GlobalKey<RoundedTextFieldState>();
  final GlobalKey<RoundedTextFieldState> _passwordKey = GlobalKey<RoundedTextFieldState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<LogoLoadingState> _logoLoadingKey = GlobalKey<LogoLoadingState>();

  bool _connected;

  double totalHeight;
  double totalWidth;

  double _contentOpacity = 0;

  @override
  void initState() {
    _bloc = get<LoginBloc>();
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
    _connectivityBar = ConnectivityBar(currentStatus: (isOnline) { _connected = isOnline;});
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    totalHeight = context.height;

    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _contentOpacity = 1.0;
      });
    });

    return BlocListener<LoginBloc, LoginState>(
      cubit: _bloc,
      listener: (context, state) {
        if (state is EmailFieldChangedState) _emailKey.currentState.updateValidState(_bloc.emailValid);
        if (state is PasswordFieldChangedState) _passwordKey.currentState.updateValidState(_bloc.passwordValid);
        if (state is Error) {
          _showSnackBar(state.message);
          _logoLoadingKey.currentState.stopAnim();
        }
        // if (state is WrongEmailOrPasswordState) _showSnackBar(state.message);
        // if (state is GoogleAuthCanceledState) _showSnackBar(state.message);
        // if (state is ResetPasswordFailureState) _showSnackBar(state.message);

        if (state is WrongEmailOrPasswordState ||
            state is GoogleAuthCanceledState ||
            state is ResetPasswordFailureState) _logoLoadingKey.currentState.stopAnim();

        if(state is LoggingInSuccessState) {
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
        return Scaffold(
          key: _scaffoldKey,
          body: Stack(
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
                padding: const EdgeInsets.only(top: 50.0, left: 32.0, right: 32.0),
                child: _buildForm(context, state),
              ),
              Positioned(
                bottom: 24,
                left: 0.0,
                right: 0.0,
                child: _connectivityBar
              )
            ],
          ),
        );
      }),
    );
  }

  Widget _buildForm(BuildContext context, LoginState state) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _contentOpacity,
      curve: Curves.easeInCirc,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: LogoLoading(key: _logoLoadingKey),
          ),
          SizedBox(height: 16.0),
          Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Bando',
                style: TextStyle(fontSize: context.scale(38.0)),
              )),
          Align(
              alignment: Alignment.topLeft,
              child: Text(
                context.translate(Texts.SPLASH_SUBTITLE),
                style: TextStyle(fontSize: context.scale(18.0)),
              )),
          SizedBox(height: 24.0),
          RoundedTextField.email(
            key: _emailKey,
            controller: _emailController,
            labelText: 'E-mail',
            validator: (text) {
              if (state is EmailFieldChangedState)
                return (state.message != null) ? context.translate(state.message) : null;
              else
                return null;
            },
          ),
          SizedBox(height: 25.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 10,
                child: RoundedTextField.password(
                  key: _passwordKey,
                  controller: _passwordController,
                  labelText: context.translate(Texts.PASSWORD),
                  validator: (text) {
                    if (state is PasswordFieldChangedState)
                      return (state.message != null) ? context.translate(state.message) : null;
                    else
                      return null;
                  },
                ),
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/forgot_pass.svg',
                  height: 40.0,
                ),
                onPressed: () {
                  if (_bloc.emailValid && _emailController.text.isNotEmpty) {
                    FocusScope.of(context).unfocus();
                    _showMaterialDialog();
                  }
                },
              ),
            ],
          ),
          SizedBox(height: context.scale(45.0)),
          GradientButton(
            text: context.translate(Texts.SIGN_IN),
            height: context.scale(45.0),
            onPressed: (_bloc.passwordValid && _bloc.emailValid) ? _onSignInClick : null,
          ),
          SizedBox(height: context.scale(30.0)),
          _buildDivider(context),
          SizedBox(height: context.scale(20.0)),
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
                    Navigator.of(context).pushNamed(Pages.REGISTRATION);
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
          ),
          SizedBox(height: context.scale(50.0)),
        ],
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

  void _showSnackBar(String message) {
    if (_scaffoldKey != null)
      _scaffoldKey.currentState.showSnackBar(BandoSnackBar.error(message: message).build(context));
  }

  void _onEmailChanged() {
    _bloc.add(EmailTextFieldChanged(enteredText: _emailController.text));
  }

  void _onPasswordChanged() {
    _bloc.add(PasswordTextFieldChanged(enteredText: _passwordController.text));
  }

  void _onSignInClick() {
    if (!_connected)
      _connectivityBar.shake();
    else {
      _logoLoadingKey.currentState.startAnim();
      _bloc.add(SignInWithEmailAndPasswordEvent(email: _emailController.text, password: _passwordController.text));
    }
  }
  void _onSignInWithGoogleClick() {
    if (!_connected)
      _connectivityBar.shake();
    else {
      _logoLoadingKey.currentState.startAnim();
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
                _logoLoadingKey.currentState.startAnim();
              },
            ));
  }
}
