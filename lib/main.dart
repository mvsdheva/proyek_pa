// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:herbal/pages/home.dart';
import 'package:herbal/pages/home_public.dart';
import 'package:herbal/widgets/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages//auth/authlogin.dart';

void main(){
  runApp(  MyApp()
  // MaterialApp(
  //     debugShowCheckedModeBanner: false,
  //     home: isRoleAdmin == "users" ? HomePublicPage() : HomeAdminPage()));
);
}
class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen() ,
    );
  }
}