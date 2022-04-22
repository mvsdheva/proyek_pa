// ignore_for_file: unused_import, unused_field, avoid_unnecessary_containers, prefer_const_constructors

import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/auth/authlogin.dart';
import 'package:herbal/pages/newspaper_details/news_detail_public.dart';
import 'package:herbal/pages/newspaper_details/newspaper_details_public.dart';
import 'package:herbal/shared/shared.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsPaperListPublic extends StatefulWidget {
  const NewsPaperListPublic({Key? key}) : super(key: key);

  @override
  NewsPaperListPublicState createState() => NewsPaperListPublicState();
}

class NewsPaperListPublicState extends State<NewsPaperListPublic> {
  TextEditingController find = TextEditingController();
  double windowHeight = 0;
  double windowWidth = 0;
  String token = '';
  bool isLoading = true;
  var tempData = [];
  var generalData = [];
  Future<void>? _launched;

  var optCategory = [
    {'name': 'All Category', 'val': ''},
    {'name': 'Olahraga', 'val': 'sport'},
    {'name': 'Kesehatan', 'val': 'health'},
    {'name': 'Sosial dan Budaya', 'val': 'social'}
  ];
  String category = "";

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
    await getItem();
    await getGeneralItem();
    setState(() {});
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

  getItem() async {
    setState(() {
      isLoading = true;
    });
    await ApiServices().getNewsUser(token, category).then((json) {
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
        await removeLikeNews(id);
      } else {
        await addLikeNews(id);
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthLoginPage()),
      ).then((value) => initiateData());
    }
  }

  addLikeNews(id) async {
    await ApiServices().addLikeNews(token, id.toString()).then((json) {
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

  removeLikeNews(id) async {
    await ApiServices().removeLikeNews(token, id.toString()).then((json) {
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

  detailBerita(var dataIdCart) async {
    final prefs = await SharedPreferences.getInstance();
    var sendData = [dataIdCart];
    prefs.setString('dataBerita', jsonEncode(sendData));
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const NewsDetailPublic()));
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
          title: const Text("Berita"),
        ),
        body: RefreshIndicator(
          onRefresh: initiateData,
          child: DoubleBackToCloseApp(
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
                child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Stack(
                      children: [
                        (cropProses)
                            ? Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                color: Colors.black54,
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              )
                            : Center(),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: HexColor("2C3246")),
                                        borderRadius:
                                            BorderRadius.circular(20))),
                                isExpanded: false,
                                items: optCategory
                                    .map<DropdownMenuItem<String>>((items) {
                                  return DropdownMenuItem(
                                      value: items['val'].toString(),
                                      child: Text(items['name'].toString()));
                                }).toList(),
                                value: category,
                                onChanged: (val) => setState(() {
                                  category = val.toString();
                                  initiateData();
                                }),
                                onSaved: (val) => setState(() {
                                  category = val.toString();
                                }),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),

                            for (int index = 0;
                                index < tempData.length;
                                index++)
                              InkWell(
                                onTap: () => detailBerita(tempData[index]),
                                splashColor: HexColor("2C3246"),
                                highlightColor:
                                    HexColor("2C3246").withOpacity(0.5),
                                child: Container(
                                  margin: EdgeInsets.all(12.0),
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.0),
                                      // ignore: prefer_const_literals_to_create_immutables
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 3.0,
                                        ),
                                      ]),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding:
                                              EdgeInsets.fromLTRB(8, 0, 8, 0),
                                          height: 200.0,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                  tempData.isNotEmpty
                                                      ? tempData[index]['image']
                                                              ['path']
                                                          .toString()
                                                      : 'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                                                ),
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8.0,
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(6.0),
                                          decoration: BoxDecoration(
                                            color: HexColor("2C3246"),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Text(
                                            !isLoading
                                                ? tempData[index]['author']
                                                    .toString()
                                                : '',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8.0,
                                        ),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  alignment: Alignment.centerLeft,
                                                  child: Text(
                                                    !isLoading
                                                        ? tempData[index]['title']
                                                            .toString()
                                                        : '',
                                                        softWrap: false,
                                                        overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 20.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: IconButton(
                                                    iconSize: 35,
                                                    onPressed: () {
                                                      likeManagement(
                                                          tempData[index]['id'],
                                                          tempData[index]
                                                              ['has_like']);
                                                    },
                                                    icon: Icon(
                                                      tempData[index]
                                                              ['has_like']
                                                          ? Icons.favorite
                                                          : Icons
                                                              .favorite_outline,
                                                      color: tempData[index]
                                                              ['has_like']
                                                          ? Colors.red
                                                          : HexColor("2C3246"),
                                                    ),
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ]),
                                ),
                              )
                            // Container(
                            //   margin: const EdgeInsets.all(10),
                            //   decoration: const BoxDecoration(
                            //     borderRadius:
                            //         BorderRadius.all(Radius.circular(20.0)),
                            //     color: Colors.black12,
                            //   ),
                            //   child: InkWell(
                            //     splashColor: Colors.yellow,
                            //     highlightColor: Colors.blue.withOpacity(0.5),
                            //     borderRadius:
                            //         const BorderRadius.all(Radius.circular(20.0)),
                            //     onTap: () => detailBerita(tempData[index]),
                            //     child: Padding(
                            //       padding: const EdgeInsets.symmetric(
                            //           vertical: 15, horizontal: 15),
                            //       child: Align(
                            //         alignment: Alignment.topLeft,
                            //         child: Row(
                            //           children: [
                            //             Image.network(
                            //                 tempData.isNotEmpty
                            //                     ? tempData[index]['image']['path']
                            //                         .toString()
                            //                     : 'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                            //                 width: 80,
                            //                 height: 80),
                            //             Expanded(
                            //               flex: 3,
                            //               child: Padding(
                            //                 padding: const EdgeInsets.symmetric(
                            //                     horizontal: 20),
                            //                 child: Column(
                            //                   crossAxisAlignment:
                            //                       CrossAxisAlignment.start,
                            //                   mainAxisAlignment:
                            //                       MainAxisAlignment.start,
                            //                   children: [
                            //                     Text(
                            //                       !isLoading
                            //                           ? tempData[index]['title']
                            //                               .toString()
                            //                           : '',
                            //                       textAlign: TextAlign.left,
                            //                     ),
                            //                     Text(!isLoading
                            //                         ? tempData[index]['title']
                            //                             .toString()
                            //                         : ''),
                            //                   ],
                            //                 ),
                            //               ),
                            //             ),
                            //             Expanded(
                            //                 flex: 1,
                            //                 child: IconButton(
                            //                   onPressed: () {
                            //                     likeManagement(
                            //                         tempData[index]['id'],
                            //                         tempData[index]['has_like']);
                            //                   },
                            //                   icon: Icon(
                            //                     tempData[index]['has_like']
                            //                         ? Icons.favorite
                            //                         : Icons.favorite_outline,
                            //                     color: tempData[index]['has_like']
                            //                         ? Colors.red
                            //                         : Colors.blue,
                            //                   ),
                            //                 ))
                            //           ],
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // )
                          ],
                        ),
                      ],
                    )),
              )),
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
