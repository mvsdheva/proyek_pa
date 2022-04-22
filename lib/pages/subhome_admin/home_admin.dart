import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/subhome_admin/apotek_admin.dart';
import 'package:herbal/pages/subhome_admin/medicine_admin.dart';
import 'package:herbal/pages/subhome_admin/newspaper_list.dart';
import 'package:herbal/pages/subhome_admin/radio_admin.dart';
import 'package:herbal/shared/shared.dart';
import 'package:herbal/widgets/loading.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BerandaAdmin extends StatefulWidget {
  const BerandaAdmin({Key? key}) : super(key: key);

  @override
  BerandaAdminState createState() => BerandaAdminState();
}

class BerandaAdminState extends State<BerandaAdmin> {
  double windowHeight = 0;
  double windowWidth = 0;
  bool isLoading = false;
  String token = "";
  var obat = [];
  var news = [];
  var radio = [];
  var apotek = [];
  Future<void>? _launched;
  @override
  void initState() {
    initiateData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  initiateData() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token').toString();
    windowHeight = MediaQuery.of(context).size.height - 25;
    windowWidth = MediaQuery.of(context).size.width;
    await getItemObat();
    await getItemNews();
    await getItemRadio();
    await getItemApotek();
    setState(() {
      isLoading = false;
    });
  }

  getItemObat() async {
    await ApiServices().getItems(token, "").then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          setState(() {
            obat = json['data']['data'];
          });
        } else {
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
      setState(() {
        isLoading = false;
      });
    });
  }

  getItemNews() async {
    await ApiServices().getNewsAdmin(token).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          setState(() {
            news = json['data']['data'];
          });
        } else {
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
      setState(() {
        isLoading = false;
      });
    });
  }

  getItemRadio() async {
    await ApiServices().getRadioAdmin(token).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          setState(() {
            radio = json['data']['data'];
          });
        } else {
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
      setState(() {
        isLoading = false;
      });
    });
  }

  getItemApotek() async {
    await ApiServices().getApotekAdmin(token).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          setState(() {
            apotek = json['data']['data'];
          });
        } else {
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
      setState(() {
        isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            backgroundColor: HexColor("2C3246"),
            title: const Text("Beranda"),
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
              child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.center,
                          runSpacing: 10,
                          spacing: 10,
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              child: SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                        iconSize: 80,
                                        icon: SvgPicture.asset(
                                          'assets/images/newspaper.svg',
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const NewsPaperList()));
                                        }),
                                    Text("Berita")
                                  ],
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            Container(
                              width: 150,
                              height: 150,
                              child: SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                        iconSize: 80,
                                        icon: SvgPicture.asset(
                                          'assets/images/herbal.svg',
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const MedicineAdmin()));
                                        }),
                                    Text("Obat Herbal")
                                  ],
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            Container(
                              width: 150,
                              height: 150,
                              child: SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                      iconSize: 80,
                                      icon: SvgPicture.asset(
                                        'assets/images/apotek.svg',
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const ApotekAdminList()));
                                      },
                                    ),
                                    Text("Apotek")
                                  ],
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            Container(
                              width: 150,
                              height: 150,
                              child: SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                      iconSize: 80,
                                      icon: SvgPicture.asset(
                                        'assets/images/radio.svg',
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const RadioAdminList()));
                                      },
                                    ),
                                    Text("Radio")
                                  ],
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        //berita
                        Container(
                          padding: EdgeInsets.all(8.0),
                          margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
                          width: windowWidth,
                          height: MediaQuery.of(context).size.height * 0.13,
                          decoration: BoxDecoration(
                              color: HexColor("2C3246"),
                              borderRadius: BorderRadius.circular(10)),
                          child:  Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  child: Text('Berita',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 22,
                                          color: white,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: Text(
                                      "Jumlah Data : ${isLoading ? "0" : news.length.toString()} ",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 16, color: white)),
                                )
                              ],
                            ),
                        ),
                        SizedBox(height: 10),
                        //obat
                        Container(
                          padding: EdgeInsets.all(8.0),
                          margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
                          width: windowWidth,
                          height: MediaQuery.of(context).size.height * 0.13,
                          decoration: BoxDecoration(
                              color: HexColor("2C3246"),
                              borderRadius: BorderRadius.circular(10)),
                          child:  Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  child: Text('Obat Herbal',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 22,
                                          color: white,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: Text(
                                      "Jumlah Data : ${isLoading ? "0" : obat.length.toString()} ",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 18, color: white)),
                                )
                              ],
                            ),
                        ),
                        SizedBox(height: 10),
                        //apotek
                        Container(
                          padding: EdgeInsets.all(8.0),
                          margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
                          width: windowWidth,
                          height: MediaQuery.of(context).size.height * 0.13,
                          decoration: BoxDecoration(
                              color: HexColor("2C3246"),
                              borderRadius: BorderRadius.circular(10)),
                          child:Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  child: Text('Apotek',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 22,
                                          color: white,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: Text(
                                      "Jumlah Data : ${isLoading ? "0" : apotek.length.toString()} ",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 18, color: white)),
                                )
                              ],
                            ),
                        ),
                        SizedBox(height: 10),
                        //radio
                        Container(
                          padding: EdgeInsets.all(8.0),
                          margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
                          width: windowWidth,
                          height: MediaQuery.of(context).size.height * 0.13,
                          decoration: BoxDecoration(
                              color: HexColor("2C3246"),
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  child: Text('Radio',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 22,
                                          color: white,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: Text(
                                      "Jumlah Data : ${isLoading ? "0" : radio.length.toString()} ",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 18, color: white)),
                                )
                              ],
                            ),
                        ),
                      ],
                    ),
                  )),
            ),
          ));
  }
}
