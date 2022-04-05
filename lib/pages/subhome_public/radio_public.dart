// ignore_for_file: unused_import, unused_field, prefer_const_constructors, avoid_unnecessary_containers

import 'dart:convert';
import 'dart:ui';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/auth/authlogin.dart';
import 'package:herbal/pages/radio_details/radio_details_pubic.dart';
import 'package:herbal/shared/shared.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class RadioListPublic extends StatefulWidget {
  const RadioListPublic({Key? key}) : super(key: key);

  @override
  RadioListPublicState createState() => RadioListPublicState();
}

class RadioListPublicState extends State<RadioListPublic> {
  double windowHeight = 0;
  double windowWidth = 0;
  String token = '';

  var tempData = [];
  bool isLoading = true;
  var generalData = [];
  Future<void>? _launched;

  @override
  void initState() {
    super.initState();
    initiateData();
  }

  Future initiateData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') != null) {
      token = prefs.getString('token').toString();
    }
    await getItem();
    await getGeneralItem();
  }

  getGeneralItem() async {
    await ApiServices().getGeneralData().then((json) {
      if (json != null) {
        setState(() {
          generalData.add(json);
        });
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  checkTokenisExist() async {
    if (token != "") {
      return true;
    } else {
      return false;
    }
  }

  likeManagement(id, value) async {
    if (await checkTokenisExist()) {
      if (value == true) {
        await removeLikeItem(id);
      } else {
        await addLikeItem(id);
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthLoginPage()),
      );
    }
  }

  addLikeItem(id) async {
    await ApiServices().addLikeRadio(token, id.toString()).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          initiateData();
        } else {
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  removeLikeItem(id) async {
    await ApiServices().removeLikeRadio(token, id.toString()).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          initiateData();
        } else {
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  getItem() async {
    setState(() {
      isLoading = true;
    });
    await ApiServices().getRadioUser(token).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          setState(() {
            tempData = json['data']['data'];
          });
        } else {
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
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

  streamingRadio(index) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('streamingRadio', jsonEncode(tempData[index]));

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const RadioDetailsPublic()));
  }

  Future<void> _launchInWebViewOrVC() async {
    String url =
        "https://wa.me/${generalData[0]['phone_number'].toString()}?text=Hello, Saya ingin menanyakan tentang obat herbal";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('error');
      throw 'Error occured';
    }
  }

  Future refreshData() async {
    await Future.delayed(const Duration(milliseconds: 200));
    initiateData();
  }

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height - 25;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: HexColor("2C3246"),
          title: const Text("Radio"),
        ),
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
            child: SafeArea(
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
                  : Stack(children: <Widget>[
                      RefreshIndicator(
                        onRefresh: initiateData,
                        child: GridView(
                            padding: EdgeInsets.fromLTRB(4, 8, 4, 4),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16),
                            children: [
                              for (int index = 0;
                                  index < tempData.length;
                                  index++)
                                Container(
                                  //  padding: EdgeInsets.fromLTRB(4, 8, 4, 4),
                                  margin: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade200,
                                        spreadRadius: 3,
                                        blurRadius: 10,
                                        offset: Offset(0, 3),
                                      )
                                    ],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                    color: Colors.white,
                                  ),
                                  child: InkWell(
                                    splashColor: Colors.yellow,
                                    highlightColor:
                                        HexColor("2C3246").withOpacity(0.5),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20.0)),
                                    onTap: () => streamingRadio(index),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Image.network(
                                                tempData[index]['image']['path']
                                                    .toString(),
                                                width: 100,
                                                height: 100),
                                            Padding(
                                              padding: const EdgeInsets.all(0),
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 25),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                        tempData[index]['name']
                                                            .toString(),
                                                        textAlign: TextAlign.left,
                                                        style: TextStyle(
                                                            fontSize: 20)),
                                                    // IconButton(
                                                    //   onPressed: () {
                                                    //     likeManagement(
                                                    //         tempData[index]['id'],
                                                    //         tempData[index]
                                                    //             ['has_like']);
                                                    //             print('paulus');
                                                    //             print(tempData[index]
                                                    //             ['has_like']);
                                                    //   },
                                                    //   icon: Icon(
                                                    //     tempData[index]
                                                    //             ['has_like']
                                                    //         ? Icons.favorite
                                                    //         : Icons
                                                    //             .favorite_border,
                                                    //     color: tempData[index]
                                                    //             ['has_like']
                                                    //         ? Colors.red
                                                    //         : Colors.blue,
                                                    //   ),
                                                    //   color: Colors.black,
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                            ]),
                      ),
                    ]),
            )),
        floatingActionButton: FloatingActionButton.small(
          focusColor: Colors.transparent,
          child: Image.asset(
            "assets/images/wa.png",
            height: 50,
          ),
          onPressed: () => setState(() {
            _launched = _launchInWebViewOrVC();
          }),
        ));
  }
}