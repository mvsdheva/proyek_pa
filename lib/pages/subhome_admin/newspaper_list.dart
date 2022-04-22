// ignore_for_file: unnecessary_const, prefer_const_constructors, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:herbal/api/api_services.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

class NewsPaperList extends StatefulWidget {
  const NewsPaperList({Key? key}) : super(key: key);

  @override
  NewsPaperListState createState() => NewsPaperListState();
}

class NewsPaperListState extends State<NewsPaperList> {
  TextEditingController title = TextEditingController();
  TextEditingController author = TextEditingController();
  TextEditingController description = TextEditingController();
  late File imageFile;
  Uint8List? imageTemp;
  String baseImage = "";
  late File _img;
  final ImagePicker _picker = ImagePicker();

  List<dynamic> tempPop = [];
  double windowHeight = 0;
  double windowWidth = 0;
  bool cropProses = false;
  String token = '';
  var tempData = [];
  bool isLoading = true;
  int id = 0;
  int idUpdate = 0;
  bool edited = false;
  bool addImage = false;
  String category = "";
  var optCategory = [
    {"val": "", "name": "All Category"},
    {"val": "sport", "name": "Olahraga"},
    {"val": "health", "name": "Kesehatan"},
    {"val": "social", "name": "Sosial dan Budaya"}
  ];
  @override
  void initState() {
    super.initState();
    initiateData();
  }

  initiateData() async {
    initializeDateFormatting('id');
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token').toString();
    await getItem();
  }

