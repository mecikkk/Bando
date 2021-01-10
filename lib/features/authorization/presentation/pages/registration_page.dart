import 'package:bando/core/utils/constants.dart';
import 'package:bando/core/utils/context_extensions.dart';
import 'package:bando/core/widgets/connectivity_bar.dart';
import 'package:bando/core/widgets/gradient_button.dart';
import 'package:bando/core/widgets/rounded_text_field.dart';
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
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegistrationBloc, RegistrationState>(
      cubit: _bloc,
      listener: (context, state) {},
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
                  top: 0,
                  left: 32.0,
                  right: 32.0,
                  bottom: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  context.translate(Texts.REGISTRATION),
                                  style: TextStyle(fontSize: context.scale(38.0)),
                                )),
                            SizedBox(height: 8.0),
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  context.translate(Texts.REGISTRATION_SUBTITLE),
                                  style: TextStyle(fontSize: context.scale(16.0)),
                                )),
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 3,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              RoundedTextField(
                                controller: _usernameController,
                                inputType: TextInputType.name,
                                labelText: context.translate(Texts.USERNAME),
                                icon: Icons.person_outline_rounded,
                              ),
                              SizedBox(height: context.scale(24.0)),
                              RoundedTextField.email(
                                controller: _emailController,
                                labelText: 'E-mail',
                                validator: null,
                              ),
                              SizedBox(height: context.scale(24.0)),
                              RoundedTextField.password(
                                controller: _passwordController,
                                labelText: context.translate(Texts.PASSWORD),
                                validator: null,
                              ),
                              SizedBox(height: context.scale(24.0)),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.center,
                          child: GradientButton(
                            text: context.translate(Texts.REGISTER),
                            height: context.scale(48.0),
                            onPressed: () {},
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
}
