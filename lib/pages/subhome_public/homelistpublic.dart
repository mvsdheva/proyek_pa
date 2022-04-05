import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/shared/shared.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';
// import 'package:video_player/video_player.dart';

class HomeListPublic extends StatefulWidget {
  const HomeListPublic({Key? key}) : super(key: key);

  @override
  HomeListPublicState createState() => HomeListPublicState();
}

class HomeListPublicState extends State<HomeListPublic> {
  double windowHeight = 0;
  double windowWidth = 0;
  bool isLoading = false;
  String token = "";
  // ignore: unused_field
  Future<void>? _launched;
  var generalData=[];
 
  late VideoPlayerController controller;
  late Future<void> _initializeVideoPlayerFuture;
  String streamUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

  @override
  void initState() {
    initiateData();
    controller = VideoPlayerController.network(streamUrl);
    _initializeVideoPlayerFuture = controller.initialize();
    controller.setLooping(true);
    super.initState();
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

  Future<void> _launchInWebViewOrVC(String url) async {
     
    if (await canLaunch(url)) {
      await launch(
        url,
        universalLinksOnly: true,
      );
    }
  }

  @override
  void dispose() {
    
    controller.dispose();
    super.dispose();
  }

  Future initiateData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token').toString();
  }
    var images4 = [
    'assets/images/img11.jpg',
    'assets/images/img12.jpg',
    'assets/images/img13.jpg',
  ];

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
    windowHeight = MediaQuery.of(context).size.height - 25;
    const String igUrl = 'https://www.instagram.com/bsk.radionetwork/';
    const String fbUrl = 'https://www.facebook.com/bskgroupsamarinda/';
    const String webUrl = 'https://bskmedia.co.id/';
    const String youtubeUrl =
        'https://www.youtube.com/channel/UCp-_MIm95m3U-dE_lXl5ekw';
    const String twitcheUrl = 'https://www.twitch.tv/bskmedia';
    // FlutterStatusbarcolor.setStatusBarColor(Colors.white);
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: HexColor("2C3246"),
          title: const Text("Beranda"),
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
                  bottom: false,
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 400,
                              height: 250,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: FutureBuilder(
                                future: _initializeVideoPlayerFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return AspectRatio(
                                      aspectRatio: controller.value.aspectRatio,
                                      child: VideoPlayer(controller),
                                    );
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                },
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  // If the video is playing, pause it.
                                  if (controller.value.isPlaying) {
                                    controller.pause();
                                  } else {
                                    // If the video is paused, play it.
                                    controller.play();
                                  }
                                });
                              },
                              child: Icon(
                                controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(10),
                              ),
                            ),
                            SizedBox(height: 30),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              width: 400,
                              height: 400,
                              child: Swiper(
                                itemCount: 3,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    height: 300,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image(
                                          image: AssetImage(images4[index]),
                                          fit: BoxFit.cover,
                                        )),
                                  );
                                },
                                viewportFraction: 0.8,
                                scale: 0.9,
                                autoplay: true,
                              ),
                            ),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 2.0, // gap between adjacent chips
                              runSpacing: 2.0, // gap between lines
                              children: [
                                IconButton(
                                  icon: const FaIcon(
                                    FontAwesomeIcons.instagram,
                                    color: Colors.red,
                                    size: 50,
                                  ),
                                  iconSize: 50,
                                  onPressed: () => setState(() {
                                    _launched = _launchInWebViewOrVC(igUrl);
                                  }),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                IconButton(
                                  icon: const FaIcon(
                                    FontAwesomeIcons.facebook,
                                    color: Colors.blue,
                                    size: 50,
                                  ),
                                  iconSize: 50,
                                  onPressed: () => setState(() {
                                    _launched = _launchInWebViewOrVC(fbUrl);
                                  }),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                IconButton(
                                  icon: const FaIcon(
                                    FontAwesomeIcons.youtube,
                                    color: Colors.red,
                                    size: 50,
                                  ),
                                  iconSize: 50,
                                  onPressed: () => setState(() {
                                    _launched = _launchInWebViewOrVC(youtubeUrl);
                                  }),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                IconButton(
                                  icon: const FaIcon(
                                    FontAwesomeIcons.twitch,
                                    color: Color(0xffA970FF),
                                    size: 50,
                                  ),
                                  iconSize: 50,
                                  onPressed: () => setState(() {
                                    _launched = _launchInWebViewOrVC(twitcheUrl);
                                  }),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))),
        ),floatingActionButton: FloatingActionButton.small(
          focusColor: Colors.transparent,
          child: Image.asset(
            "assets/images/wa.png",
            height: 50,
          ),
          onPressed: () => setState(() {
            _launched = _launchInWebViewOrVC(
        "https://wa.me/${generalData[0]['phone_number'].toString()}?text=Hello, Saya ingin menanyakan tentang obat herbal");
          }),
        ));
  }
}

