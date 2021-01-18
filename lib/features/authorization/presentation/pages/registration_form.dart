import 'package:bando/core/utils/constants.dart';
import 'package:bando/core/utils/context_extensions.dart';
import 'package:bando/core/utils/widget_extensions.dart';
import 'package:bando/core/widgets/gradient_button.dart';
import 'package:bando/core/widgets/logo_loading.dart';
import 'package:bando/core/widgets/rounded_text_field.dart';
import 'package:bando/features/authorization/presentation/blocs/auth/auth_bloc.dart';
import 'package:bando/features/authorization/presentation/blocs/registration/registration_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koin_flutter/koin_flutter.dart';

class RegistrationPage extends StatefulWidget {
  final Function(String message) showMessage;
  final GlobalKey<LogoLoadingState> logoLoadingKey;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function shakeConnectivityBar;
  final bool initialConnectionState;

  RegistrationPage({
    Key key,
    @required this.showMessage,
    @required this.logoLoadingKey,
    @required this.shakeConnectivityBar,
    @required this.scaffoldKey,
    this.initialConnectionState
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  RegistrationBloc _bloc;

  bool _connected;

  @override
  void initState() {
    _bloc = get<RegistrationBloc>();
    _usernameController.addListener(_onUsernameChanged);
    _passwordController.addListener(_onPasswordChanged);
    _emailController.addListener(_onEmailChanged);
    _connected = widget.initialConnectionState;
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegistrationBloc, RegistrationState>(
      cubit: _bloc,
      listener: (context, state) {
        if (state is RegistrationFailureState) {
          widget.logoLoadingKey.currentState.stopAnim();
          widget.showMessage(state.failure.message);
        }
        if (state is RegistrationSuccess) {
          debugPrint("Registration success | ${state.user}");
          widget.logoLoadingKey.currentState.stopAnim();
          get<AuthBloc>().add(SignedIn(user: state.user));
          // pushNamedReplace
        }
        if (state is RegistrationLoadingState) {
          widget.logoLoadingKey.currentState.startAnim();
        }
      },
      child: BlocBuilder<RegistrationBloc, RegistrationState>(
        builder: (context, state) {
          return _buildForm(state);
        },
      ),
    );
  }

  Widget _buildForm(RegistrationState state) {
    return Container(
      height: context.height / 1.2,
      width: context.width,
      child: Column(
        children: [
          Align(
              alignment: Alignment.topLeft,
              child: Text(
                context.translate(Texts.REGISTRATION),
                style: TextStyle(fontSize: context.scale(38.0)),
              )).showFromBottomAnimation(1),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              context.translate(Texts.REGISTRATION_SUBTITLE),
              style: TextStyle(fontSize: context.scale(16.0)),
            ),
          )
              .paddingOnly(
                top: 8.0,
                bottom: context.scale(54),
              )
              .showFromBottomAnimation(2),
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
          ).showFromBottomAnimation(3),
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
          ).paddingOnly(top: context.scale(24.0), bottom: context.scale(24.0)).showFromBottomAnimation(4),
          RoundedTextField.password(
            controller: _passwordController,
            labelText: context.translate(Texts.PASSWORD),
            validator: (text) {
              if (state is PasswordVerifiedState)
                return (state.message != null) ? context.translate(state.message) : null;
              else
                return null;
            },
          ).showFromBottomAnimation(5),
          Align(
            alignment: Alignment.bottomCenter,
            child: GradientButton(
              text: context.translate(Texts.REGISTER),
              height: context.scale(48.0),
              onPressed: _isFormValid() ? _onRegisterClick : null,
            ),
          ).paddingOnly(top: context.height / 10, bottom: 16.0).showFromBottomAnimation(6),
        ],
      ),
    );
  }

  bool _isFormValid() => _bloc.emailValid && _bloc.usernameValid && _bloc.passwordValid;

  onConnectivityStateChange({bool isOnline}) {
    _connected = isOnline;
    debugPrint("SET CONNECTION REGISTRATION PAGE : $_connected");
  }

  void _onRegisterClick() {
    debugPrint("Connecton state : $_connected");
    if (!_connected)
      widget.shakeConnectivityBar();
    else {
      widget.logoLoadingKey.currentState.startAnim();
      _bloc.add(RegisterWithEmailAndPasswordEvent(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
      ));
    }
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
