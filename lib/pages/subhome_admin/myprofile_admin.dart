// ignore_for_file: unnecessary_import, unused_import, unused_field

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/auth/authlogin.dart';
import 'package:herbal/pages/home_public.dart';
import 'package:herbal/pages/list_cart/list_cart.dart';
import 'package:herbal/pages/list_favorite/list_favorite.dart';
import 'package:herbal/pages/list_transaction/list_transaction.dart';
import 'package:herbal/pages/list_transaction/list_transaction_admin.dart';
import 'package:herbal/shared/shared.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class MyProfileAdmin extends StatefulWidget {
  const MyProfileAdmin({Key? key}) : super(key: key);

  @override
  MyProfileAdminState createState() => MyProfileAdminState();
}

class MyProfileAdminState extends State<MyProfileAdmin> {
  late File imageFile;
  late Uint8List imageTemp;
  late String baseImage;
  final ImagePicker _picker = ImagePicker();
  List<dynamic> tempPop = [];
  double windowHeight = 0;
  double windowWidth = 0;
  bool cropProses = false;
  String token = '';
  var tempData = [];
  bool isLoading = true;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    initiateData();
  }

  initiateData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') != null) {
      token = prefs.getString('token').toString();
    }
    await getItem();
  }

  getItem() async {
    setState(() {
      isLoading = true;
    });
    // await ApiServices().getItems(token).then((json) {
    //   if (json != null) {
    //     print(json);
    //     if (json['status'] == 'success') {
    //       setState(() {
    //         tempData = json['data']['data'];
    //       });
    //       setState(() {
    //         isLoading = false;
    //       });
    //     } else {
    //       alertError(json.toString(), 1);
    //     }
    //   }
    // }).catchError((e) {
    //   alertError(e.toString(), 1);
    // });
    setState(() {
      isLoading = false;
    });
  }

  alertError(String err, int error) {
    setState(() {
      isLoading = false;
    });
    AwesomeDialog(
            context: context,
            dialogType: error == 0 ? DialogType.WARNING : DialogType.ERROR,
            animType: AnimType.SCALE,
            headerAnimationLoop: false,
            title: 'Error',
            desc: err,
            btnOkOnPress: () {},
            btnOkIcon: Icons.cancel,
            btnOkColor: Colors.red)
        .show();
  }

  logoutProses() async {
    bool isSignedGoogle = await _googleSignIn.isSignedIn();
    await ApiServices().logoutLogin(token).then((json) async {
      if (json != null) {
        var jsonConvert = jsonDecode(json);
        if (jsonConvert['status'] == 'success') {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          await preferences.clear();
          if (isSignedGoogle == true) {
            await _handleSignOut();
          }
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
            return const HomePublicPage();
          }));
        } else {
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();
  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: HexColor("2C3246"),
          title: const Text("Setelan"),
        ),
        body: SafeArea(
          bottom: false,
          child: isLoading
              ? Shimmer.fromColors(
                  baseColor: Colors.black12,
                  highlightColor: Colors.black26,
                  enabled: isLoading,
                  // ignore: sized_box_for_whitespace
                  child: Container(
                    height: windowHeight,
                    width: double.infinity,
                    child: Column(children: [
                      for (var i = 0; i < 6; i++)
                        Container(
                          margin: const EdgeInsets.all(10),
                          height: 70,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                    ]),
                  ))
              : Stack(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Container(
                                margin: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text("Pengaturan Akun",
                                        style: TextStyle(
                                            fontFamily: 'Nunito',
                                            color: Colors.black54,
                                            fontSize: 20)),
                                    SizedBox(
                                      height: windowHeight * 0.02,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.assignment_outlined,
                                          size: windowWidth * 0.08,
                                          color: Colors.black87,
                                        ),
                                        SizedBox(
                                          width: windowWidth * 0.02,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: TextButton(
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const TransactionListAdmin()),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: const <Widget>[
                                                Text("Daftar Transaksi",
                                                    style: TextStyle(
                                                      fontFamily: 'Nunito',
                                                      color: Colors.black54,
                                                      fontSize: 18,
                                                    )),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                Text(
                                                    "Menampilkan daftar transaksi pengguna",
                                                    style: TextStyle(
                                                      fontFamily: 'Nunito',
                                                      color: Colors.black54,
                                                      fontSize: 12,
                                                    )),
                                              ],
                                            ),
                                            style: ButtonStyle(
                                              alignment: Alignment
                                                  .centerLeft, // <-- had to set alignment
                                              padding: MaterialStateProperty
                                                  .all<EdgeInsetsGeometry>(
                                                const EdgeInsets.all(
                                                    0), // <-- had to set padding to 0
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: windowWidth * 0.01,
                                    ),
                                  ],
                                ))),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Align(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    onPrimary: HexColor("2C3246"),
                                    onSurface: HexColor("2C3246"),
                                    primary: HexColor("2C3246"),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0)))),
                                onPressed: () => logoutProses(),
                                child: const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Text(
                                    "Keluar",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white),
                                  ),
                                )),
                          ),
                        )
                      ],
                    ),
                    (cropProses)
                        ? Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.black54,
                            child: const Center(
                                child: CircularProgressIndicator()),
                          )
                        : const Center(),
                  ],
                ),
        ));
  }
}
