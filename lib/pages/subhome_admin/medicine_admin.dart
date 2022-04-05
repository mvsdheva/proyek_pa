// ignore_for_file: unused_import, prefer_typing_uninitialized_variables, unused_field, deprecated_member_use, unnecessary_null_comparison, prefer_conditional_assignment, avoid_unnecessary_containers, sized_box_for_whitespace, prefer_const_constructors, duplicate_ignore, unused_local_variable, avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:herbal/api/api_services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class MedicineAdmin extends StatefulWidget {
  const MedicineAdmin({Key? key}) : super(key: key);

  @override
  MedicineAdminState createState() => MedicineAdminState();
}

class MedicineAdminState extends State<MedicineAdmin> {
  TextEditingController namaBarang = TextEditingController();
  TextEditingController hargaBarang = TextEditingController();
  // TextEditingController unit = TextEditingController();
  TextEditingController stock = TextEditingController();
  TextEditingController deskipsi = TextEditingController();
  TextEditingController find = TextEditingController();
  var imageFile;
  Uint8List? imageTemp;
  String baseImage = "";
  final ImagePicker _picker = ImagePicker();
  List<dynamic> tempPop = [];
  double windowHeight = 0;
  double windowWidth = 0;
  bool cropProses = false;
  String token = '';
  bool edited = false;
  int id = 0;
  int idUpdate = 0;
  var tempData = [];
  var apotekList = [];
  var list_unit = [];
  bool isLoading = true;
  String pathImg = '';
  late File _img;
  final picker = ImagePicker();
  String unitChoose = '1';
  String selectApotek = '';
  @override
  void initState() {
    super.initState();
    initiateData();
  }

  initiateData() async {
    apotekList.length = 0;
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token').toString();
    await getUnits();
    await getItem();
    await getApotek();
  }

