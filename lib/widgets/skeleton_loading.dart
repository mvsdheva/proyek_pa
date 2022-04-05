import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  final bool visible;
  Loading(this.visible);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Visibility(
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          visible: visible,
          child: Container(
            color: Colors.black45,
            child: const SpinKitFadingCube(
              color: Colors.amber,
            ),
          )),
    );
  }
}
