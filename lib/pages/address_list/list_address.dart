import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:herbal/api/api_services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListAddress extends StatefulWidget {
  const ListAddress({Key? key}) : super(key: key);

  @override
  ListAddressState createState() => ListAddressState();
}

class ListAddressState extends State<ListAddress> {
  bool isLoading = false;
  double windowHeight = 0;
  double windowWidth = 0;
  String token = "";
  int totalPrice = 0;
  var tempData = [];
  var cart = [];
  int idxAddress = 0;
  bool changeAddress = false;
  TextEditingController name = TextEditingController();
  TextEditingController categoryAddress = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController no_telp = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController postal_code = TextEditingController();

  @override
  void initState() {
    super.initState();
    initiateData();
  }

  initiateData() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token').toString();

    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;
    await getItem();
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

  getItem() async {
    await ApiServices().getAddress(token).then((json) {
      if (json != null) {
        print(json);
        if (json['status'] == 'success') {
          setState(() {
            tempData = json['data']['data'];
          });
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  createItem() async {
    await ApiServices()
        .createAddress(token, postal_code.text, address.text, description.text)
        .then((json) {
      if (json != null) {
        if (json['status'] == "success") {
          getItem();
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  updateItem(id) async {
    print(id);
    await ApiServices()
        .updateAddress(token, id.toString(), postal_code.text, address.text,
            description.text)
        .then((json) {
      if (json != null) {
        if (json['status'] == "success") {
          getItem();
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  deleteItem(id) async {
    await ApiServices().deleteAddress(token, id.toString()).then((json) {
      if (json != null) {
        if (json['status'] == "success") {
          getItem();
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  dialogAddress() async {
    description.text = '';
    address.text = '';
    postal_code.text = '';

    Alert(
        style: const AlertStyle(alertAlignment: Alignment.bottomCenter),
        context: context,
        title: 'Tambah Alamat',
        content: Column(
          children: <Widget>[
            // Card(
            //     shape: RoundedRectangleBorder(
            //       side: BorderSide(color: Colors.black, width: 1),
            //       borderRadius: BorderRadius.circular(5),
            //     ),
            //     child: Padding(
            //       padding: const EdgeInsets.all(10.0),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         mainAxisAlignment: MainAxisAlignment.start,
            //         children: [
            //           Text(
            //             'Alamat sebagai ( Alamat rumah, alamat kantor, atau sebagainya)',
            //             textAlign: TextAlign.left,
            //             style: TextStyle(
            //                 decoration: TextDecoration.underline, fontSize: 13),
            //           ),
            //           TextField(
            //             controller: categoryAddress,
            //             keyboardType: TextInputType.text,
            //           ),
            //           SizedBox(
            //             height: 10,
            //           ),
            //           Text(
            //             'Nama Penerima',
            //             textAlign: TextAlign.left,
            //             style: TextStyle(
            //                 decoration: TextDecoration.underline, fontSize: 13),
            //           ),
            //           TextField(
            //             controller: name,
            //             keyboardType: TextInputType.text,
            //           ),
            //         ],
            //       ),
            //     )),
            Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Text(
                      //   'Alamat',
                      //   textAlign: TextAlign.left,
                      //   style: TextStyle(
                      //       decoration: TextDecoration.underline, fontSize: 13),
                      // ),
                      // TextField(
                      //   controller: description,
                      //   keyboardType: TextInputType.text,
                      // ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Kode Pos',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            decoration: TextDecoration.underline, fontSize: 13),
                      ),
                      TextField(
                        controller: postal_code,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Alamat',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            decoration: TextDecoration.underline, fontSize: 13),
                      ),
                      TextField(
                        controller: address,
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  ),
                )),
            Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'Deskripsi',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            decoration: TextDecoration.underline, fontSize: 13),
                      ),
                      TextField(
                        controller: description,
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  ),
                )),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () => {createItem(), Navigator.pop(context)},
            child: const Text(
              "Tambah Data",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  dialogAddressUpdate(index) async {
    description.text = tempData[index]['description'].toString();
    address.text = tempData[index]['address'].toString();
    postal_code.text = tempData[index]['postal_code'].toString();
    Alert(
        style: const AlertStyle(alertAlignment: Alignment.bottomCenter),
        context: context,
        title: 'Update Alamat',
        content: Column(
          children: <Widget>[
            Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Kode Pos',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            decoration: TextDecoration.underline, fontSize: 13),
                      ),
                      TextField(
                        controller: postal_code,
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Alamat',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            decoration: TextDecoration.underline, fontSize: 13),
                      ),
                      TextField(
                        controller: address,
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  ),
                )),
            Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'Deskripsi',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            decoration: TextDecoration.underline, fontSize: 13),
                      ),
                      TextField(
                        controller: description,
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  ),
                )),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () =>
                {updateItem(tempData[index]['id']), Navigator.pop(context)},
            child: const Text(
              "Simpan Data",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: HexColor("2C3246"), title: const Text("Daftar Alamat")),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        for (var i = 0; i < tempData.length; i++)
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 15),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Alamat Pengiriman',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                            fontSize: 17),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            tempData.isNotEmpty
                                                ? tempData[i]['address']
                                                    .toString()
                                                : "",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            tempData.isNotEmpty
                                                ? tempData[i]['postal_code']
                                                    .toString()
                                                : "",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            tempData.isNotEmpty
                                                ? tempData[i]['description']
                                                    .toString()
                                                : "",
                                            textAlign: TextAlign.left,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          // ignore: sized_box_for_whitespace
                                          Container(
                                            width: double.infinity,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    onPrimary: Colors.white,
                                                    onSurface: Colors.red,
                                                    shadowColor: Colors.red,
                                                    primary: Colors.red,
                                                    elevation: 3,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10.0)), //////// HERE
                                                  ),
                                                  onPressed: () {
                                                    deleteItem(
                                                        tempData[i]['id']);
                                                  },
                                                  child: const Text(
                                                      'Delete Alamat',
                                                      style: TextStyle(
                                                          fontSize: 15)),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    onPrimary: Colors.white,
                                                    shadowColor:
                                                        Colors.greenAccent,
                                                    elevation: 3,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10.0)), //////// HERE
                                                  ),
                                                  onPressed: () {
                                                    dialogAddressUpdate(i);
                                                  },
                                                  child: const Text(
                                                      'Ubah Alamat',
                                                      style: TextStyle(
                                                          fontSize: 15)),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                // ignore: sized_box_for_whitespace
                child: Container(
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                        iconSize: 50,
                        onPressed: () {
                          dialogAddress();
                        },
                        icon: const Icon(
                          Icons.add_circle_outline_sharp,
                          color: Colors.blue,
                          size: 50,
                        )),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                // ignore: sized_box_for_whitespace
                child: Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      onPrimary: Colors.white,
                      shadowColor: Colors.greenAccent,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10.0)), //////// HERE
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Pilih Alamat',
                        style: TextStyle(fontSize: 15)),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
