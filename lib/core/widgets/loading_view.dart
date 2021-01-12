import 'package:bando/core/utils/context_extensions.dart';
import 'package:bando/core/widgets/logo_loading.dart';
import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background.withOpacity(0.6),
      body: Center(
        child: LogoLoading(
          autoRun: true,
        ),
      ),
    );
  }

}