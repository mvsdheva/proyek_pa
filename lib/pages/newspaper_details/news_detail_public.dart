import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/auth/authlogin.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe

class NewsDetailPublic extends StatefulWidget {
  const NewsDetailPublic({Key? key}) : super(key: key);

  @override
  _NewsDetailPublicState createState() => _NewsDetailPublicState();
}

class _NewsDetailPublicState extends State<NewsDetailPublic> {
  double windowHeight = 0;
  double windowWidth = 0;
  var dataNews = [];
  bool isLoading = true;
  int id = 0;
  String token = "";
  var datePublish = "";
  var tempData = [];
  @override
  void initState() {
    initializeDateFormatting('id');
    initiateData();
    super.initState();
  }

  Future<void> share() async {
    await FlutterShare.share(
        title: 'Dapatkan Aplikasi',
        text:
            'Dapatkan aplikasi BSK Media App dengan mengunduh link yang tersedia',
        linkUrl: 'https://flutter.dev/',
        chooserTitle: 'aaaaaa');
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
    await ApiServices().addLikeNews(token, id.toString()).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          print("berhasil1");
          setState(() {});
        } else {
          print("error7");
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      print("error6");
      alertError(e.toString(), 1);
    });
  }

  removeLikeItem(id) async {
    await ApiServices().removeLikeNews(token, id.toString()).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          print("berhasil2");
          setState(() {});
        } else {
          print("error9");
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      print("error8");
      alertError(e.toString(), 1);
    });
  }

  getGeneralItem() async {
    await ApiServices().getGeneralData().then((json) {
      if (json != null) {
        setState(() {
          tempData.add(json);
        });
      }
    }).catchError((e) {
      print("error1");
      alertError(e.toString(), 1);
    });
  }

  getItem() async {
    await ApiServices().getItemsPublic(token, id.toString(), "").then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          tempData.clear();
          print("berhasil");
          setState(() {
            tempData = json['data']['data'];
          });
        } else {
          print("error5");
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      print("error3");
      alertError(e.toString(), 1);
    });
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

  initiateData() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') != null) {
      token = prefs.getString('token').toString();
    }
    String tempDataIdCart = prefs.getString('dataBerita')!;
    dataNews = json.decode(tempDataIdCart);
    datePublish = getCustomFormattedDateTime(
        dataNews[0]['created_at'], 'EEE, dd MMMM yyyy hh:mm a');
    getItem();
    getGeneralItem();
    setState(() {
      isLoading = false;
    });
  }

  getCustomFormattedDateTime(String givenDateTime, String dateFormat) {
    final DateTime docDateTime = DateTime.parse(givenDateTime).toLocal();
    return DateFormat(dateFormat, 'id').format(docDateTime);
  }

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        floatingActionButton: FloatingActionButton.small(
          backgroundColor: HexColor("2C3246"),
          child: Container(
              margin: EdgeInsets.only(top: 3), child: const Icon(Icons.close)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Stack(
              children: [
                Image.network(
                    !isLoading
                        ? dataNews[0]['image']['path'].toString()
                        : 'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.5),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 350.0, 0.0, 0.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Material(
                      shadowColor: Colors.black,
                      borderRadius: BorderRadius.circular(35),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                20.0, 20.0, 20.0, 20.0),
                            child: Text(
                              !isLoading ? dataNews[0]['title'] : '',
                              style: const TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              !isLoading ? datePublish : ''.substring(0, 10),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              !isLoading ? dataNews[0]['author'] : '',
                              style: const TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              !isLoading ? dataNews[0]['description'] : '',
                              style: const TextStyle(
                                fontSize: 25.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.39,
                  right: MediaQuery.of(context).size.height * 0.03,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.zero,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(color: Colors.black)
                              ]),
                          child: IconButton(
                            icon: Icon(
                              dataNews[0]['has_like']
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: dataNews[0]['has_like']
                                  ? Colors.red
                                  : HexColor("2C3246"),
                            ),
                            onPressed: () {
                              setState(() {
                                likeManagement(
                                    dataNews[0]['id'], dataNews[0]['has_like']);
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Padding(
                        padding: EdgeInsets.zero,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(color: Colors.black)
                              ]),
                          child: IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () {
                              share();
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
