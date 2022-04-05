import 'dart:async';
import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_radio/flutter_radio.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/auth/authlogin.dart';
import 'package:herbal/pages/radio_details/playing_status.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RadioDetailsPublic extends StatefulWidget {
  const RadioDetailsPublic({Key? key}) : super(key: key);

  @override
  RadioDetailsPublicState createState() => RadioDetailsPublicState();
}

class RadioDetailsPublicState extends State<RadioDetailsPublic> {
  double windowHeight = 0;
  double windowWidth = 0;
  var pathUrl = [];
  bool isLoading = true;
  late bool isPlay;
  PlayingStatus playingStatus = PlayingStatus();
  Future<void>? _launched;
  String token = '';
  var tempData = [];
  int id = 0;

  @override
  void initState() {
    super.initState();
    initiateData();
    isPlay = playingStatus.isPlaying;
    audioStart();
  }

  @override
  void dispose() async {
    super.dispose();
    bool isPlayingRadio = await FlutterRadio.isPlaying();
    if (isPlayingRadio) {
      FlutterRadio.stop();
    }
  }

  Future<void> _launchInWebViewOrVC(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        universalLinksOnly: true,
      );
    }
  }

  Future<void> audioStart() async {
    await FlutterRadio.audioStart();
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
          setState(() {});
        } else {
          alertError(json.toString(), 1);
          print(alertError(json.toString(), 1));
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
          setState(() {});
        } else {
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
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

  initiateData() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') != null) {
      token = prefs.getString('token').toString();
    }
    if (prefs.getString('streamingRadio') != "") {
      pathUrl.add(jsonDecode(prefs.getString('streamingRadio')!));
    }
    getItem();
    getGeneralItem();
    setState(() {
      isLoading = false;
    });
  }

  getItem() async {
    await ApiServices().getItemsPublic(token, id.toString(), "").then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          tempData.clear();
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

  Future<void> share() async {
    await FlutterShare.share(
        title: 'Dapatkan Aplikasi',
        text:
            'Dapatkan aplikasi BSK Media App dengan mengunduh link yang tersedia',
        linkUrl: 'https://flutter.dev/',
        chooserTitle: 'aaaaaa');
  }

  @override
  Widget build(BuildContext context) {
    const String igUrl = 'https://www.instagram.com/bsk.radionetwork/';
    const String fbUrl = 'https://www.facebook.com/bskgroupsamarinda/';
    const String webUrl = 'https://bskmedia.co.id/';
    const String youtubeUrl =
        'https://www.youtube.com/channel/UCp-_MIm95m3U-dE_lXl5ekw';
    const String twitcheUrl = 'https://www.twitch.tv/bskmedia';
    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
            backgroundColor: HexColor("2C3246"),
            title: const Text("Play Radio")),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < pathUrl.length; i++)
                SizedBox(
                  height: windowHeight * 0.04,
                ),
              Expanded(
                  flex: 1,
                  child: Align(
                      alignment: Alignment.center,
                      child: Image.network(
                        !isLoading
                            ? pathUrl[0]['image']['name'] == "default.jpg"
                                ? "'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg'"
                                : pathUrl[0]['image']['path'].toString()
                            : 'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                        width: windowWidth * 0.8,
                        height: windowWidth * 0.8,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                            width: 50,
                            height: 50,
                          );
                        },
                      ))),
              SizedBox(
                height: windowHeight * 0.04,
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(!isLoading ? pathUrl[0]['name'] : '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              color: Colors.black54,
                              fontSize: 15)),
                      SizedBox(
                        height: windowHeight * 0.01,
                      ),
                      Text(
                          !isLoading
                              ? pathUrl[0]['channel']
                              : 'saluran radio (109.0 fm)',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              color: Colors.black54,
                              fontSize: 15)),
                      SizedBox(
                        height: windowHeight * 0.01,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () {
                              share();
                            },
                            icon: const Icon(Icons.share),
                          ),
                          // ignore: prefer_const_constructors
                          IconButton(
                            iconSize: 40,
                            onPressed: () async {
                              print(pathUrl[0]['link_stream']);
                              FlutterRadio.playOrPause(
                                  url: pathUrl[0]['link_stream']);
                              setState(() {
                                isPlay
                                    ? playingStatus.isPlaying = false
                                    : playingStatus.isPlaying = true;
                                isPlay = playingStatus.isPlaying;
                              });
                            },
                            icon: Icon(
                              isPlay
                                  ? Icons.pause_circle_outline
                                  : Icons.play_circle_outline,
                              size: 40,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                likeManagement(
                                    pathUrl[0]['id'], pathUrl[0]['has_like']);
                              });
                            },
                            icon: Icon(
                              pathUrl[0]['has_like']
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: pathUrl[0]['has_like']
                                  ? Colors.red
                                  : HexColor("2C3246"),
                            ),
                            color: Colors.black,
                          ),
                          // SizedBox(
                          //   width: windowWidth * 0.05,
                          // ),
                          // IconButton(
                          //   iconSize: 40,
                          //   onPressed: () {
                          //     FlutterRadio.pause(
                          //         url: pathUrl[0]['link_stream'].toString());
                          //   },
                          //   icon: const Icon(
                          //     Icons.pause_circle_outline,
                          //     size: 40,
                          //   ),
                          // )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ));
  }
}
