import 'package:bando/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:bando/auth/blocs/group_bloc/group_bloc.dart';
import 'package:bando/auth/models/group_model.dart';
import 'package:bando/auth/pages/success_page.dart';
import 'package:bando/utils/consts.dart';
import 'package:bando/utils/util.dart';
import 'package:bando/widgets/gradient_raised_button.dart';
import 'package:bando/widgets/simple_rounded_card.dart';
import 'package:bando/widgets/text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class RegisterGroupForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RegisterGroupFormState();
  }
}

class RegisterGroupFormState extends State<RegisterGroupForm> {
  //RegisterBloc _registerBloc;
  GroupBloc _groupBloc;
  BuildContext scaffoldContext;

  final PageController _groupPageViewController = PageController();
  final TextEditingController _groupNameController = TextEditingController();

  Color _newGroupCardColor = Color.fromRGBO(143, 110, 255, 1.0);
  Color _joinToGroupCardColor = Colors.black12;

  bool disableTouch = false;

  String groupIdFromQrCode;
  Group groupFound;

  @override
  void initState() {
    super.initState();
    //_registerBloc = BlocProvider.of<RegisterBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
    _groupNameController.dispose();
    _groupPageViewController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupBloc, GroupState>(
      listener: (context, state) {
        // Hide Snackbar from previous page
//        if (state.isRegistrationSuccess) {
//          Scaffold.of(context)..hideCurrentSnackBar();
//        }

        if (state is GroupFailureState) {
          Scaffold.of(scaffoldContext)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: (state.configurationType == GroupConfigurationType.JOINING_TO_GROUP)
                      ? [
                          Text('Problem z dołączeniem do grupy...'),
                          Icon(Icons.error),
                        ]
                      : [
                          Text('Problem przy tworzeniu nowej grupy...'),
                          Icon(Icons.error),
                        ],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }
        if (state is GroupLoadingState) {
          disableTouch = true;
          Scaffold.of(scaffoldContext)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: (state.loadingType == GroupConfigurationType.JOINING_TO_GROUP)
                      ? [
                          Text('Dołączam do grupy...'),
                          CircularProgressIndicator(),
                        ]
                      : [
                          Text('Tworzę nową grupę...'),
                          CircularProgressIndicator(),
                        ],
                ),
              ),
            );
        }

