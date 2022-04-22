// ignore_for_file: prefer_const_constructors
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:herbal/pages/subhome_public/medicine.dart';
import 'package:herbal/pages/subhome_public/homelistpublic.dart';
import 'package:herbal/pages/subhome_public/newspaperlist_public.dart';
import 'package:herbal/pages/subhome_public/radio_public.dart';
import 'package:herbal/pages/subhome_public/myprofile_public.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomePublicPage extends StatefulWidget {
  const HomePublicPage({Key? key}) : super(key: key);

  @override
  HomePublicPageState createState() => HomePublicPageState();
}

class HomePublicPageState extends State<HomePublicPage> {
  final List<Widget> _widgetList = [
    const HomeListPublic(),
    const NewsPaperListPublic(),
    const MedicinePage(),
    const RadioListPublic(),
    const MyProfilePublic(),
  ];
  int _index = 0;
  double windowHeight = 0;
  double windowWidth = 0;
  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height - 25;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false, 
        bottomNavigationBar: Container(
          height: 60,
          width: double.infinity,
          // ignore: prefer_const_constructors
          margin: EdgeInsets.fromLTRB(5, 0, 5, 8),
          decoration: BoxDecoration(
            color: HexColor("#2C3246"),
            borderRadius: BorderRadius.circular(50),
          ),
          child: SalomonBottomBar(
            selectedItemColor: HexColor("#3DD9D6"),
            unselectedItemColor: Colors.white,
            currentIndex: _index,
            onTap: (index) {
              setState(() {
                _index = index;
              });
            },
            items: [
              /// Home
              SalomonBottomBarItem(
                icon: Icon(Icons.home),
                title: Text(
                  "Home",
                  style: GoogleFonts.nunito(fontSize: 13),
                ),
              ),

              /// Likes
              SalomonBottomBarItem(
                icon: Icon(Icons.my_library_books),
                title: Text(
                  "Berita",
                  style: GoogleFonts.nunito(fontSize: 12),
                ),
              ),

              /// Search
              SalomonBottomBarItem(
                icon: Icon(Icons.shopping_cart),
                title: Text(
                  "Obat Herbal",
                  style: GoogleFonts.nunito(fontSize: 12),
                ),
              ),

              SalomonBottomBarItem(
                icon: Icon(Icons.radio),
                title: Text(
                  "Radio",
                  style: GoogleFonts.nunito(fontSize: 12),
                ),
              ),

              /// Profile
              SalomonBottomBarItem(
                icon: Icon(Icons.account_circle),
                title: Text(
                  "Setting",
                  style: GoogleFonts.nunito(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        
        // bottomNavigationBar:
        // BottomNavigationBar(
        //   backgroundColor: Colors.blue,
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
        //           Icons.home,
        //         ),
        //         title: Text('Beranda', style: TextStyle())),
        //     BottomNavigationBarItem(
        //         icon: Icon(
        //           Icons.my_library_books,
        //         ),
        //         title: Text('Berita', style: TextStyle())),
        //     BottomNavigationBarItem(
        //         icon: Icon(Icons.shopping_cart),
        //         title: Text('Belanja', style: TextStyle())),
        //     BottomNavigationBarItem(
        //         icon: Icon(
        //           Icons.radio,
        //         ),
        //         title: Text(
        //           'Radio',
        //           style: TextStyle(),
        //         )),
        //     BottomNavigationBarItem(
        //         icon: Icon(
        //           Icons.account_circle,
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
        ));
  }

  List<IconData> listOfIcons = [
    Icons.home_rounded,
    Icons.my_library_books,
    Icons.shopping_cart,
    Icons.radio,
    Icons.settings
  ];

  List<String> listOfStrings = [
    'Home',
    'Berita',
    'Obat Herbal',
    'Radio',
    'Setting'
  ];
}
