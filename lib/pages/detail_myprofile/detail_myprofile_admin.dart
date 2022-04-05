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
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class MyDetailProfileAdmin extends StatefulWidget {
  const MyDetailProfileAdmin({Key? key}) : super(key: key);

  @override
  MyDetailProfileAdminState createState() => MyDetailProfileAdminState();
}

class MyDetailProfileAdminState extends State<MyDetailProfileAdmin> {
  double windowHeight = 0;
  double windowWidth = 0;
  String token = '';
  bool isLoading = true;
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

  changeName() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('edit_name', 'admin');

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const EditProfileName()));
  }

  changePhone() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('edit_phone', 'admin');

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const EditProfilePhone()));
  }

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
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
              : Stack(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 20),
                            child: Align(
                              alignment: Alignment.center,
                              child: Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        child: Image.asset(
                                          'assets/images/herbal.png',
                                          width: 100,
                                          height: 100,
                                        )),
                                  ),
                                  Positioned(
                                    bottom: -3,
                                    right: -5,
                                    child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () {
                                          print('ubah gambar');
                                        },
                                        child: Card(
                                          shape: BeveledRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          elevation: 8,
                                          shadowColor: Colors.black,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Colors.white),
                                              width: windowWidth * 0.1,
                                              height: windowWidth * 0.1,
                                              child: const Icon(
                                                  Icons.edit_outlined)),
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
                                        const Expanded(
                                          flex: 1,
                                          child: Text("Paulus Agata S",
                                              style: TextStyle(
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
                                        const Expanded(
                                          flex: 1,
                                          child: Text("0851234567890",
                                              style: TextStyle(
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
                                    const Text("Jenis Kelamin",
                                        style: TextStyle(
                                            fontFamily: 'Nunito',
                                            color: Colors.black54,
                                            fontSize: 20)),
                                    SizedBox(
                                      height: windowWidth * 0.02,
                                    ),
                                    const Text("Laki - laki",
                                        style: TextStyle(
                                            fontFamily: 'Nunito',
                                            color: Colors.black54,
                                            fontSize: 17)),
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
                                    const Text("paul@gmail.com",
                                        style: TextStyle(
                                            fontFamily: 'Nunito',
                                            color: Colors.black54,
                                            fontSize: 20)),
                                  ],
                                ))),
                      ],
                    ),
                  ],
                ),
        ));
  }
}
