import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/newspaper_details/newspaper_details_public.dart';
import 'package:herbal/shared/shared.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadProof extends StatefulWidget {
  const UploadProof({Key? key}) : super(key: key);

  @override
  UploadProofState createState() => UploadProofState();
}

class UploadProofState extends State<UploadProof> {
  double windowHeight = 0;
  double windowWidth = 0;
  String token = "";
  var tempData = null;
  final picker = ImagePicker();
  late File _img;
  bool isloading = true;
  Uint8List? imageTemp;
  var generalData = [];
  String baseImage = "";
  bool loadingUplaod = false;
  @override
  void initState() {
    super.initState();
    initiateData();
  }

  initiateData() async {
    await getGeneralItem();

    setState(() {
      isloading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token').toString();
    if (prefs.getString('dataUploadProof') != "") {
      String tempCart = prefs.getString('dataUploadProof')!;
      var dataDecode = json.decode(tempCart);
      tempData = dataDecode;
    }
    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;

    setState(() {
      isloading = false;
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

  createItem() async {
    setState(() {
      loadingUplaod = true;
    });
    final prefs = await SharedPreferences.getInstance();
    await ApiServices()
        .uploadTransaction(token, tempData['id'], baseImage)
        .then((json) {
      if (json != null) {
        if (json['status'] == "success") {
          setState(() {
            loadingUplaod = false;
          });
          Navigator.pop(context);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
      setState(() {
        loadingUplaod = false;
      });
    });
  }

  uplaodBuktiTF() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.SCALE,
      headerAnimationLoop: false,
      title: 'Warning',
      desc: "Anda yakin ingin menghapus data?",
      body: Column(
        children: <Widget>[
          Align(
            alignment: const Alignment(0, 1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                imageTemp != null
                    ? Image.memory(
                        imageTemp!,
                        height: 200,
                      )
                    : Container(
                        color: Colors.black38,
                        width: 200,
                        height: 200,
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
      btnOkText: !loadingUplaod ? "Upload Bukti" : "Loading...",
      btnOkOnPress: () async {
        !loadingUplaod ? createItem() : null;
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
    }
    uplaodBuktiTF();
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
                  decoration: const BoxDecoration(
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
                        children: [
                          Text(
                              !isloading
                                  ? "Silahkan Bayar sejumlah Rp " +
                                      tempData['data_cart']['total']
                                          .toString() +
                                      " sebelum tanggal " +
                                      tempData['expired_at'].toString() +
                                      "."
                                  : '',
                              style: const TextStyle(fontSize: 15)),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: <Widget>[
                              Icon(Icons.account_balance),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                isloading
                                    ? ""
                                    : generalData[0]['bank_credential']
                                            ['bank_name']
                                        .toString(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: <Widget>[
                              Icon(Icons.account_balance_wallet_rounded),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                isloading
                                    ? ""
                                    : generalData[0]['bank_credential']
                                            ['account_number']
                                        .toString(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: <Widget>[
                              Icon(Icons.account_box),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                isloading
                                    ? ""
                                    : generalData[0]['bank_credential']
                                            ['account_name']
                                        .toString(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                              !isloading
                                  ? tempData['proof'] != null
                                      ? 'Pesanan Anda masih di proses oleh admin'
                                      : ''
                                  : '',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: !isloading
                                      ? tempData['proof'] != null
                                          ? Colors.green
                                          : Colors.black
                                      : Colors.black)),
                          const SizedBox(
                            height: 20,
                          ),
                          // ignore: sized_box_for_whitespace
                          Container(
                            width: double.infinity,
                            // ignore: deprecated_member_use
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              onPressed: () {
                                !isloading
                                    ? tempData['proof'] != null
                                        ? null
                                        : uplaodBuktiTF()
                                    : null;
                              },
                              child: const Text('Upload Bukti Transfer',
                                  style: TextStyle(fontSize: 15)),
                              color: !isloading
                                  ? tempData['proof'] != null
                                      ? Colors.grey
                                      : HexColor("2C3246")
                                  : HexColor("2C3246"),
                              textColor: Colors.white,
                              elevation: 5,
                            ),
                          ),
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