        if (state is GroupByQRCodeLoadingState) {
          disableTouch = true;
          Scaffold.of(scaffoldContext)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Szukam grupy...'),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }

        if (state is GroupByQRCodeFoundState) {
          Scaffold.of(scaffoldContext)..hideCurrentSnackBar();
          groupFound = state.group;
          print("Group found : ${groupFound.name}");

          disableTouch = false;
          setState(() {
          });
        }

        if (state is GroupByQRCodeNotFoundState) {
          print("Group founding error");
          disableTouch = false;
          Scaffold.of(scaffoldContext)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Grupa nie istnieje.'), Icon(Icons.error)],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }

        if (state is GroupConfigurationSuccessState) {
          Scaffold.of(scaffoldContext)
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

          if (state.configurationType == GroupConfigurationType.CREATING_GROUP) {
            _showSuccessPage(
              context,
              state.group,
              ConfigurationType.NEW_GROUP,
            );
          } else if (state.configurationType == GroupConfigurationType.JOINING_TO_GROUP) {
            _showSuccessPage(
              context,
              state.group,
              ConfigurationType.JOIN_TO_EXIST,
            );
          }
        }

        if (state is GroupInitialState) {
          if (state.configurationType == GroupConfigurationType.CREATING_GROUP) {
            _newGroupCardColor = Constants.getStartGradientColor(context);
            _joinToGroupCardColor = Colors.black12;
            _groupPageViewController.animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.easeOutCirc);
          } else {
            _newGroupCardColor = Colors.black12;
            _joinToGroupCardColor = Constants.getEndGradientColor(context);
            _groupPageViewController.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.easeOutCirc);
          }
        }
      },
      child: BlocBuilder<GroupBloc, GroupState>(
        builder: (context, state) {
          _groupBloc = BlocProvider.of<GroupBloc>(context);

          return Scaffold(body: Builder(
            builder: (scaffold) {
              scaffoldContext = scaffold;
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
                                _groupBloc.add(
                                  GroupConfigurationTypeChangeEvent(
                                      configurationType: GroupConfigurationType.CREATING_GROUP),
                                );
                              }),
                            ),
                            Expanded(
                              child: buildJoinToGroupCard(onTap: () {
                                _groupBloc.add(
                                  GroupConfigurationTypeChangeEvent(
                                      configurationType: GroupConfigurationType.JOINING_TO_GROUP),
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
                            height: 390,
                            child: PageView(
                              physics: NeverScrollableScrollPhysics(),
                              controller: _groupPageViewController,
                              scrollDirection: Axis.horizontal,
                              children: <Widget>[
                                _buildGroupCreatorWidget(state, _groupNameController),
                                _buildQRCodeGroupView(state),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              );
            },
          ));
        },
      ),
    );
  }

  void _showSuccessPage(BuildContext context, Group group, ConfigurationType configurationType) {
    Future.delayed(const Duration(milliseconds: 500), () {
      BlocProvider.of<AuthBloc>(context).add(AuthLoggedIn());

      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return SuccessPage(
            configurationType: configurationType,
            group: group,
          );
        }),
//        ModalRoute.withName('/'),
      );
    });
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

  Widget _buildGroupCreatorWidget(GroupState state, TextEditingController controller) {
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
              obscureText: false,
              isValid: _groupNameController.text.isNotEmpty,
              validator: (_) {
                return _groupNameController.text.isEmpty ? 'Pole jest puste' : null;
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
                  onPressed: _groupNameController.text.isNotEmpty ? _onCreateGroupClick : null,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeGroupView(GroupState state) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: (state is GroupByQRCodeFoundState)
          ? _buildSecondQRScannerWidget(state.group.name)
          : _buildFirstQRScannerWidget(),
    );
  }

  Widget _buildFirstQRScannerWidget() {
    debugPrint("BuildQRCodeViewWidget");

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
              child: Text(
                "Skanuj kod QR grupy, aby do niej dołączyć.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(top: 30, bottom: 30),
              child: SvgPicture.asset(
                "assets/qr-code.svg",
                width: 150,
                height: 150,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20),
            child: GradientRaisedButton(
              text: "SKANUJ",
              colors: [Constants.getStartGradientColor(context), Constants.getEndGradientColor(context)],
              height: 50,
              onPressed: () {
                scanQRCode().then((value) {
                  setState(() {
                    groupIdFromQrCode = value;
                    debugPrint("Group ID : $groupIdFromQrCode");

                    _onQRScanSuccess();
                  });
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondQRScannerWidget(String groupName) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Text("Dołączyć do grupy :"),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(top: 5, bottom: 40),
              child: Text("$groupName ?",
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                _onJoinToGroupClick();
              },
              child: Container(
                height: 50,
                width: 170,
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(70),
                    border: Border.all(color: Constants.positiveGreenColor),
                    boxShadow: [
                      BoxShadow(
                        color: Constants.positiveGreenColor,
                        blurRadius: 15,
                        spreadRadius: 1,
                        offset: Offset(0, 0),
                      )
                    ]),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.check,
                      color: Constants.positiveGreenColor,
                      size: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Text(
                        "Dołącz".toUpperCase(),
                        style: TextStyle(fontSize: 18.0, color: Constants.positiveGreenColor),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 60),
              child: FlatButton(
                child: Text(
                  "SKANUJ PONOWNIE",
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  scanQRCode().then((value) {
                    setState(() {
                      groupIdFromQrCode = value;
                      debugPrint("Group ID : $groupIdFromQrCode");
                      _onQRScanSuccess();
                    });
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> scanQRCode() async {
    return await FlutterBarcodeScanner.scanBarcode("#bd3356", "Anuluj", true, ScanMode.QR);
  }

  void _onCreateGroupClick() async {
    print("PAGE onCreateGroupClick...");
    _groupBloc.add(GroupConfigurationSubmittingEvent(
      configurationType: GroupConfigurationType.CREATING_GROUP,
      groupName: _groupNameController.text,
    ));
  }

  void _onQRScanSuccess() {
    _groupBloc.add(GroupQRCodeScannedEvent(
      groupId: groupIdFromQrCode,
    ));
  }

  void _onJoinToGroupClick() async {
    _groupBloc.add(GroupConfigurationSubmittingEvent(
      configurationType: GroupConfigurationType.JOINING_TO_GROUP,
      groupId: groupIdFromQrCode,
    ));
  }
}