  getItem() async {
    setState(() {
      isLoading = true;
    });
    await ApiServices().getNewsAdmin(token).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          setState(() {
            tempData = json['data']['data'];
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

  getCustomFormattedDateTime(String givenDateTime, String dateFormat) {
    final DateTime docDateTime = DateTime.parse(givenDateTime).toLocal();
    return DateFormat(dateFormat, 'id').format(docDateTime);
  }

  createItem() async {
    setState(() {
      isLoading = true;
    });
    await ApiServices()
        .addNews(token, title.text, author.text, description.text, baseImage,
            category)
        .then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          initiateData();
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

  updateItem(index) async {
    setState(() {
      isLoading = true;
    });
    await ApiServices()
        .updateNews(token, idUpdate.toString(), title.text, author.text,
            description.text, baseImage, category)
        .then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          initiateData();
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

  deleteItem(int index) async {
    setState(() {
      isLoading = true;
    });
    await ApiServices().deleteNews(token, index.toString()).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          initiateData();
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
    final pickedFile = await _picker.getImage(source: source, maxWidth: 600);
    if (pickedFile != null) {
      baseImage = "";
      _img = File(pickedFile.path);
      List<int> imageBytes = _img.readAsBytesSync();
      String _img64 = base64Encode(imageBytes);
      imageTemp = const Base64Decoder().convert(_img64);
      baseImage = "data:image/png;base64," + _img64;
    }
    if (edited) {
      _showEditDataModal();
    } else {
      _showFullModal();
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
    // ignore: unnecessary_null_comparison
    return (bytes != null ? base64Encode(bytes) : null);
  }

  editData() async {
    title.text = tempData[id]['title'].toString();
    author.text = tempData[id]['author'].toString();
    description.text = tempData[id]['description'].toString();
    category = tempData[id]['category'].toString();
    if (baseImage == "") {
      final imgBase64Str =
          await networkImageToBase64(tempData[id]['image']['path'].toString());
      baseImage = "data:image/png;base64," + imgBase64Str.toString();
    }
    AwesomeDialog(
      context: context,
      onDissmissCallback: (type) {
        imageTemp = null;
        title.text = "";
        author.text = "";
        description.text = "";
        addImage = false;
        category = "";
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
                    setState(() {
                      addImage = true;
                    });
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
            TextField(
              controller: title,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  icon: Icon(Icons.label_important_rounded),
                  labelText: "Judul Berita"),
            ),
            TextField(
              controller: author,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                icon: Icon(Icons.account_circle),
                labelText: "Author",
              ),
            ),
            TextField(
              keyboardType: TextInputType.text,
              controller: description,
              decoration: const InputDecoration(
                icon: Icon(Icons.details),
                labelText: "Description",
              ),
            ),
            // ignore: sized_box_for_whitespace
            Container(
              width: double.infinity,
              child: Row(
                children: [
                  const Icon(
                    Icons.medical_services,
                    color: Colors.grey,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      items: optCategory.map<DropdownMenuItem<String>>((items) {
                        return DropdownMenuItem(
                            value: items['val'].toString(),
                            child: Text(items['name'].toString()));
                      }).toList(),
                      value: category,
                      onChanged: (val) => setState(() {
                        category = val.toString();
                      }),
                      onSaved: (val) => setState(() {
                        category = val.toString();
                      }),
                      hint: const Text(
                        "Select Item",
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.end,
                      ),
                      icon: const Padding(
                          //Icon at tail, arrow bottom is default icon
                          padding: EdgeInsets.only(left: 20),
                          child: Icon(Icons.arrow_downward)),
                      style: TextStyle(
                        color: category == "" ? Colors.grey[800] : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    title.text = "";
    author.text = "";
    description.text = "";
    category = "";
    if (addImage = false) {
      imageTemp = null;
    }
    AwesomeDialog(
      padding: EdgeInsets.all(5),
      context: context,
      onDissmissCallback: (type) {
        title.text = "";
        imageTemp = null;
        author.text = "";
        description.text = "";
        addImage = false;
        category = "";
      },
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.SCALE,
      headerAnimationLoop: false,
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(5),
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
                      primary: Colors.blue,
                      onPrimary: Colors.grey,
                      onSurface: Colors.black,
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              TextField(
                controller: title,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    icon: Icon(Icons.label_important_rounded),
                    labelText: "Judul Berita"),
              ),
              TextField(
                controller: author,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  icon: Icon(Icons.account_circle),
                  labelText: "Author",
                ),
              ),
              Container(
                width: double.infinity,
                child: Row(
                  children: [
                    const Icon(
                      Icons.medical_services,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        items:
                            optCategory.map<DropdownMenuItem<String>>((items) {
                          return DropdownMenuItem(
                              value: items['val'].toString(),
                              child: Text(items['name'].toString()));
                        }).toList(),
                        value: category,
                        onChanged: (val) => setState(() {
                          category = val.toString();
                        }),
                        onSaved: (val) => setState(() {
                          category = val.toString();
                        }),
                        hint: const Text(
                          "Select Item",
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.end,
                        ),
                        icon: const Padding(
                            //Icon at tail, arrow bottom is default icon
                            padding: EdgeInsets.only(left: 20),
                            child: Icon(Icons.arrow_downward)),
                        style: TextStyle(
                          color:
                              category == "" ? Colors.grey[800] : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextField(
                keyboardType: TextInputType.text,
                controller: description,
                decoration: const InputDecoration(
                  icon: Icon(Icons.details),
                  labelText: "Description",
                ),
              ),
              // ignore: sized_box_for_whitespace
            ],
          ),
        ),
      ),
      btnOk: DialogButton(
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

  _showEditDataModal() async {
    title.text = tempData[id]['title'].toString();
    author.text = tempData[id]['author'].toString();
    description.text = tempData[id]['description'].toString();
    category = tempData[id]['category'].toString();
    if (baseImage == "") {
      final imgBase64Str =
          await networkImageToBase64(tempData[id]['image']['path'].toString());
      baseImage = "data:image/png;base64," + imgBase64Str.toString();
    }

    showSlidingBottomSheet(context, builder: (context) {
      return SlidingSheetDialog(
          cornerRadius: 16,
          avoidStatusBar: true,
          snapSpec: SnapSpec(
            initialSnap: 1,
            snappings: [0.4, 1],
          ),
          headerBuilder: (context, state) => Material(
                child: Container(
                  width: double.infinity,
                  color: HexColor("#2C3246"),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 32,
                      height: 8,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ]),
                ),
              ),
          builder: (context, state) {
            return Material(
              child: ListView(
                shrinkWrap: true,
                primary: false,
                children: [
                  Container(
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
                                                backgroundImage:
                                                    MemoryImage(imageTemp!),
                                                radius: 100.0,
                                              )
                                            : Image.network(
                                                tempData[id]['image']['path']
                                                    .toString(),
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
                                  setState(() {
                                    addImage = true;
                                  });
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
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          TextField(
                            controller: title,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                                icon: Icon(Icons.label_important_rounded),
                                labelText: "Judul Berita"),
                          ),
                          TextField(
                            controller: author,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.account_circle),
                              labelText: "Author",
                            ),
                          ),
                          TextField(
                            keyboardType: TextInputType.text,
                            controller: description,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.details),
                              labelText: "Description",
                            ),
                          ),
                          // ignore: sized_box_for_whitespace
                          Container(
                            width: double.infinity,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.medical_services,
                                  color: Colors.grey,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    items: optCategory
                                        .map<DropdownMenuItem<String>>((items) {
                                      return DropdownMenuItem(
                                          value: items['val'].toString(),
                                          child:
                                              Text(items['name'].toString()));
                                    }).toList(),
                                    value: category,
                                    onChanged: (val) => setState(() {
                                      category = val.toString();
                                    }),
                                    onSaved: (val) => setState(() {
                                      category = val.toString();
                                    }),
                                    hint: const Text(
                                      "Select Item",
                                      style: TextStyle(color: Colors.grey),
                                      textAlign: TextAlign.end,
                                    ),
                                    icon: const Padding(
                                        //Icon at tail, arrow bottom is default icon
                                        padding: EdgeInsets.only(left: 20),
                                        child: Icon(Icons.arrow_downward)),
                                    style: TextStyle(
                                      color: category == ""
                                          ? Colors.grey[800]
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: HexColor("2C3246"),
                              onPrimary: HexColor("2C3246"),
                              onSurface: HexColor("2C3246"),
                            ),
                            onPressed: () {
                              updateItem(idUpdate.toString());
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Simpan',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          });
    });

    // showBarModalBottomSheet(
    //     enableDrag: true,
    //     context: context,
    //     builder: (context) {
    //       return
    //     });
  }

  // ignore: unused_element
  _showFullModal() async {
    title.text = "";
    author.text = "";
    description.text = "";
    category = "";
    if (addImage = false) {
      imageTemp = null;
    }

    showSlidingBottomSheet(context, builder: (context) {
      return SlidingSheetDialog(
          cornerRadius: 16,
          avoidStatusBar: true,
          snapSpec: SnapSpec(
            initialSnap: 1,
            snappings: [0.4, 1],
          ),
          headerBuilder: (context, state) => Material(
                child: Container(
                  width: double.infinity,
                  color: HexColor("#2C3246"),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 32,
                      height: 8,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ]),
                ),
              ),
          builder: (context, state) {
            return Material(
                child: ListView(
              shrinkWrap: true,
              primary: false,
              children: [
                Container(
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
                                              backgroundImage:
                                                  MemoryImage(imageTemp!),
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
                        SizedBox(
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
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: TextField(
                            controller: title,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                icon: Icon(Icons.label_important_rounded),
                                labelText: "Judul Berita"),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: TextField(
                            controller: author,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              icon: Icon(Icons.account_circle),
                              labelText: "Author",
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: double.infinity,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.medical_services,
                                color: Colors.grey,
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                flex: 1,
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder()),
                                  isExpanded: true,
                                  items: optCategory
                                      .map<DropdownMenuItem<String>>((items) {
                                    return DropdownMenuItem(
                                        value: items['val'].toString(),
                                        child: Text(items['name'].toString()));
                                  }).toList(),
                                  value: category,
                                  onChanged: (val) => setState(() {
                                    category = val.toString();
                                  }),
                                  onSaved: (val) => setState(() {
                                    category = val.toString();
                                  }),
                                  hint: const Text(
                                    "Select Item",
                                    style: TextStyle(color: Colors.grey),
                                    textAlign: TextAlign.end,
                                  ),
                                  icon: const Padding(
                                      //Icon at tail, arrow bottom is default icon
                                      padding: EdgeInsets.only(left: 20),
                                      child: Icon(Icons.arrow_downward)),
                                  style: TextStyle(
                                    color: category == ""
                                        ? Colors.grey[800]
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            minLines: 5,
                            maxLines: 5,
                            controller: description,
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 15),
                              border: OutlineInputBorder(),
                              icon: Icon(Icons.details),
                              labelText: "Description",
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: HexColor("2C3246"),
                            onPrimary: HexColor("2C3246"),
                            onSurface: HexColor("2C3246"),
                          ),
                          onPressed: () {
                            createItem();
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Tambah Data',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        // ignore: sized_box_for_whitespace
                      ],
                    ),
                  ),
                )
              ],
            ));
          });
    });

    // showBarModalBottomSheet(
    //     enableDrag: true,
    //     context: context,
    //     builder: (context) {
    //       return
    //     });
  }

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => {
            setState(() {
              edited = false;
            }),
            _showFullModal(),
            imageTemp?.clear()
          },
          backgroundColor: HexColor("#2C3246"),
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          backgroundColor: HexColor("2C3246"),
          title: const Text("Berita"),
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
                              SizedBox(
                                height: 20,
                              ),
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
                                                        Image.network(
                                                          tempData[index]
                                                                      ['image']
                                                                  ['path']
                                                              .toString(),
                                                          width: 70,
                                                        ),
                                                        Expanded(
                                                            flex: 2,
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                      tempData[index]
                                                                              [
                                                                              'title']
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
                                                                          fontWeight: FontWeight
                                                                              .normal,
                                                                          decoration:
                                                                              TextDecoration.none)),
                                                                  Text(
                                                                      tempData[index]
                                                                              [
                                                                              'author']
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
                                                                          fontWeight: FontWeight
                                                                              .normal,
                                                                          decoration:
                                                                              TextDecoration.none)),
                                                                  Text(
                                                                      getCustomFormattedDateTime(
                                                                              tempData[index][
                                                                                  'created_at'],
                                                                              'dd-MM-yyyy hh:mm a')
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
                                                                          fontWeight: FontWeight
                                                                              .normal,
                                                                          decoration:
                                                                              TextDecoration.none)),
                                                                ],
                                                              ),
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
                                                                        () {
                                                                      deleteAlert(
                                                                          tempData[index]
                                                                              [
                                                                              'id']);
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
                                                                                edited = true;
                                                                              }),
                                                                              _showEditDataModal(),
                                                                            }))
                                                      ]),
                                                    ),
                                                  ),
                                              ])),
                                      SizedBox(
                                        height: windowHeight * 0.02,
                                      ),
                                    ],
                                  ),
                                ),
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
