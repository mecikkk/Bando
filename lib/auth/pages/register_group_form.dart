import 'package:bando/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:bando/auth/blocs/register_bloc/register_bloc.dart';
import 'package:bando/auth/pages/success_page.dart';
import 'package:bando/utils/consts.dart';
import 'package:bando/utils/util.dart';
import 'package:bando/widgets/gradient_raised_button.dart';
import 'package:bando/widgets/simple_rounded_card.dart';
import 'package:bando/widgets/text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterGroupForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RegisterGroupFormState();
  }
}

class RegisterGroupFormState extends State<RegisterGroupForm> {
  RegisterBloc _registerBloc;

  final PageController _groupPageViewController = PageController();
  final TextEditingController _groupNameController = TextEditingController();

  Color _newGroupCardColor = Color.fromRGBO(143, 110, 255, 1.0);
  Color _joinToGroupCardColor = Colors.black12;

  bool disableTouch = false;

  @override
  void initState() {
    super.initState();
    _registerBloc = BlocProvider.of<RegisterBloc>(context);
    _groupNameController.addListener(_onGroupNameChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _groupNameController.dispose();
    _groupPageViewController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        // Hide Snackbar from previous page
        if (state.isRegistrationSuccess) {
          Scaffold.of(context)..hideCurrentSnackBar();
        }

        if (state.isFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Błąd..'), Icon(Icons.error)],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }
        if (state.isGroupSubmitting && state.isJoiningToExistingGroup) {
          disableTouch = true;
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dołączanie do grupy...'),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }
        if (state.isGroupSubmitting && state.isNewGroupCreating) {
          disableTouch = true;
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tworzę nową grupę...'),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }
        if (state.isGroupConfigurationSuccess) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Konfiguracja zakończona pomyślnie !'), Icon(Icons.check)],
                ),
                backgroundColor: Constants.positiveGreenColor,
              ),
            );

          Future.delayed(const Duration(milliseconds: 1500), () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return SuccessPage(
                  configurationType: ConfigurationType.NEW_GROUP,
                  groupId: state.groupId,
                  groupName: _groupNameController.text,
                );
              }),
            );

//            BlocProvider.of<AuthBloc>(context).add(AuthLoggedIn());
//            Navigator.of(context).popUntil((route) => route.isFirst);
          });
        }

        if (state.isNewGroupCreating && !state.isGroupSubmitting && !state.isGroupConfigurationSuccess) {
          _newGroupCardColor = Constants.getStartGradientColor(context);
          _joinToGroupCardColor = Colors.black12;
          _groupPageViewController.animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.easeOutCirc);
        }
        if (state.isJoiningToExistingGroup && !state.isGroupSubmitting && !state.isGroupConfigurationSuccess) {
          _newGroupCardColor = Colors.black12;
          _joinToGroupCardColor = Constants.getEndGradientColor(context);
          _groupPageViewController.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.easeOutCirc);
        }
      },
      child: BlocBuilder<RegisterBloc, RegisterState>(
        builder: (context, state) {
          return AbsorbPointer(
            absorbing: disableTouch,
            child: Form(
              child: ListView(
                children: <Widget>[
                  _buildHeader(),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: buildNewGroupCard(onTap: () {
                            _registerBloc.add(
                              RegisterNewGroupCreating(),
                            );
                          }),
                        ),
                        Expanded(
                          child: buildJoinToGroupCard(onTap: () {
                            _registerBloc.add(
                              RegisterJoiningToGroup(),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 25,
                    endIndent: 25,
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 270,
                        child: PageView(
                          physics: NeverScrollableScrollPhysics(),
                          controller: _groupPageViewController,
                          scrollDirection: Axis.horizontal,
                          children: <Widget>[
                            _buildGroupCreatorWidget(state, _groupNameController),
                            Container(),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 4.0, top: 23),
            child: Text(
              "Grupa",
              style: TextStyle(fontSize: 38.0, letterSpacing: 0),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 28.0, left: 3, right: 3),
            child: Text(
              "Utwórz nową grupę dla zespołu, lub dołącz do istniejącej.",
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildJoinToGroupCard({@required Function onTap}) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 400),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: _joinToGroupCardColor,
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 2),
                color: Colors.black.withOpacity(0.2),
                blurRadius: 2.0,
                spreadRadius: 2.0,
              )
            ],
          ),
          child: SimpleRoundedCard(text: "Dołącz do istniejącej"),
        ),
      ),
    );
  }

  Padding buildNewGroupCard({@required Function onTap}) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 400),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: _newGroupCardColor,
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 2),
                color: Colors.black.withOpacity(0.2),
                blurRadius: 2.0,
                spreadRadius: 2.0,
              )
            ],
          ),
          child: SimpleRoundedCard(text: "Nowa grupa"),
        ),
      ),
    );
  }

  Widget _buildGroupCreatorWidget(RegisterState state, TextEditingController controller) {
    debugPrint("BuildGroupCreatorWidget");
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Text(
              "Nazwij swoją grupę",
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Text(
              "Nazwa będzie widoczna tylko dla członków utworzonej grupy.",
              style: TextStyle(fontSize: 14.0, color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.5)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: RoundedTextField(
              controller: controller,
              labelText: 'Nazwa grupy',
              icon: Icons.group,
              passwordMode: false,
              isValid: state.isGroupNameValid,
              validator: (_) {
                return !state.isGroupNameValid ? 'Pole jest puste' : null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 40),
            child: Align(
                alignment: Alignment.center,
                child: GradientRaisedButton(
                  text: "Utwórz grupę",
                  height: 50.0,
                  colors: [Constants.getStartGradientColor(context), Constants.getEndGradientColor(context)],
                  onPressed: state.isUsernameValid ? _onCreateGroupClick : null,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeViewWidget() {
    debugPrint("BuildQRCodeViewWidget");

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Container(
              width: 100,
              height: 100,
              color: Constants.getEndGradientColor(context),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Text(
              "Pozwól zeskanować kod QR innym.",
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Text(
              "Osoba dołączająca do istniejącej grupy, skanując kod QR w szybki i prosty sposób zostanie do niej dodana.",
              style: TextStyle(fontSize: 14.0, color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }

  void _onCreateGroupClick() {
    _registerBloc.add(RegisterSubmittedNewGroup(
      groupName: _groupNameController.text,
    ));
  }

  void _onGroupNameChanged() {
    _registerBloc.add(
      RegisterGroupNameChanged(
        groupName: _groupNameController.text,
      ),
    );
  }
}
