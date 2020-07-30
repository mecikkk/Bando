import 'package:bando/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:bando/auth/blocs/login_bloc/login_bloc.dart';
import 'package:bando/auth/blocs/register_bloc/register_bloc.dart';
import 'package:bando/auth/pages/register_group_form.dart';
import 'package:bando/auth/pages/register_page.dart';
import 'package:bando/utils/consts.dart';
import 'package:bando/widgets/gradient_raised_button.dart';
import 'package:bando/widgets/text_field.dart';
import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginForm extends StatefulWidget {
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  LoginBloc _loginBloc;

  bool get isLoginFieldsValid => _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  bool isLoginButtonEnabled(LoginState state) {
    return state.isFormValid && isLoginFieldsValid && !state.isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.isFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Nie znaleziono konta'), Icon(Icons.error)],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }
        if (state.isSubmitting) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Logowanie...'),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }
        if (state.isSuccess) {
          print("state SUCCESS and GROUP CONFIGURED");
          BlocProvider.of<AuthBloc>(context).add(AuthLoggedIn());
        }

      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Scaffold(
            body: Form(
              child: ListView(
                padding: EdgeInsets.all(20),
                children: <Widget>[
                  _buildHeader(),
                  SizedBox(
                    height: 25,
                  ),
                  RoundedTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    icon: Icons.mail_outline,
                    inputType: TextInputType.emailAddress,
                    isValid: state.isEmailValid,
                    obscureText: false,
                    validator: (_) {
                      return !state.isEmailValid ? 'Niepoprawny Email' : null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: RoundedTextField(
                      controller: _passwordController,
                      labelText: 'Hasło',
                      icon: Icons.lock_outline,
                      isPasswordFiled: true,
                      obscureText: _obscurePassword,
                      changePasswordVisibility: _changePasswordVisibility,
                      isValid: state.isPasswordValid,
                      validator: (_) {
                        return !state.isPasswordValid ? 'Niepoprawne Hasło' : null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        GradientRaisedButton(
                          colors: [Constants.getEndGradientColor(context), Constants.getStartGradientColor(context)],
                          text: "Zaloguj",
                          height: 45.0,
                          onPressed: isLoginButtonEnabled(state) ? _onFormSubmitted : null,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        RaisedButton.icon(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              side: BorderSide(color: Colors.black.withOpacity(0.1))),
                          icon: SvgPicture.asset(
                            "assets/google_g.svg",
                            height: 22,
                          ),
                          onPressed: () {
                            BlocProvider.of<LoginBloc>(context).add(
                              LoginWithGooglePressed(),
                            );
                          },
                          label: Text('Zaloguj z Google',
                              style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color)),
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30.0, bottom: 15),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Divider(
                                  height: 20,
                                  thickness: 2,
                                  indent: 15,
                                  endIndent: 15,
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              Text("lub"),
                              Expanded(
                                child: Divider(
                                  height: 20,
                                  thickness: 2,
                                  indent: 15,
                                  endIndent: 15,
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FlatButton(
                          child: Text(
                            'Utwórz konto',
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) {
                                return RegisterPage();
                              }),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: 30, bottom: 10),
            child: Image.asset(
              "assets/logo_gradient.png",
              scale: 8,
              height: 120,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 4.0),
          child: Text(
            "Bando",
            style: TextStyle(fontSize: 38.0, letterSpacing: 0),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 28.0, left: 3),
          child: Text(
            "Zsynchronizuj śpiewnik zespołowy ♫",
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ),
      ],
    );
  }

  void _changePasswordVisibility(){
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    _loginBloc.add(
      LoginEmailChanged(email: _emailController.text),
    );
  }

  void _onPasswordChanged() {
    _loginBloc.add(
      LoginPasswordChanged(password: _passwordController.text),
    );
  }

  void _onFormSubmitted() async {
    bool isConnected = await ConnectivityUtils.instance.isPhoneConnected();
    if(isConnected) {
      _loginBloc.add(
        LoginWithEmailPressed(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }
}
