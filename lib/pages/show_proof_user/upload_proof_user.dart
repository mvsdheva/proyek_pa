import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/list_transaction/list_transaction_admin.dart';
import 'package:herbal/pages/newspaper_details/newspaper_details_public.dart';
import 'package:herbal/shared/shared.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadProofUser extends StatefulWidget {
  const UploadProofUser({Key? key}) : super(key: key);

  @override
  UploadProofUserState createState() => UploadProofUserState();
}

class UploadProofUserState extends State<UploadProofUser> {
  double windowHeight = 0;
  double windowWidth = 0;
  String token = "";
  var tempData = null;
  final picker = ImagePicker();
  late File _img;
  bool isloading = true;
  Uint8List? imageTemp;
  String baseImage = "";
  @override
  void initState() {
    super.initState();
    initiateData();
  }

  initiateData() async {
    setState(() {
      isloading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token').toString();
    if (prefs.getString('dataUploadProofUser') != "") {
      String tempCart = prefs.getString('dataUploadProofUser')!;
      var dataDecode = json.decode(tempCart);
      tempData = dataDecode;
    }
    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;

    setState(() {
      isloading = false;
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

  createItem(status) async {
    await ApiServices()
        .switchStatusTransaction(token, tempData['id'], status.toString())
        .then((json) {
      if (json != null) {
        if (json['status'] == "success") {
          Navigator.pop(context);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor("2C3246"),
        title: const Text("Detail Transaksi"),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    color: Colors.black12,
                  ),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                              "Anda dapat mengubah status transaksi dengan menyetujui, membatalkan, atau pending pesanan.",
                              style: TextStyle(fontSize: 15)),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("Profile User",
                              style: TextStyle(
                                fontSize: 18,
                              )),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              const Icon(Icons.account_circle_outlined),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                  !isloading
                                      ? tempData['data_user']['name']
                                      : "",
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.red)),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.email_outlined),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                  !isloading
                                      ? tempData['data_user']['email']
                                      : "",
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.red)),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Column(
                            children: [
                              !isloading
                                  ? Image.network(
                                      tempData['proof'] != null
                                          ? tempData['proof'].toString()
                                          : 'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                                      width: windowWidth * 0.8,
                                      height: windowHeight * 0.5,
                                      fit: BoxFit.contain,
                                    )
                                  : const CircleAvatar(
                                      backgroundColor: Colors.black38,
                                      backgroundImage: null,
                                      radius: 100.0,
                                    ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                width: double.infinity,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      onPressed: () {
                                        createItem(0);
                                      },
                                      child: const Text('Pending',
                                          style: TextStyle(fontSize: 15)),
                                      color: HexColor("2C3246"),
                                      textColor: Colors.white,
                                      elevation: 5,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      onPressed: () {
                                        createItem(1);
                                      },
                                      child: const Text('Setujui',
                                          style: TextStyle(fontSize: 15)),
                                      color: Colors.green,
                                      textColor: Colors.white,
                                      elevation: 5,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      onPressed: () {
                                        createItem(3);
                                      },
                                      child: const Text('Batalkan',
                                          style: TextStyle(fontSize: 15)),
                                      color: Colors.red,
                                      textColor: Colors.white,
                                      elevation: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
