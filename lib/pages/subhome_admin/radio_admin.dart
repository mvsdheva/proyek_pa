// ignore_for_file: unused_import, unnecessary_null_comparison, prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:herbal/api/api_services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class RadioAdminList extends StatefulWidget {
  const RadioAdminList({Key? key}) : super(key: key);

  @override
  RadioAdminListState createState() => RadioAdminListState();
}

class RadioAdminListState extends State<RadioAdminList> {
  TextEditingController radioName = TextEditingController();
  TextEditingController linkStream = TextEditingController();
  TextEditingController channel = TextEditingController();
  late File imageFile;
  Uint8List? imageTemp;
  String baseImage = "";
  List<dynamic> tempPop = [];
  double windowHeight = 0;
  double windowWidth = 0;
  int id = 0;
  int idUpdate = 0;
  bool cropProses = false;
  String token = '';
  var tempData = [];
  bool isLoading = true;
  late File _img;
  final picker = ImagePicker();
  bool edited = false;
  bool addImage = false;
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
    await ApiServices().getRadioAdmin(token).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          setState(() {
            tempData = json['data']['data'];
            print(tempData = json['data']['data']);
          });
        } else {
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
    print(tempData);
    setState(() {
      isLoading = false;
    });
  }

  createItem() async {
    setState(() {
      isLoading = true;
    });
    await ApiServices()
        .addRadio(
            token, radioName.text, linkStream.text, channel.text, baseImage)
        .then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          getItem();
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
    setState(() {
      isLoading = false;
    });
  }

  updateItem(index) async {
    setState(() {
      isLoading = true;
    });
    await ApiServices()
        .updateRadio(token, idUpdate.toString(), radioName.text,
            linkStream.text, channel.text, baseImage)
        .then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          getItem();
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
    setState(() {
      isLoading = false;
    });
  }

  deleteItem(index) async {
    setState(() {
      isLoading = true;
    });
    await ApiServices().deleteRadio(token, idUpdate.toString()).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          getItem();
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

  deleteAlert(int index) {
    AwesomeDialog(
            context: context,
            dialogType: DialogType.WARNING,
            animType: AnimType.SCALE,
            headerAnimationLoop: false,
            title: 'Warning',
            desc: "Anda yakin ingin menghapus data?",
            btnOkOnPress: () {
              deleteItem(index);
            },
            btnOkIcon: Icons.check,
            btnOkColor: Colors.red,
            btnCancelColor: HexColor("2C3246"),
            btnCancelIcon: Icons.cancel,
            btnCancelOnPress: () {})
        .show();
  }

  Future<String?> networkImageToBase64(String imageUrl) async {
    http.Response response = await http.get(Uri.parse(imageUrl));
    final bytes = response.bodyBytes;
    return (bytes != null ? base64Encode(bytes) : null);
  }

  updateData() async {
    radioName.text = tempData[id]['name'].toString();
    linkStream.text = tempData[id]['link_stream'].toString();
    channel.text = tempData[id]['channel'].toString();
    if (baseImage == "") {
      final imgBase64Str =
          await networkImageToBase64(tempData[id]['image']['path'].toString());
      baseImage = "data:image/png;base64," + imgBase64Str.toString();
    }
    AwesomeDialog(
      context: context,
      onDissmissCallback: (type) {
        radioName.text = "";
        linkStream.text = "";
        channel.text = "";
      },
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.SCALE,
      headerAnimationLoop: false,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            Align(
              alignment: const Alignment(0, 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 55,
                      child: Hero(
                          tag: "pp",
                          child: imageTemp != null
                              ? CircleAvatar(
                                  backgroundColor: Colors.black38,
                                  backgroundImage: MemoryImage(imageTemp!),
                                  radius: 100.0,
                                )
                              : Image.network(
                                  tempData[id]['image']['path'].toString(),
                                  width: 200))),
                ],
              ),
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
            TextField(
              controller: radioName,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  icon: Icon(Icons.account_box), labelText: "Nama Radio"),
            ),
            TextField(
              controller: linkStream,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                icon: Icon(Icons.radio),
                labelText: "Link Steaming",
              ),
            ),
            TextField(
              controller: channel,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                icon: Icon(Icons.link),
                labelText: "Channel",
              ),
            ),
          ],
        ),
      ),
      btnOk: DialogButton(
        color:  HexColor("2C3246"),
        onPressed: () => {
          updateItem(idUpdate.toString()),
          Navigator.pop(context),
        },
        child: const Text(
          "Simpan Data",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      btnOkOnPress: () {},
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
    if (edited) {
      updateData();
    } else {
      addData();
    }
  }

  addData() async {
    radioName.text = "";
    linkStream.text = "";
    channel.text = "";
    if (addImage = false) {
      imageTemp = null;
    }
    AwesomeDialog(
      context: context,
      onDissmissCallback: (type) {
        radioName.text = "";
        linkStream.text = "";
        addImage = false;
        imageTemp = null;
      },
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.SCALE,
      headerAnimationLoop: false,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            Align(
              alignment: const Alignment(0, 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 55,
                      child: Hero(
                          tag: "pp",
                          child: imageTemp != null
                              ? CircleAvatar(
                                  backgroundColor: Colors.black38,
                                  backgroundImage: MemoryImage(imageTemp!),
                                  radius: 100.0,
                                )
                              : const CircleAvatar(
                                  backgroundColor: Colors.black38,
                                  backgroundImage: null,
                                  radius: 100.0,
                                )))
                ],
              ),
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
                    setState(() {
                      addImage = true;
                    });
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
            TextField(
              controller: radioName,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  icon: Icon(Icons.account_box), labelText: "Nama Radio"),
            ),
            TextField(
              controller: linkStream,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                icon: Icon(Icons.radio),
                labelText: "Link Stream",
              ),
            ),
            TextField(
              controller: channel,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                icon: Icon(Icons.link),
                labelText: "Channel",
              ),
            ),
          ],
        ),
      ),
      btnOk: DialogButton(
        color: HexColor("2C3246"),
        onPressed: () => {
          createItem(),
          Navigator.pop(context),
        },
        child: const Text(
          "Tambah Data",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                edited = false;
              });
              addData();
            },
            backgroundColor: HexColor("2C3246"),
            child: Icon(Icons.add)),
        appBar: AppBar(
          backgroundColor: HexColor("2C3246"),
          title: const Text("Radio"),
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
                    width: double.infinity,
                    child: Column(children: [
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
                    // ignore: unrelated_type_equality_checks
                    tempData.length == 0
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                  child: SvgPicture.asset(
                                'assets/images/empty.svg',
                                height: 150,
                              )),
                              SizedBox(height: 20,),
                              Center(child: Text("Data Kosong"))
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: ListView(
                                    scrollDirection: Axis.vertical,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.all(5.0),
                                    children: <Widget>[
                                      Container(
                                          margin: const EdgeInsets.all(2),
                                          alignment: Alignment.topCenter,
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                for (int index = 0;
                                                    index < tempData.length;
                                                    index++)
                                                  Container(
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 5,
                                                        vertical: 5),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.black12,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 7,
                                                          horizontal: 10),
                                                      child: Row(children: [
                                                        Expanded(
                                                            flex: 4,
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10),
                                                              child: Text(
                                                                  tempData[index][
                                                                          'name']
                                                                      .toString(),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: const TextStyle(
                                                                      fontFamily:
                                                                          'Nunito',
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      decoration:
                                                                          TextDecoration
                                                                              .none)),
                                                            )),
                                                        Expanded(
                                                            flex: 1,
                                                            child:
                                                                ElevatedButton(
                                                                    child:
                                                                        const Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .bottomCenter,
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .delete,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      primary:
                                                                          HexColor(
                                                                              "2C3246"),
                                                                      onPrimary:
                                                                          HexColor(
                                                                              "2C3246"),
                                                                      onSurface:
                                                                          HexColor(
                                                                              "2C3246"),
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(20.0)),
                                                                    ),
                                                                    onPressed:
                                                                        () => {
                                                                              setState(() {
                                                                                id = index;
                                                                                idUpdate = tempData[index]['id'];
                                                                              }),
                                                                              deleteAlert(index)
                                                                            })),
                                                        SizedBox(
                                                          width: windowWidth *
                                                              0.02,
                                                        ),
                                                        Expanded(
                                                            flex: 1,
                                                            child:
                                                                ElevatedButton(
                                                                    child:
                                                                        const Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      child: Icon(
                                                                          Icons
                                                                              .edit,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      primary:
                                                                          HexColor(
                                                                              "2C3246"),
                                                                      onPrimary:
                                                                          HexColor(
                                                                              "2C3246"),
                                                                      onSurface:
                                                                          HexColor(
                                                                              "2C3246"),
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(20.0)),
                                                                    ),
                                                                    onPressed:
                                                                        () => {
                                                                              setState(() {
                                                                                id = index;
                                                                                idUpdate = tempData[index]['id'];
                                                                              }),
                                                                              updateData()
                                                                            })),
                                                      ]),
                                                    ),
                                                  ),
                                              ])),
                                      SizedBox(
                                        height: windowHeight * 0.02,
                                      ),
                                      // Container(
                                      //   margin: const EdgeInsets.symmetric(
                                      //       horizontal: 15),
                                      //   child: ElevatedButton(
                                      //       onPressed: () => {

                                      //           },
                                      //       child: Padding(
                                      //           padding: const EdgeInsets.all(10),
                                      //           // ignore: sized_box_for_whitespace
                                      //           child: Container(
                                      //             width: windowWidth * 0.8,
                                      //             child: Column(
                                      //               children: <Widget>[
                                      //                 const Icon(
                                      //                   Icons.add,
                                      //                   size: 25,
                                      //                 ),
                                      //                 SizedBox(
                                      //                   height: windowHeight * 0.01,
                                      //                 ),
                                      //                 const Text("Tambah List Radio")
                                      //               ],
                                      //             ),
                                      //           ))),
                                      // ),
                                    ],
                                  ),
                                )
                              ]),
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
                ),
        ));
  }
}
