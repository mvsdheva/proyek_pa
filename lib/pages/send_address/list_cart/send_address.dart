import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/address_list/list_address.dart';
import 'package:herbal/pages/list_transaction/list_transaction.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressSend extends StatefulWidget {
  const AddressSend({Key? key}) : super(key: key);

  @override
  AddressSendState createState() => AddressSendState();
}

class AddressSendState extends State<AddressSend> {
  bool isLoading = false;
  double windowHeight = 0;
  double windowWidth = 0;
  String token = "";
  int totalPrice = 0;
  var tempData = [];
  var cart = [];
  int idxAddress = 0;
  int idAddress = 0;
  bool changeAddress = false;
  var addressList = [];
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
    String tempDataIdCart = prefs.getString('itemChoosen')!;
    tempData = json.decode(tempDataIdCart);
    await countPrice();
    await getItem();
  }

  countPrice() {
    setState(() {
      totalPrice = 0;
    });
    for (var i = 0; i < tempData.length; i++) {
      int temp = tempData[i]['volume'] * tempData[i]['price'];
      setState(() {
        totalPrice = totalPrice + temp;
      });
    }
  }

  getItem() async {
    await ApiServices().getAddress(token).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          setState(() {
            addressList = json['data']['data'];
          });
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  createItem() async {
    final prefs = await SharedPreferences.getInstance();
    String cart_id = prefs.getString('idCart')!;
    await ApiServices()
        .createTransaction(
            token, cart_id.toString(), 'transfer', idAddress.toString())
        .then((json) {
      if (json != null) {
        if (json['status'] == "success") {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
            return const TransactionList();
          }));
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  dialogAddress() async {
    AwesomeDialog(
        context: context,
        dialogType: DialogType.NO_HEADER,
        animType: AnimType.SCALE,
        headerAnimationLoop: false,
        title: 'Warning',
        desc: "Anda yakin ingin menghapus data?",
        body: Container(
          child: Column(
            children: [
              Text(
                "List Address",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              for (var i = 0; i < addressList.length; i++)
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() {
                      idxAddress = i;
                      idAddress = addressList[i]['id'];
                      changeAddress = true;
                    });
                    Navigator.pop(context);
                  },
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              'Alamat Pengiriman',
                              textAlign: TextAlign.left,
                              style: TextStyle(fontSize: 17),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  addressList.isNotEmpty
                                      ? addressList[i]['address'].toString()
                                      : "",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  addressList.isNotEmpty
                                      ? addressList[i]['postal_code'].toString()
                                      : "",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  addressList.isNotEmpty
                                      ? addressList[i]['description'].toString()
                                      : "",
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        btnOk: DialogButton(
          onPressed: () => {
            Navigator.pop(context),
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ListAddress()),
            ).then((value) => initiateData())
          },
          child: const Text(
            "Tambah Data",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )).show();
  }

  alertError(String err, int error) {
    AwesomeDialog(
            context: context,
            dialogType: error == 0 ? DialogType.WARNING : DialogType.ERROR,
            animType: AnimType.SCALE,
            headerAnimationLoop: false,
            title: error == 1 ? 'Error' : 'Warning',
            desc: err,
            btnOkOnPress: () {},
            btnOkIcon: Icons.cancel,
            btnOkColor: Colors.red)
        .show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: HexColor("2C3246"), title: const Text("Pengiriman")),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  'Alamat Pengiriman',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                !changeAddress
                                    ? const Text(
                                        'Pilih Alamat Pengiriman',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.red),
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            addressList[idxAddress]['address']
                                                .toString(),
                                            textAlign: TextAlign.left,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            addressList[idxAddress]
                                                    ['postal_code']
                                                .toString(),
                                            textAlign: TextAlign.left,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            addressList[idxAddress]
                                                    ['description']
                                                .toString(),
                                            textAlign: TextAlign.left,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                          Expanded(
                              child: Align(
                            alignment: Alignment.topRight,
                            child: TextButton(
                                onPressed: () {
                                  dialogAddress();
                                },
                                child: const Text("Pilih alamat lain")),
                          ))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
                                  child: Row(
                                    children: [
                                      Image.network(
                                          tempData.isNotEmpty
                                              ? tempData[i]['item_detail']
                                                      ['image']['path']
                                                  .toString()
                                              : 'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                                          width: 50,
                                          height: 50),
                                      Container(
                                        width: windowWidth * 0.1,
                                        height: windowHeight * 0.1,
                                        color: Colors.amber,
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                tempData.isNotEmpty
                                                    ? tempData[i]['item_detail']
                                                            ['name']
                                                        .toString()
                                                    : '',
                                                textAlign: TextAlign.left,
                                              ),
                                              Text(tempData.isNotEmpty
                                                  ? tempData[i]['volume']
                                                          .toString() +
                                                      "paks"
                                                  : '- paks'),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: Text(tempData.isNotEmpty
                                              ? "Rp " +
                                                  tempData[i]['price']
                                                      .toString()
                                              : "Rp -"))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Total', style: TextStyle(fontSize: 20)),
                            Text('Rp ' + totalPrice.toString(),
                                style: const TextStyle(fontSize: 20))
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          onPressed: () {
                            changeAddress
                                ? createItem()
                                : alertError('Anda belum pilih alamat!', 0);
                            ;
                          },
                          child: const Text('Bayar',
                              style: TextStyle(fontSize: 15)),
                          color: HexColor("2C3246"),
                          textColor: Colors.white,
                          elevation: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              ))
            ],
          ),
        ));
  }
}
