// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:herbal/api/api_services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ApotekAdminList extends StatefulWidget {
  const ApotekAdminList({Key? key}) : super(key: key);

  @override
  ApotekAdminListState createState() => ApotekAdminListState();
}

class ApotekAdminListState extends State<ApotekAdminList> {
  TextEditingController name = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController linkAddress = TextEditingController();
  late File imageFile;
  late Uint8List imageTemp;
  late String baseImage;
  final ImagePicker _picker = ImagePicker();
  List<dynamic> tempPop = [];
  double windowHeight = 0;
  double windowWidth = 0;
  int id = 0;
  int idUpdate = 0;
  bool cropProses = false;
  String token = '';
  var tempData = [];
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
    await ApiServices().getApotekAdmin(token).then((json) {
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
    setState(() {
      isLoading = false;
    });
  }

  createItem() async {
    setState(() {
      isLoading = true;
    });
    await ApiServices()
        .addApotek(token, name.text, city.text, linkAddress.text)
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
        .updateApotek(
            token, idUpdate.toString(), name.text, city.text, linkAddress.text)
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
    await ApiServices().deleteApotek(token, idUpdate.toString()).then((json) {
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

  updateData() async {
    name.text = tempData[id]['name'].toString();
    city.text = tempData[id]['city'].toString();
    linkAddress.text = tempData[id]['link_address'].toString();
    AwesomeDialog(
      context: context,
      onDissmissCallback: (type) {
        name.text = "";
        city.text = "";
        linkAddress.text = "";
      },
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.SCALE,
      headerAnimationLoop: false,
      body: Column(
        children: <Widget>[
          TextField(
            controller: name,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
                icon: Icon(Icons.account_box_rounded),
                labelText: "Apotek Name"),
          ),
          TextField(
            controller: city,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              icon: Icon(Icons.location_city),
              labelText: "City",
            ),
          ),
          TextField(
            controller: linkAddress,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              icon: Icon(Icons.link),
              labelText: "Link Address",
            ),
          ),
        ],
      ),
      btnOk: DialogButton(
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

  addData() async {
    name.text = "";
    city.text = "";
    linkAddress.text = "";
    AwesomeDialog(
      context: context,
      onDissmissCallback: (type) {
        name.text = "";
        city.text = "";
        linkAddress.text = "";
      },
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.SCALE,
      headerAnimationLoop: false,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: name,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  icon: Icon(Icons.account_box_rounded),
                  labelText: "Apotek Name"),
            ),
            TextField(
              controller: city,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                icon: Icon(Icons.location_city),
                labelText: "City",
              ),
            ),
            TextField(
              controller: linkAddress,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                icon: Icon(Icons.link),
                labelText: "Link Address",
              ),
            ),
          ],
        ),
      ),
      btnOk: DialogButton(
        color: HexColor("#2C3246"),
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
          backgroundColor: HexColor("2C3246"),
          child: Icon(Icons.add),
          onPressed: (){
            addData();
          },
        ),
        appBar: AppBar(
          backgroundColor: HexColor("2C3246"),
          title: const Text("Apotek"),
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
                              physics: const AlwaysScrollableScrollPhysics(),
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
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.black12,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 7,
                                                        horizontal: 10),
                                                child: Row(children: [
                                                  Expanded(
                                                      flex: 4,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 10),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                tempData[index]
                                                                        ['name']
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
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .none)),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text(
                                                                tempData[index]
                                                                        ['city']
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
                                                          ],
                                                        ),
                                                      )),
                                                  Expanded(
                                                      flex: 1,
                                                      child: ElevatedButton(
                                                          child: const Align(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            child: Icon(
                                                                Icons.delete, color: Colors.white,),
                                                          ),
                                                           style: ElevatedButton
                                                              .styleFrom(
                                                            primary: HexColor(
                                                                "2C3246"),
                                                            onPrimary: HexColor(
                                                                "2C3246"),
                                                            onSurface: HexColor(
                                                                "2C3246"),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20.0)),
                                                          ),
                                                          onPressed: () => {
                                                                setState(() {
                                                                  id = index;
                                                                  idUpdate =
                                                                      tempData[
                                                                              index]
                                                                          [
                                                                          'id'];
                                                                }),
                                                                deleteAlert(
                                                                    index)
                                                              })),
                                                  SizedBox(
                                                    width: windowWidth * 0.02,
                                                  ),
                                                  // Expanded(
                                                  //     flex: 1,
                                                  //     child: ElevatedButton(
                                                  //         child: const Align(
                                                  //           alignment: Alignment
                                                  //               .center,
                                                  //           child: Icon(
                                                  //               Icons.edit),
                                                  //         ),
                                                  //         style: ButtonStyle(
                                                  //             shape: MaterialStateProperty.all<
                                                  //                     RoundedRectangleBorder>(
                                                  //                 RoundedRectangleBorder(
                                                  //           borderRadius:
                                                  //               BorderRadius
                                                  //                   .circular(
                                                  //                       18.0),
                                                  //         ))),
                                                  //         onPressed: () => {
                                                  //               setState(() {
                                                  //                 id = index;
                                                  //                 idUpdate =
                                                  //                     tempData[
                                                  //                             index]
                                                  //                         [
                                                  //                         'id'];
                                                  //               }),
                                                  //               updateData()
                                                  //             })),
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
                                //       onPressed: () => {addData()},
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
                                //                 const Text("Tambah List Apotek")
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
