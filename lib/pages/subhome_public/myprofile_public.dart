// ignore_for_file: unused_import, unnecessary_null_comparison, avoid_print

import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/address_list/list_address.dart';
import 'package:herbal/pages/auth/authlogin.dart';
import 'package:herbal/pages/detail_myprofile/detail_myprofile_public.dart';
import 'package:herbal/pages/home_public.dart';
import 'package:herbal/pages/list_cart/list_cart.dart';
import 'package:herbal/pages/list_favorite/list_favorite.dart';
import 'package:herbal/pages/list_transaction/list_transaction.dart';
import 'package:herbal/shared/shared.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class MyProfilePublic extends StatefulWidget {
  const MyProfilePublic({Key? key}) : super(key: key);

  @override
  MyProfilePublicState createState() => MyProfilePublicState();
}

class MyProfilePublicState extends State<MyProfilePublic> {
  double windowHeight = 0;
  double windowWidth = 0;
  String token = '';
  bool cropProses = false;
  var tempData = [];
  bool isLoading = true;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    initiateData();
  }

  initiateData() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') != null) {
      token = prefs.getString('token').toString();
    }
    tempData = [];
    if (token != "") {
      await getItem();
    }
    setState(() {
      isLoading = false;
    });
  }

  getItem() async {
    await ApiServices().getProfileUser(token).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          setState(() {
            tempData.add(json['data']);
          });
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  logoutProses() async {
    bool isSignedGoogle = await _googleSignIn.isSignedIn();
    await ApiServices().logoutLogin(token).then((json) async {
      if (json != null) {
        var jsonConvert = jsonDecode(json);
        if (jsonConvert['status'] == 'success') {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          await preferences.clear();
          print(isSignedGoogle);
          if (isSignedGoogle == true) {
            print('login google true');
            await _handleSignOut();
            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (_) {
              return const HomePublicPage();
            }));
          } else {
            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (_) {
              return const HomePublicPage();
            }));
          }
        } else {
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();
  alertError(String err, int error) {
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

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height - 25;
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
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
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
              : token != ""
                  ? Stack(
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Image.network(
                                        !isLoading
                                            ? tempData[0]['image']['name'] ==
                                                    "default.jpg"
                                                ? "'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg'"
                                                : tempData[0]['image']['path']
                                                    .toString()
                                            : 'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                                        width: 50,
                                        height: 50,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.network(
                                            'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                                            width: 50,
                                            height: 50,
                                          );
                                        },
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              !isLoading
                                                  ? tempData[0]['name']
                                                  : 'Nama Pengguna',
                                              style: const TextStyle(
                                                fontFamily: 'Nunito',
                                                color: Colors.black54,
                                                fontSize: 17,
                                              )),
                                          SizedBox(
                                            height: windowHeight * 0.01,
                                          ),
                                          Text(
                                              !isLoading
                                                  ? tempData[0]['no_telephone']
                                                      .toString()
                                                  : 'Nomor telepon',
                                              style: const TextStyle(
                                                fontFamily: 'Nunito',
                                                color: Colors.black54,
                                                fontSize: 13,
                                              ))
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                            Expanded(
                                flex: 1,
                                child: SingleChildScrollView(
                                  child: Container(
                                      margin: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                                Icons.account_circle_rounded,
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
                                                            const MyDetailProfilePublic()),
                                                  ).then(
                                                      (value) => initiateData()),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: const <Widget>[
                                                      Text("Ubah Saya",
                                                          style: TextStyle(
                                                            fontFamily: 'Nunito',
                                                            color: Colors.black54,
                                                            fontSize: 18,
                                                          )),
                                                      SizedBox(
                                                        height: 2,
                                                      ),
                                                      Text(
                                                          "Mengubah data diri pengguna",
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
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: windowHeight * 0.01,
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.home,
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
                                                            const ListAddress()),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: const <Widget>[
                                                      Text("Daftar Alamat",
                                                          style: TextStyle(
                                                            fontFamily: 'Nunito',
                                                            color: Colors.black54,
                                                            fontSize: 18,
                                                          )),
                                                      SizedBox(
                                                        height: 2,
                                                      ),
                                                      Text(
                                                          "Atur alamat pengiriman belanjaan",
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
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: windowHeight * 0.02,
                                          ),
                                          const Text("Aktifitas Saya",
                                              style: TextStyle(
                                                  fontFamily: 'Nunito',
                                                  color: Colors.black54,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.normal)),
                                          SizedBox(
                                            height: windowHeight * 0.02,
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.favorite_border_sharp,
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
                                                            const ListFavorite()),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: const <Widget>[
                                                      Text("Daftar Keinginan",
                                                          style: TextStyle(
                                                            fontFamily: 'Nunito',
                                                            color: Colors.black54,
                                                            fontSize: 18,
                                                          )),
                                                      SizedBox(
                                                        height: 2,
                                                      ),
                                                      Text(
                                                          "Menampilkan daftar keinginan setial hal",
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
                                                            const TransactionList()),
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
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.shop,
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
                                                            const ListCart()),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: const <Widget>[
                                                      Text("Daftar Keranjang",
                                                          style: TextStyle(
                                                            fontFamily: 'Nunito',
                                                            color: Colors.black54,
                                                            fontSize: 18,
                                                          )),
                                                      SizedBox(
                                                        height: 2,
                                                      ),
                                                      Text(
                                                          "Menampilkan daftar keranjang pengguna",
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
                                        ],
                                      )),
                                )),
                            Align(
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
                    )
                  : Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 20),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                                'Anda belum login, Silakan login untuk mendapatkan lebih banyak keuntungan!',
                                style: const TextStyle(
                                  fontSize: 15,
                                )),
                            Align(
                                alignment: Alignment.center,
                                child: Container(
                                  margin: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: HexColor("2C3246"),
                                      onPrimary: HexColor("2C3246"),
                                      onSurface: HexColor("2C3246"),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(80.0)),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const AuthLoginPage()),
                                      ).then((value) => initiateData());
                                    },
                                    child: Container(
                                      constraints: const BoxConstraints(
                                          maxWidth: 250.0, minHeight: 50.0),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "Login",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                    ),
                                  ),
                                )),
                          ])),
        ));
  }
}
