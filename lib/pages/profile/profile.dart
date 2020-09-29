import 'package:bando/blocs/profile/profile_bloc.dart';
import 'package:bando/pages/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:koin_flutter/koin_flutter.dart';

class UserProfile extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (context) => get<ProfileBloc>(),
      child: ProfilePage(),
    );
  }
}