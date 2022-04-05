// ignore_for_file: prefer_const_constructors

import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:herbal/pages/subhome_admin/apotek_admin.dart';
import 'package:herbal/pages/subhome_admin/home_admin.dart';
import 'package:herbal/pages/subhome_admin/medicine_admin.dart';
import 'package:herbal/pages/subhome_admin/myprofile_admin.dart';
import 'package:herbal/pages/subhome_admin/newspaper_list.dart';
import 'package:herbal/pages/subhome_admin/radio_admin.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomeAdminPage extends StatefulWidget {
  const HomeAdminPage({Key? key}) : super(key: key);

  @override
  HomeAdminPageState createState() => HomeAdminPageState();
}

class HomeAdminPageState extends State<HomeAdminPage> {
  final List<Widget> _widgetList = [
    const BerandaAdmin(),
    const MyProfileAdmin(),
  ];
  int _index = 0;
  double windowHeight = 0;
  double windowWidth = 0;
  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height - 25;
    windowWidth = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Nunito'),
      home: Scaffold(
          bottomNavigationBar: Container(
            height: 60,
            width: double.infinity,
            // ignore: prefer_const_constructors
            margin: EdgeInsets.fromLTRB(5, 0, 5, 8),
            decoration: BoxDecoration(
              color: HexColor("#2C3246"),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: SalomonBottomBar(
                margin: EdgeInsets.symmetric(horizontal: 70),
                  selectedItemColor: HexColor("#3DD9D6"),
                  unselectedItemColor: Colors.white,
                  currentIndex: _index,
                  onTap: (index) {
                    setState(() {
                      _index = index;
                    });
                  },
                  items: [
                    SalomonBottomBarItem(
                      icon: Icon(Icons.home),
                      title: Text(
                        "Home",
                        style: GoogleFonts.nunito(),
                      ),
                    ),
                    SalomonBottomBarItem(
                      icon: Icon(Icons.account_circle),
                      title: Text(
                        "Setting",
                        style: GoogleFonts.nunito(),
                      ),
                    ),
                  ]),
            ),
          ),
          // BottomNavigationBar(
          //   selectedItemColor: HexColor("#50A8EA"),
          //   unselectedItemColor: Colors.black,
          //   type: BottomNavigationBarType.shifting,
          //   currentIndex: _index,
          //   onTap: (index) {
          //     setState(() {
          //       _index = index;
          //     });
          //   },
          //   items: const [
          //     BottomNavigationBarItem(
          //         icon: Icon(
          //           Icons.home, size: 35,
          //         ),
          //         title: Text('Beranda', style: TextStyle())),

          //     BottomNavigationBarItem(
          //         icon: Icon(
          //           Icons.account_circle,size: 35,
          //         ),
          //         title: Text(
          //           'Setelan',
          //           style: TextStyle(),
          //         ))
          //   ],
          // ),
          body: DoubleBackToCloseApp(
            snackBar: SnackBar(
                duration: const Duration(seconds: 1),
                width: windowWidth * 0.7,
                behavior: SnackBarBehavior.floating,
                elevation: 6.0,
                content: const Text(
                  'Tekan sekali lagi untuk keluar',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                )),
            child: _widgetList[_index],
          )),
    );
  }
}
