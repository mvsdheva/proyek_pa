import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/newspaper_details/newspaper_details_public.dart';
import 'package:herbal/pages/upload_proof/upload_proof.dart';
import 'package:herbal/shared/shared.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionList extends StatefulWidget {
  const TransactionList({Key? key}) : super(key: key);

  @override
  TransactionListState createState() => TransactionListState();
}

class TransactionListState extends State<TransactionList> {
  double windowHeight = 0;
  double windowWidth = 0;
  String token = "";
  var tempData = [];
  bool isLoading = true;
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

  getItem() async {
    await ApiServices().getTransaction(token).then((json) {
      if (json != null) {
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

  uploadProof(index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dataUploadProof', json.encode(tempData[index]));
    Navigator.push(context,
            MaterialPageRoute(builder: (context) => const UploadProof()))
        .then((value) => getItem());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor("2C3246"),
        title: const Text("Daftar Transaksi"),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                for (var i = 0; i < tempData.length; i++)
                  Container(
                    margin: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      color: Colors.black12,
                    ),
                    child: InkWell(
                      splashColor: Colors.yellow,
                      highlightColor: HexColor("2C3246").withOpacity(0.5),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20.0)),
                      onTap: () => uploadProof(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tempData[i]['id'],
                                            textAlign: TextAlign.left,
                                          ),
                                          Container(
                                            width: windowWidth * 0.3,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(5.0)),
                                              color: tempData[i]['status'] == 0
                                                  ? tempData[i]['proof'] != null
                                                      ? Colors.red[800]
                                                      : Colors.red[200]
                                                  : Colors.green[800],
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                tempData[i]['status'] == 0
                                                    ? tempData[i]['proof'] !=
                                                            null
                                                        ? 'Proses'
                                                        : 'Belum Selesai'
                                                    : tempData[i]['status'] == 1
                                                        ? 'Selesai'
                                                        : 'Dibatalkan',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Text(
                                        'Pembelian',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      for (var j = 0;
                                          j <
                                              tempData[i]['data_cart']['data']
                                                  .length;
                                          j++)
                                        // ignore: avoid_unnecessary_containers
                                        Container(
                                            margin: EdgeInsets.all(2),
                                            child: Column(children: [
                                              Row(
                                                children: [
                                                  Image.network(
                                                      tempData[i]['data_cart']
                                                                      ['data']
                                                                  .length >
                                                              0
                                                          ? tempData[i]['data_cart']
                                                                          [
                                                                          'data'][j]
                                                                      [
                                                                      'item_detail']
                                                                  [
                                                                  'image']['path']
                                                              .toString()
                                                          : 'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                                                      width: 50,
                                                      height: 50),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(tempData[i]['data_cart']
                                                          ['data'][j]
                                                      ['item_detail']['name']),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Row(
                                                        children: [
                                                          Text(tempData[i][
                                                                          'data_cart']
                                                                      ['data']
                                                                  [j]['volume']
                                                              .toString()),
                                                          Text("x Rp " +
                                                              tempData[i]['data_cart']
                                                                          [
                                                                          'data']
                                                                      [
                                                                      j]['price']
                                                                  .toString()),
                                                        ],
                                                      )),
                                                ],
                                              ),
                                            ])),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          const Text("Total Pembayaran"),
                                          Expanded(
                                              flex: 1,
                                              child: Text(
                                                "Rp " +
                                                    tempData[i]['data_cart']
                                                            ['total']
                                                        .toString(),
                                                textAlign: TextAlign.right,
                                              ))
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: RaisedButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              onPressed: () {
                                                uploadProof(i);
                                              },
                                              child: const Text(
                                                  'Cara Pembayaran',
                                                  style:
                                                      TextStyle(fontSize: 15)),
                                              color: HexColor("2C3246"),
                                              textColor: Colors.white,
                                              elevation: 5,
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            )),
      ),
    );
  }
}
