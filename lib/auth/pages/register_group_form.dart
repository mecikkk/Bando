import 'package:bando/auth/blocs/register_bloc/register_bloc.dart';
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
  final BuildContext scaffoldContext;


  RegisterGroupForm(this.scaffoldContext);

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

  String groupId;

  Widget _joinToGroupWidget;

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

    _joinToGroupWidget = _buildFirstQRScannerWidget();

    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        // Hide Snackbar from previous page
//        if (state.isRegistrationSuccess) {
//          Scaffold.of(context)..hideCurrentSnackBar();
//        }

        if (state.isFailure) {
          Scaffold.of(widget.scaffoldContext)
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
          Scaffold.of(widget.scaffoldContext)
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
          Scaffold.of(widget.scaffoldContext)
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

        if(state.isSearchingForGroup) {
          disableTouch = true;
          Scaffold.of(widget.scaffoldContext)
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

        if(state.isGroupByQRCodeFound){
          Scaffold.of(widget.scaffoldContext)
            ..hideCurrentSnackBar();

          print("Group found : ${state.groupName}");
          disableTouch = false;
          setState(() {
            _joinToGroupWidget = _buildSecondQRScannerWidget(state.groupName);
          });
        }

        if(state.isFindingGroupByQrCodeFailure) {
          print("Group founding error");
          disableTouch = false;
          Scaffold.of(widget.scaffoldContext)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Taka grupa nie istnieje..'), Icon(Icons.error)],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }

        if (state.isGroupConfigurationSuccess) {
          Scaffold.of(widget.scaffoldContext)
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
          if(state.isNewGroupCreating) {
            Future.delayed(const Duration(milliseconds: 1000), () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      return SuccessPage(
                        configurationType: ConfigurationType.NEW_GROUP,
                        groupId: state.groupId,
                        groupName: _groupNameController.text,
                      );
                    }),
              );
            });
          } else if(state.isJoiningToExistingGroup){

            // TODO : Ten state nie przechwyca nazwy grupy. Trzeba w State .joiningToGroupConfigured przez parametr dac nazwe grupy czy cos

            Future.delayed(const Duration(milliseconds: 1000), () {
              Navigator.of(
                  context).push(
                MaterialPageRoute(
                    builder: (context) {
                      return SuccessPage(
                        configurationType: ConfigurationType.JOIN_TO_EXIST,
                        groupId: state.groupId,
                        groupName: state.groupName,
                      );
                    }),
              );
            });
          }
        }

        // TODO : Ogranac cofanie sie przyciskiem wstecz w nieodpowiednich miejscach

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
          return Scaffold(
            body: AbsorbPointer(
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
                          height: 390,
                          child: PageView(
                            physics: NeverScrollableScrollPhysics(),
                            controller: _groupPageViewController,
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              _buildGroupCreatorWidget(state, _groupNameController),
                              _buildQRCodeGroupView(state.isGroupByQRCodeFound, groupName : state.groupName) ,
                            ],
                          ),
                        )),
                  ],
                ),
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

  Widget _buildQRCodeGroupView(bool isGroupFounded, {String groupName = ""}) {

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: isGroupFounded ? _buildSecondQRScannerWidget(groupName) : _buildFirstQRScannerWidget(),
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
              child: SvgPicture.asset("assets/qr-code.svg", width: 150, height: 150,),
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
                    groupId = value;
                    debugPrint("Group ID : $groupId");

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
              child: Text("$groupName ?", style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold,)),
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
                  border : Border.all(
                    color: Constants.positiveGreenColor
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Constants.positiveGreenColor,
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: Offset(0,0),
                    )
                  ]
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.check, color: Constants.positiveGreenColor, size: 30,),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Text("Dołącz".toUpperCase(), style: TextStyle(fontSize: 18.0, color: Constants.positiveGreenColor),),
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
                child: Text("SKANUJ PONOWNIE", style: TextStyle(fontSize: 16),),
                onPressed: () {
                  scanQRCode().then((value) {
                    setState(() {
                      groupId = value;
                      debugPrint("Group ID : $groupId");
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


  // TODO : Przetestowac i rozkminić ui do doawania sie do grupy
  Future<String> scanQRCode() async {
    return await FlutterBarcodeScanner.scanBarcode(
        "#bd3356",
        "Anuluj",
        true,
        ScanMode.QR);
  }

  void _onCreateGroupClick() {
    _registerBloc.add(RegisterSubmittedNewGroup(
      groupName: _groupNameController.text,
    ));
  }

  void _onQRScanSuccess() {
    _registerBloc.add(RegisterQRCodeScanned(
      groupId: groupId,
    ));
  }

  void _onJoinToGroupClick() {
    _registerBloc.add(RegisterSubmittedJoinToGroup(
      groupId: groupId,
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