  getUnits() async {
    await ApiServices().getUnits(token).then((json) {
      if (json != null) {
        setState(() {
          list_unit = json;
        });
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
      setState(() {
        isLoading = false;
      });
    });
  }

  getItem() async {
    setState(() {
      isLoading = true;
    });
    await ApiServices().getItems(token, find.text).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          setState(() {
            tempData = json['data']['data'];
            print(tempData);
          });
          setState(() {
            isLoading = false;
          });
        } else {
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  getApotek() async {
    apotekList.add({"id": '', "name": 'Select Apotek', "link_address": ''});
    setState(() {
      isLoading = true;
    });
    await ApiServices().getApotekAdmin(token).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          for (var item in json['data']['data']) {
            apotekList.add({
              "id": item['id'],
              "name": item['name'],
              "link_address": item['link_address']
            });
          }
          setState(() {
            isLoading = false;
          });
        } else {
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  createItem() async {
    await ApiServices()
        .createItems(token, namaBarang.text, hargaBarang.text, stock.text,
            unitChoose, deskipsi.text, baseImage, selectApotek)
        .then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          getItem();
        } else {
          alertError(json, 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  updateItem(String index) async {
    await ApiServices()
        .updateItems(token, index, namaBarang.text, hargaBarang.text,
            stock.text, unitChoose, deskipsi.text, baseImage, selectApotek)
        .then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          getItem();
        } else {
          alertError(json, 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  deleteItem(String index) async {
    await ApiServices().deleteItems(token, index.toString()).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          getItem();
        } else {
          alertError(json, 1);
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
    } else {
      AlertData("No image selected.");
    }
    if (edited) {
      AlertData("Edit");
    } else {
      AlertData("");
    }
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
              deleteItem(index.toString());
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

  // ignore: non_constant_identifier_names
  AlertData(String typeAlert) async {
    if (typeAlert == "Edit") {
      if (imageTemp == null) {
        pathImg = tempData[id]['image']['path'];
      }
      if (baseImage == "") {
        final imgBase64Str = await networkImageToBase64(
            tempData[id]['image']['path'].toString());
        baseImage = "data:image/png;base64," + imgBase64Str.toString();
      }
      namaBarang.text = tempData[id]['name'].toString();
      namaBarang.text = tempData[id]['name'].toString();
      hargaBarang.text = tempData[id]['price'].toString();
      stock.text = tempData[id]['stock'].toString();
      unitChoose = tempData[id]['unit'].toString();
      deskipsi.text = tempData[id]['description'].toString();
      selectApotek = tempData[id]['apotek_id'].toString();
      edited = true;
    } else {
      if (!edited) {
        if (namaBarang.text == "") {
          namaBarang.text = "";
        }
        if (hargaBarang.text == "") {
          hargaBarang.text = "";
        }
        if (stock.text == "") {
          stock.text = "";
        }
        if (unitChoose == "") {
          unitChoose = "1";
        }
        if (deskipsi.text == "") {
          deskipsi.text = "";
        }
        if (imageTemp == null) {
          imageTemp = null;
        }
        if (!edited) {
          edited = false;
        }
      }
    }

    showBarModalBottomSheet(
        isDismissible: false,
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Padding(
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
                                  : edited
                                      ? Image.network(
                                          tempData[id]['image']['path']
                                              .toString(),
                                          width: 200)
                                      : const CircleAvatar(
                                          backgroundColor: Colors.black38,
                                          backgroundImage: null,
                                          radius: 100.0,
                                        ),
                            )),
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
                          // if (typeAlert == "Edit") {
                          edited = true;
                          // } else {
                          // edited = true;
                          // }
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
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    controller: namaBarang,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.production_quantity_limits),
                        labelText: "Nama Barang"),
                  ),
                  TextField(
                    controller: hargaBarang,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.monetization_on),
                      labelText: "Harga barang",
                    ),
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: stock,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.confirmation_number),
                      labelText: "Stock",
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Icon(
                          Icons.ac_unit,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            items: list_unit
                                .map<DropdownMenuItem<String>>((items) {
                              return DropdownMenuItem(
                                  value: items['id'].toString(),
                                  child: Text(items['name']));
                            }).toList(),
                            value: unitChoose,
                            onChanged: (val) => setState(() {
                              unitChoose = val.toString();
                            }),
                            onSaved: (val) => setState(() {
                              unitChoose = val.toString();
                            }),
                            hint: Text(
                              "Select Item",
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.end,
                            ),
                            icon: Padding(
                                //Icon at tail, arrow bottom is default icon
                                padding: EdgeInsets.only(left: 20),
                                child: Icon(Icons.arrow_downward)),
                            style: TextStyle(
                              color: unitChoose == ""
                                  ? Colors.grey[800]
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Icon(
                          Icons.medical_services,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            items: apotekList
                                .map<DropdownMenuItem<String>>((items) {
                              return DropdownMenuItem(
                                  value: items['id'].toString(),
                                  child: Text(items['name']));
                            }).toList(),
                            value: selectApotek,
                            onChanged: (val) => setState(() {
                              selectApotek = val.toString();
                            }),
                            onSaved: (val) => setState(() {
                              selectApotek = val.toString();
                            }),
                            hint: Text(
                              "Select Item",
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.end,
                            ),
                            icon: Padding(
                                //Icon at tail, arrow bottom is default icon
                                padding: EdgeInsets.only(left: 20),
                                child: Icon(Icons.arrow_downward)),
                            style: TextStyle(
                              color: selectApotek == ""
                                  ? Colors.grey[800]
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    keyboardType: TextInputType.text,
                    controller: deskipsi,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.description),
                      labelText: "Deskrispi",
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => {
                      typeAlert == "Edit"
                          ? updateItem(idUpdate.toString())
                          : createItem(),
                      Navigator.pop(context),
                    },
                    child: Text(
                      typeAlert == "Edit" ? "Simpan Data" : "Tambah Data",
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
    // AwesomeDialog(
    //   context: context,
    //   onDissmissCallback: (type) {
    //     edited = false;
    //     imageTemp = null;
    //     namaBarang.text = "";
    //     hargaBarang.text = "";
    //     stock.text = "";
    //     unitChoose = "1";
    //     deskipsi.text = "";
    //   },
    //   dialogType: DialogType.NO_HEADER,
    //   animType: AnimType.SCALE,
    //   headerAnimationLoop: false,
    //   title: 'Warning',
    //   desc: "Anda yakin ingin menghapus data?",
    //   body: Padding(
    //     padding: const EdgeInsets.all(15.0),
    //     child: Column(
    //       children: <Widget>[
    //         Align(
    //           alignment: const Alignment(0, 1),
    //           child: Column(
    //             mainAxisSize: MainAxisSize.min,
    //             children: [
    //               CircleAvatar(
    //                   backgroundColor: Colors.white,
    //                   radius: 55,
    //                   child: Hero(
    //                     tag: "pp",
    //                     child: imageTemp != null
    //                         ? CircleAvatar(
    //                             backgroundColor: Colors.black38,
    //                             backgroundImage: MemoryImage(imageTemp!),
    //                             radius: 100.0,
    //                           )
    //                         : edited
    //                             ? Image.network(
    //                                 tempData[id]['image']['path'].toString(),
    //                                 width: 200)
    //                             : const CircleAvatar(
    //                                 backgroundColor: Colors.black38,
    //                                 backgroundImage: null,
    //                                 radius: 100.0,
    //                               ),
    //                   )),
    //             ],
    //           ),
    //         ),
    //         Align(
    //           alignment: Alignment.center,
    //           // ignore: sized_box_for_whitespace
    //           child: Container(
    //             width: MediaQuery.of(context).size.width * 0.3,
    //             child: ElevatedButton(
    //               style: ElevatedButton.styleFrom(
    //                 primary: Colors.blue,
    //                 onPrimary: Colors.grey,
    //                 onSurface: Colors.black,
    //               ),
    //               onPressed: () {
    //                 // if (typeAlert == "Edit") {
    //                 edited = true;
    //                 // } else {
    //                 // edited = true;
    //                 // }
    //                 Navigator.pop(context);
    //                 popUpCamera();
    //               },
    //               child: Container(
    //                 alignment: Alignment.center,
    //                 child: Container(
    //                   child: Row(
    //                     children: const <Widget>[
    //                       Icon(
    //                         Icons.camera_alt,
    //                         color: Colors.white,
    //                       ),
    //                       SizedBox(
    //                         width: 5,
    //                       ),
    //                       Text(
    //                         "Tambah",
    //                         textAlign: TextAlign.center,
    //                         style: TextStyle(color: Colors.white, fontSize: 15),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ),
    //         TextField(
    //           controller: namaBarang,
    //           keyboardType: TextInputType.text,
    //           decoration: const InputDecoration(
    //               icon: Icon(Icons.production_quantity_limits),
    //               labelText: "Nama Barang"),
    //         ),
    //         TextField(
    //           controller: hargaBarang,
    //           keyboardType: TextInputType.number,
    //           decoration: const InputDecoration(
    //             icon: Icon(Icons.monetization_on),
    //             labelText: "Harga barang",
    //           ),
    //         ),
    //         TextField(
    //           keyboardType: TextInputType.number,
    //           controller: stock,
    //           decoration: const InputDecoration(
    //             icon: Icon(Icons.confirmation_number),
    //             labelText: "Stock",
    //           ),
    //         ),
    //         Container(
    //           width: double.infinity,
    //           child: Row(
    //             children: [
    //               Icon(
    //                 Icons.ac_unit,
    //                 color: Colors.grey,
    //               ),
    //               SizedBox(
    //                 width: 15,
    //               ),
    //               Expanded(
    //                 flex: 1,
    //                 child: DropdownButtonFormField<String>(
    //                   isExpanded: true,
    //                   items: list_unit.map<DropdownMenuItem<String>>((items) {
    //                     return DropdownMenuItem(
    //                         value: items['id'].toString(),
    //                         child: Text(items['name']));
    //                   }).toList(),
    //                   value: unitChoose,
    //                   onChanged: (val) => setState(() {
    //                     unitChoose = val.toString();
    //                   }),
    //                   onSaved: (val) => setState(() {
    //                     unitChoose = val.toString();
    //                   }),
    //                   hint: Text(
    //                     "Select Item",
    //                     style: TextStyle(color: Colors.grey),
    //                     textAlign: TextAlign.end,
    //                   ),
    //                   icon: Padding(
    //                       //Icon at tail, arrow bottom is default icon
    //                       padding: EdgeInsets.only(left: 20),
    //                       child: Icon(Icons.arrow_downward)),
    //                   style: TextStyle(
    //                     color:
    //                         unitChoose == "" ? Colors.grey[800] : Colors.black,
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //         Container(
    //           width: double.infinity,
    //           child: Row(
    //             children: [
    //               Icon(
    //                 Icons.medical_services,
    //                 color: Colors.grey,
    //               ),
    //               SizedBox(
    //                 width: 15,
    //               ),
    //               Expanded(
    //                 flex: 1,
    //                 child: DropdownButtonFormField<String>(
    //                   isExpanded: true,
    //                   items: apotekList.map<DropdownMenuItem<String>>((items) {
    //                     return DropdownMenuItem(
    //                         value: items['id'].toString(),
    //                         child: Text(items['name']));
    //                   }).toList(),
    //                   value: selectApotek,
    //                   onChanged: (val) => setState(() {
    //                     selectApotek = val.toString();
    //                   }),
    //                   onSaved: (val) => setState(() {
    //                     selectApotek = val.toString();
    //                   }),
    //                   hint: Text(
    //                     "Select Item",
    //                     style: TextStyle(color: Colors.grey),
    //                     textAlign: TextAlign.end,
    //                   ),
    //                   icon: Padding(
    //                       //Icon at tail, arrow bottom is default icon
    //                       padding: EdgeInsets.only(left: 20),
    //                       child: Icon(Icons.arrow_downward)),
    //                   style: TextStyle(
    //                     color: selectApotek == ""
    //                         ? Colors.grey[800]
    //                         : Colors.black,
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //         TextField(
    //           keyboardType: TextInputType.text,
    //           controller: deskipsi,
    //           decoration: const InputDecoration(
    //             icon: Icon(Icons.description),
    //             labelText: "Deskrispi",
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    //   btnOk: DialogButton(
    //     onPressed: () => {
    //       typeAlert == "Edit" ? updateItem(idUpdate.toString()) : createItem(),
    //       Navigator.pop(context),
    //     },
    //     child: Text(
    //       typeAlert == "Edit" ? "Simpan Data" : "Tambah Data",
    //       style: const TextStyle(color: Colors.white, fontSize: 20),
    //     ),
    //   ),
    //   btnOkOnPress: () {},
    // ).show();
  }

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: HexColor("2C3246"),
          title: const Text("Obat Herbal"),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: HexColor("2C3246"),
            child: Icon(Icons.add),
            onPressed: () {
              AlertData("false");
              setState(() {
                id = tempData.length;
              });
            }),
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
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextField(
                              onEditingComplete: () => getItem(),
                              controller: find,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(),
                                  labelText: "Cari Obat"),
                            ),
                          ),
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
                                                    flex: 1,
                                                    child: Image.network(
                                                      tempData[index]['image']
                                                              ['path']
                                                          .toString(),
                                                      width: 200,
                                                    ),
                                                  ),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 10),
                                                        child: Text(
                                                            tempData[index]
                                                                    ['name']
                                                                .toString(),
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: const TextStyle(
                                                                fontFamily:
                                                                    'Nunito',
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none)),
                                                      )),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 10),
                                                        child: Text(
                                                            tempData[index][
                                                                    'data_apotek']
                                                                ['name'],
                                                            textAlign: TextAlign
                                                                .start,
                                                            style: const TextStyle(
                                                                fontFamily:
                                                                    'Nunito',
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none)),
                                                      )),
                                                  Expanded(
                                                      flex: 1,
                                                      child: ElevatedButton(
                                                          child: const Align(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            child: Icon(
                                                                Icons.delete),
                                                          ),
                                                          style: ButtonStyle(
                                                              shape: MaterialStateProperty.all<
                                                                      RoundedRectangleBorder>(
                                                                  RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20.0),
                                                          ))),
                                                          onPressed: () =>
                                                              deleteAlert(
                                                                  tempData[
                                                                          index]
                                                                      ['id']))),
                                                  SizedBox(
                                                    width: windowWidth * 0.02,
                                                  ),
                                                  Expanded(
                                                      flex: 1,
                                                      child: ElevatedButton(
                                                          child: const Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Icon(
                                                                Icons.edit),
                                                          ),
                                                          style: ButtonStyle(
                                                              shape: MaterialStateProperty.all<
                                                                      RoundedRectangleBorder>(
                                                                  RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        18.0),
                                                          ))),
                                                          onPressed: () => {
                                                                setState(() {
                                                                  id = index;
                                                                  idUpdate =
                                                                      tempData[
                                                                              index]
                                                                          [
                                                                          'id'];
                                                                }),
                                                                AlertData(
                                                                    "Edit"),
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
                                //             AlertData("false"),
                                //             setState(() {
                                //               id = tempData.length;
                                //             })
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
                                //                 const Text("Tambah Barang")
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
