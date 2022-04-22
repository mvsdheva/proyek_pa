// ignore_for_file: avoid_print, unnecessary_new

import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/auth/authlogin.dart';
import 'package:herbal/pages/list_cart/list_cart.dart';
import 'package:herbal/pages/medicine_details/medicine_details.dart';
import 'package:herbal/shared/shared.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MedicinePage extends StatefulWidget {
  const MedicinePage({Key? key}) : super(key: key);

  @override
  MedicinePageState createState() => MedicinePageState();
}

class MedicinePageState extends State<MedicinePage> {
  TextEditingController find = TextEditingController();
  double windowHeight = 0;
  double windowWidth = 0;
  String token = "";
  var tempData = [];
  var generalData = [];
  int cartPending = 0;
  var list_unit = [];
  int idItem = 0;
  var tempSendCart = [];

  Future<void>? _launched;

  bool cropProses = false;

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
    await getCart();
    await getItem();
    await getGeneralItem();
    await getUnits();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getUnits() async {
    await ApiServices().getUnits(token).then((json) {
      if (json != null) {
        setState(() {
          list_unit = json;
        });
      }
    }).catchError((e) {
      print("error1");

      alertError(e.toString(), 1);
    });
  }

  getGeneralItem() async {
    await ApiServices().getGeneralData().then((json) {
      if (json != null) {
        setState(() {
          generalData.add(json);
        });
      }
    }).catchError((e) {
      print("error2");

      alertError(e.toString(), 1);
    });
  }

