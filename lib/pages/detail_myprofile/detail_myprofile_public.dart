import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/auth/authlogin.dart';
import 'package:herbal/pages/edit_profile/edit_name.dart';
import 'package:herbal/pages/edit_profile/edit_phone.dart';
import 'package:herbal/shared/shared.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class MyDetailProfilePublic extends StatefulWidget {
  const MyDetailProfilePublic({Key? key}) : super(key: key);

  @override
  MyDetailProfilePublicState createState() => MyDetailProfilePublicState();
}

class MyDetailProfilePublicState extends State<MyDetailProfilePublic> {
  double windowHeight = 0;
  double windowWidth = 0;
  String token = '';
  bool isLoading = true;
  var tempData = [];
  final picker = ImagePicker();
  late File _img;
  Uint8List? imageTemp;
  String baseImage = "";
  @override
  void initState() {
    super.initState();
    initiateData();
  }

  initiateData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token').toString();
    await getItem();
  }

  getItem() async {
    setState(() {
      isLoading = true;
    });
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

    setState(() {
      isLoading = false;
    });
  }

  addImage() async {
    setState(() {
      isLoading = true;
    });
    await ApiServices().addImageProfileUser(token, baseImage).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          setState(() {
            tempData.add(json['data']);
          });
          initiateData();
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
    setState(() {
      isLoading = false;
    });
  }

  addImageProfile() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.SCALE,
      headerAnimationLoop: false,
      body: Column(
        children: <Widget>[
          Align(
            alignment: Alignment(0, 1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                imageTemp != null
                    ? Image.memory(
                        imageTemp!,
                        height: 200,
                      )
                    : const CircleAvatar(
                        backgroundColor: Colors.black38,
                        backgroundImage: null,
                        radius: 100.0,
                      ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.center,
            // ignore: sized_box_for_whitespace
            child: Container(
              width: MediaQuery.of(context).size.width * 0.3,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: HexColor("2C3246"),
                  onPrimary: HexColor("2C3246"),
                  onSurface: HexColor("2C3246"),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  popUpCamera();
                },
                child: Container(
                  alignment: Alignment.center,
                  // ignore: avoid_unnecessary_containers
                  child: Container(
                    child: Row(
                      children: const <Widget>[
                        Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Tambah",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      btnOkColor: Colors.green,
      btnOkText: "Upload Gambar Profile",
      btnOkOnPress: () {
        addImage();
      },
    ).show();
  }

  popUpCamera() {
    // ignore: avoid_single_cascade_in_expression_statements
    AwesomeDialog(
        context: context,
        dialogType: DialogType.WARNING,
        animType: AnimType.SCALE,
        headerAnimationLoop: false,
        title: '',
        desc: 'Pilih gambar',
        btnOkOnPress: () {
          fromCamera('camera');
        },
        btnCancelOnPress: () {
          fromCamera('galeri');
        },
        btnOkText: 'Camera',
        btnCancelText: 'File',
        btnOkIcon: Icons.camera,
        btnCancelIcon: Icons.file_upload,
        btnCancelColor: HexColor("2C3246"),
        btnOkColor: Colors.red)
      ..show();
  }

  fromCamera(value) async {
    var result;
    if (value == 'camera') {
      result = _takePic(ImageSource.camera);
    } else {
      result = _takePic(ImageSource.gallery);
    }
  }

  Future<void> _takePic(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source, maxWidth: 600);
    if (pickedFile != null) {
      baseImage = "";
      _img = File(pickedFile.path);
      List<int> imageBytes = _img.readAsBytesSync();
      String _img64 = base64Encode(imageBytes);
      imageTemp = const Base64Decoder().convert(_img64);
      baseImage = "data:image/png;base64," + _img64;
      addImageProfile();
    }
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

  changeName() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('edit_name', 'public');

    Navigator.push(context,
            MaterialPageRoute(builder: (context) => const EditProfileName()))
        .then((value) => initiateData());
  }

  changePhone() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('edit_phone', 'public');

    Navigator.push(context,
            MaterialPageRoute(builder: (context) => const EditProfilePhone()))
        .then((value) => initiateData());
  }

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          title: const Text("Data Diri",
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.black,
                fontSize: 18,
              )),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Align(
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Image.network(
                              !isLoading
                                  ? tempData[0]['image']['name'] ==
                                          "default.jpg"
                                      ? 'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg'
                                      : tempData[0]['image']['path'].toString()
                                  : 'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                              width: 100,
                              height: 100),
                        ),
                        Positioned(
                          bottom: -3,
                          right: -5,
                          child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                addImageProfile();
                              },
                              child: Card(
                                shape: BeveledRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                elevation: 8,
                                shadowColor: Colors.black,
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white),
                                    width: windowWidth * 0.1,
                                    height: windowWidth * 0.1,
                                    child: Icon(Icons.edit_outlined)),
                              )),
                        )
                      ],
                    ),
                  )),
              Expanded(
                  flex: 1,
                  child: Container(
                      margin: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text("Nama",
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  color: Colors.black54,
                                  fontSize: 20)),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                    !isLoading ? tempData[0]['name'] : '-',
                                    style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        color: Colors.black54,
                                        fontSize: 17)),
                              ),
                              SizedBox(
                                width: windowWidth * 0.02,
                              ),
                              TextButton(
                                onPressed: () => changeName(),
                                child: const Text("Ubah",
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 17,
                                    )),
                                style: ButtonStyle(
                                  alignment: Alignment
                                      .centerLeft, // <-- had to set alignment
                                  padding: MaterialStateProperty.all<
                                      EdgeInsetsGeometry>(
                                    const EdgeInsets.all(
                                        0), // <-- had to set padding to 0
                                  ),
                                ),
                              )
                            ],
                          ),
                          const Text("Nomor Telepon",
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  color: Colors.black54,
                                  fontSize: 20)),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                    !isLoading
                                        ? tempData[0]['no_telephone'].toString()
                                        : "-",
                                    style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        color: Colors.black54,
                                        fontSize: 17)),
                              ),
                              SizedBox(
                                width: windowWidth * 0.02,
                              ),
                              TextButton(
                                onPressed: () => changePhone(),
                                child: const Text("Ubah",
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 17,
                                    )),
                                style: ButtonStyle(
                                  alignment: Alignment
                                      .centerLeft, // <-- had to set alignment
                                  padding: MaterialStateProperty.all<
                                      EdgeInsetsGeometry>(
                                    const EdgeInsets.all(
                                        0), // <-- had to set padding to 0
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: windowWidth * 0.02,
                          ),
                          const Text("Email",
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  color: Colors.black54,
                                  fontSize: 17)),
                          SizedBox(
                            height: windowHeight * 0.01,
                          ),
                          Text(
                              !isLoading
                                  ? tempData[0]['email'].toString()
                                  : "-",
                              style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  color: Colors.black54,
                                  fontSize: 20)),
                        ],
                      ))),
            ],
          ),
        ));
  }
}
