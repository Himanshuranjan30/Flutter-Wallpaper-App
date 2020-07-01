import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.indigo[100],
      child: Center(
        child: SpinKitRotatingCircle(
          color: Colors.indigo,
          size: 50.0,
        ),
      ),
    );
  }
}