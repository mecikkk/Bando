import 'package:bando/auth/blocs/register_bloc/register_bloc.dart';
import 'package:bando/utils/consts.dart';
import 'package:bando/utils/validator.dart';
import 'package:bando/widgets/gradient_raised_button.dart';
import 'package:bando/widgets/text_field.dart';
import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterForm extends StatefulWidget {

  final PageController _pageController;

  RegisterForm({Key key, @required PageController pageController})
        : _pageController = pageController,
        super(key: key);

  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  bool isEmailValid = true;
  bool isPasswordValid = true;
  bool isUsernameValid = true;

  RegisterBloc _registerBloc;

  bool get isRegisterFieldsValid => _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty && _usernameController.text.isNotEmpty;

  bool isRegisterButtonEnabled(RegisterState state) {
    return isRegisterFieldsValid && _usernameController.text.isNotEmpty && !(state is RegisterSubmittingState);
  }

  @override
  void initState() {
    super.initState();
    _registerBloc = BlocProvider.of<RegisterBloc>(context);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
    _usernameController.addListener(_onUsernameChanged);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterFailureState) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Problem z rejestracją. Spróbuj ponownie.'), Icon(Icons.error)],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }
        if (state is RegisterSubmittingState) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Zaczekaj...'),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }
        if (state is RegisterRegistrationSuccessState) {
          Scaffold.of(context)
            ..hideCurrentSnackBar();

          widget._pageController.animateToPage(1, duration: Duration(milliseconds: 600), curve: Curves.easeInOutQuad);

        }
      },
      child: BlocBuilder<RegisterBloc, RegisterState>(
        builder: (context, state) {
          return Form(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: <Widget>[
                _buildHeader(),
                SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: RoundedTextField(
                    controller: _usernameController,
                    labelText: 'Nazwa użytkownika',
                    icon: Icons.person_outline,
                    obscureText: false,
                    isValid: isUsernameValid,
                    validator: (_) {
                      return !isUsernameValid ? 'Pole jest puste' : null;
                    },
                  ),
                ),
                RoundedTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  icon: Icons.mail_outline,
                  inputType: TextInputType.emailAddress,
                  isValid: isEmailValid,
                  obscureText: false,
                  validator: (_) {
                    return !isEmailValid ? 'Niepoprawny Email' : null;
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
                    isValid: isPasswordValid,
                    validator: (_) {
                      return !isPasswordValid ? 'Minimum 8 znaków, w tym jedna cyfra' : null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: GradientRaisedButton(
                    colors: [Constants.getEndGradientColor(context), Constants.getStartGradientColor(context)],
                    text: "Zarejestruj",
                    height: 45.0,
                    onPressed: isRegisterButtonEnabled(state) ? _onFormSubmitted : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _changePasswordVisibility(){
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 4.0, top : 50),
          child: Text(
            "Rejestracja",
            style: TextStyle(fontSize: 38.0, letterSpacing: 0),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 28.0, left: 3),
          child: Text(
            "Utwórz nowe konto oraz grupę, lub dołącz do istniejącej grupy.",
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }


  void _onEmailChanged() {
    isEmailValid = _emailController.text.isNotEmpty && Validators.isValidEmail(_emailController.text);
  }

  void _onPasswordChanged() {
    isPasswordValid = _passwordController.text.isNotEmpty && Validators.isValidPassword(_passwordController.text);
  }

  void _onUsernameChanged(){
    isUsernameValid = _usernameController.text.isNotEmpty;
  }

  void _onFormSubmitted() async {
    bool isConnected = await ConnectivityUtils.instance.isPhoneConnected();
    FocusScope.of(context).unfocus();
    if(isConnected) {
      _registerBloc.add(
        RegisterSubmittedEvent(
          email: _emailController.text,
          password: _passwordController.text,
          username: _usernameController.text,
        ),
      );
    }
  }
}
