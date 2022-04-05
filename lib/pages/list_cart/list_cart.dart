import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/send_address/list_cart/send_address.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListCart extends StatefulWidget {
  const ListCart({Key? key}) : super(key: key);

  @override
  ListCartState createState() => ListCartState();
}

class ListCartState extends State<ListCart> {
  bool isLoading = false;
  double windowHeight = 0;
  double windowWidth = 0;
  String token = "";
  int totalPrice = 0;
  var tempData = [];
  bool _checkbox = false;
  int idCart = -1;
  var cart = [];
  var list_unit = [];
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
    await getUnits();
    await getItem();
    countPrice();
  }

  setDefaultCheckbox(item) async {
    for (var i = 0; i < item.length; i++) {
      cart.add(false);
    }
    setState(() {
      isLoading = false;
    });
  }

  getUnits() async {
    await ApiServices().getUnits(token).then((json) {
      if (json != null) {
        print(json);
        setState(() {
          list_unit = json;
        });
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  getItem() async {
    final prefs = await SharedPreferences.getInstance();
    await ApiServices().getCart(token).then((json) {
      if (json != null) {
        if (json['status'] == 'success' && json['data']['data'].length > 0) {
          setDefaultCheckbox(json['data']['data'][0]['data']);
          setState(() {
            idCart = json['data']['data'][0]['id'];
            tempData = json['data']['data'][0]['data'];
          });
          if (json['data']['data'][0]['data'].length > 0) {
            var tempSendCart = [];
            for (var i = 0; i < json['data']['data'][0]['data'].length; i++) {
              tempSendCart.add({
                'id': json['data']['data'][0]['data'][i]['id'],
                'volume': json['data']['data'][0]['data'][i]['volume'],
                'price': json['data']['data'][0]['data'][i]['price']
              });
            }
            prefs.setString('dataCart', jsonEncode(tempSendCart));
          } else {
            prefs.setString('dataCart', "");
          }
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  sendData() async {
    await ApiServices().setCart(token, json.encode(tempData)).then((json) {
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

  onChange(idx, index, value) {
    setState(() {
      cart[idx] = !cart[idx];
    });
    countPrice();
  }

  countPrice() {
    setState(() {
      totalPrice = 0;
    });
    for (var i = 0; i < tempData.length; i++) {
      // if (cart[i] == true) {
      int temp = tempData[i]['volume'] * tempData[i]['price'];
      setState(() {
        totalPrice = totalPrice + temp;
      });
      // }
    }
  }

  nextChooseAddress() async {
    final prefs = await SharedPreferences.getInstance();
    var itemChoosen = [];
    // for (var i = 0; i < cart.length; i++) {
    // if (cart[i] == true) {
    // itemChoosen.add(tempData[i]);
    // }
    // }
    for (var i = 0; i < tempData.length; i++) {
      itemChoosen.add(tempData[i]);
    }
    prefs.setString('itemChoosen', jsonEncode(itemChoosen));
    prefs.setString('idCart', idCart.toString());
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
      return const AddressSend();
    }));

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const AddressSend()),
    // );
  }

  deleteCart(index) async {
    setState(() {
      tempData.removeAt(index);
    });
    await sendData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: HexColor("2C3246"), title: const Text("Keranjang")),
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
                                  child: Row(
                                    children: [
                                      // Checkbox(
                                      //   value: isLoading ? false : cart[i],
                                      //   onChanged: (value) {
                                      //     onChange(i, tempData[i], value);
                                      //   },
                                      // ),

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
                                              Row(
                                                children: [
                                                  Text(tempData.isNotEmpty
                                                      ? tempData[i]['volume']
                                                              .toString() +
                                                          " " +
                                                          tempData[i]['item_detail']
                                                                      [
                                                                      'unit_detail']
                                                                  ['name']
                                                              .toString()
                                                      : '')
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          flex: 2,
                                          child: Text(tempData.isNotEmpty
                                              ? "Rp " +
                                                  tempData[i]['price']
                                                      .toString()
                                              : "Rp -")),
                                      IconButton(
                                        onPressed: () {
                                          deleteCart(i);
                                        },
                                        icon: const Icon(Icons.delete_forever),
                                        color: Colors.red,
                                      ),
                                      // Checkbox(
                                      //   value: isLoading ? false : cart[i],
                                      //   onChanged: (value) {
                                      //     onChange(i, tempData[i], value);
                                      //   },
                                      // ),
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
                            nextChooseAddress();
                          },
                          child: const Text('Beli',
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