  getItem() async {
    await ApiServices().getItemsPublic(token, idItem.toString(),find.text).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          setState(() {
            tempData = json['data']['data'];
            print(tempData.asMap());
          });
        } else {
          print("error3");
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      print("error4");
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
    await ApiServices().addLikeItem(token, id.toString()).then((json) {
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
    await ApiServices().removeLikeItem(token, id.toString()).then((json) {
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

  Future getCart() async {
    if (await checkTokenisExist()) {
      final prefs = await SharedPreferences.getInstance();
      await ApiServices().getCart(token).then((json) {
        if (json != null) {
          if (json['status'] == 'success' && json['data']['data'].length > 0) {
            if (json['data']['data'][0]['data'].length > 0) {
              for (var i = 0; i < json['data']['data'][0]['data'].length; i++) {
                tempSendCart.add({
                  'id': json['data']['data'][0]['data'][i]['id'],
                  'volume': json['data']['data'][0]['data'][i]['volume'],
                  'price': json['data']['data'][0]['data'][i]['price']
                });
              }
              setState(() {
                cartPending = json['data']['data'][0]['data'].length;
              });
              prefs.setString('dataCart', jsonEncode(tempSendCart));
            } else {
              prefs.setString('dataCart', "");
              cartPending = 0;
            }
          }
        }
      }).catchError((e) {
        print("error5");
        alertError(e.toString(), 1);
      });
    } else {
      cartPending = 0;
    }
  }

  Future refreshData() async {
    await Future.delayed(const Duration(milliseconds: 200));
    getCart();
  }

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

  setIDCart(var dataIdCart) async {
    final prefs = await SharedPreferences.getInstance();
    var sendData = [await dataIdCart];
    await prefs.setString('idItemCart', jsonEncode(sendData));
    Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MedicineDetails()))
        .then((value) => initiateData());
    // if (await checkTokenisExist()) {

    // }else{

    //   Navigator.push(context,
    //           MaterialPageRoute(builder: (context) => const AuthLoginPage()))
    //       .then((value) => initiateData());
    // }
  }

  listCart() async {
    if (await checkTokenisExist()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ListCart()),
      ).then((value) => initiateData());
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthLoginPage()),
      );
    }
  }

  Future<void> _launchInWebViewOrVC() async {
    String url =
        "https://wa.me/${generalData[0]['phone_number'].toString()}?text=Hello, Saya ingin menanyakan tentang obat herbal";
    if (await canLaunch(url)) {
      await launch(
        url,
        universalLinksOnly: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height - 25;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: HexColor("2C3246"),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                flex: 1,
                child: Text("Obat Herbal"),
              ),
              Stack(children: [
                IconButton(
                    iconSize: 40,
                    onPressed: () {
                      listCart();
                    },
                    icon: const Icon(
                      Icons.shopping_cart,
                      size: 30,
                    )),
                new Positioned(
                    right: 1,
                    top: 3,
                    child: cartPending > 0
                        ? Container(
                            width: windowWidth * 0.07,
                            height: windowWidth * 0.05,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              color: Colors.red,
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                cartPending.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          )
                        : Text(''))
              ])
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: initiateData,
          child: Container(
              margin: const EdgeInsets.all(20),
              child: ListView(children: [
                TextField(
                  onEditingComplete: () => getItem(),
                  controller: find,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      labelText: "Cari Obat"),
                ),
                SizedBox(
                  height: 10,
                ),
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Wrap(
                        children: [
                          for (var i = 0; i < tempData.length; i++)
                            Container(
                              margin: const EdgeInsets.all(7),
                              width: windowWidth * 0.4,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  onPrimary: defaultColor,
                                  onSurface: Colors.white,
                                  primary: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(15)),
                                  ),
                                ),
                                onPressed: () {
                                  setIDCart(tempData[i]);
                                },
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Stack(
                                    children: <Widget>[
                                      // Positioned(
                                      //   top: 0.0,
                                      //   right: -10.0,
                                      //   width: 50,
                                      //   child: IconButton(
                                      //     onPressed: () {
                                      //       likeManagement(
                                      //           tempData[i]['detail'][0]['id'],
                                      //           tempData[i]['detail'][0]['has_like']);
                                      //     },
                                      //     icon: Icon(
                                      //       tempData[i]['detail'][0]['has_like']
                                      //           ? Icons.favorite
                                      //           : Icons.favorite_outline,
                                      //       color: tempData[i]['detail'][0]
                                      //               ['has_like']
                                      //           ? Colors.red
                                      //           : Colors.blue,
                                      //     ),
                                      //     color: Colors.blue,
                                      //   ),
                                      // ),
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Center(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: windowWidth * 0.01,
                                                height: windowHeight * 0.01,
                                              ),
                                              Align(
                                                  alignment: Alignment.center,
                                                  child: Image.network(
                                                      tempData[i]['image']
                                                              ['path']
                                                          .toString(),
                                                      width: 100,
                                                      height: 100)),
                                              SizedBox(
                                                width: windowWidth * 0.01,
                                                height: windowHeight * 0.01,
                                              ),
                                              Center(
                                                child: Text(
                                                  tempData[i]['name']
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: windowWidth * 0.01,
                                                height: windowHeight * 0.01,
                                              ),
                                              // Row(
                                              //   children: [
                                              //     Expanded(
                                              //       flex: 3,
                                              //       child: Text(
                                              //         "Rp. " +
                                              //             tempData[i]['detail'][0]
                                              //                     ['price']
                                              //                 .toString(),
                                              //         style: const TextStyle(
                                              //           color: Colors.black,
                                              //         ),
                                              //       ),
                                              //     ),
                                              //     Expanded(
                                              //         flex: 1,
                                              //         child: IconButton(
                                              //           highlightColor: Colors.black,
                                              //           onPressed: () {
                                              //             Navigator.push(
                                              //                 context,
                                              //                 MaterialPageRoute(
                                              //                     builder: (context) =>
                                              //                         const MedicineDetails()));
                                              //           },
                                              //           icon: const Icon(
                                              //             Icons.add_circle,
                                              //             size: 30,
                                              //             color: Colors.blueAccent,
                                              //           ),
                                              //         ))
                                              //   ],
                                              // ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
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
              ])),
        ),
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
