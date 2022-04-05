// ignore_for_file: unnecessary_const

import 'dart:convert';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/shared/shared.dart';
import 'package:herbal/widgets/loading.dart';

class AuthRegisterPage extends StatefulWidget {
  const AuthRegisterPage({Key? key}) : super(key: key);

  @override
  AuthRegisterState createState() => AuthRegisterState();
}

class AuthRegisterState extends State<AuthRegisterPage> {
  double windowHeight = 0;
  double windowWidth = 0;
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController noTelp = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController address = TextEditingController();
  bool isLoading = false;
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

  registerProsses() async {
    if (username.text != "" &&
        email.text != "" &&
        noTelp.text != "" &&
        password.text != "" &&
        confirmPassword.text != "" &&
        address.text != "") {
      setState(() {
        noTelp.text = noTelp.text.replaceFirst('0', '');
      });
      setState(() {
        isLoading = true;
      });
      await ApiServices()
          .registerPublicUser(username.text, email.text, password.text,
              confirmPassword.text, noTelp.text, address.text)
          .then((json) {
        if (json != null) {
          var jsonConvert = jsonDecode(json);
          if (jsonConvert['status'] == "success") {
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context);
          }
        }
      }).catchError((e) {
        alertError(e.toString(), 1);
      });
    } else {
      alertError('Data harus di isi semua!', 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height - 25;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: SizedBox(
          width: double.infinity,
          child: Stack(children: <Widget>[
            // ignore: sized_box_for_whitespace
            Positioned(
              top: 200,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  color: Color(0x304599ff),
                  borderRadius: BorderRadius.all(
                    Radius.circular(150),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: -10,
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  color: Color(0x30cc33ff),
                  borderRadius: BorderRadius.all(
                    Radius.circular(100),
                  ),
                ),
              ),
            ),
            Positioned(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 80,
                  sigmaY: 80,
                ),
                child: Container(),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(children: <Widget>[
                  const SizedBox(
                    height: 70,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Container(
                    child: Image.asset(
                      'assets/images/bsk.png',
                      height: 80,
                    ),
                  ),
                   const SizedBox(
                    height: 70,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 25, right: 25, top: 20, bottom: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nama Pengguna',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontFamily: 'Nunito', fontSize: 17),
                          ),
                          TextField(
                            controller: username,
                            style: const TextStyle(fontSize: 15),
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                                // hintText: 'Nama Pengguna,
                                ),
                          ),
                        ],
                      )),
                      
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 25, right: 25, top: 20, bottom: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Alamat',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Nunito', fontSize: 17),
                                ),
                                TextField(
                                  controller: address,
                                  style: const TextStyle(fontSize: 15),
                                  keyboardType: TextInputType.text,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                      // hintText: 'Nama Pengguna,
                                      ),
                                ),
                              ],
                            )),
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 25, right: 25, top: 5, bottom: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Email',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Nunito', fontSize: 17),
                                ),
                                TextField(
                                  controller: email,
                                  style: const TextStyle(fontSize: 18),
                                  keyboardType: TextInputType.emailAddress,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                      // hintText: 'Email',

                                      ),
                                ),
                              ],
                            )),
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 25, right: 25, top: 5, bottom: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nomor Telepon',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Nunito', fontSize: 20),
                                ),
                                TextField(
                                  controller: noTelp,
                                  style: const TextStyle(fontSize: 17),
                                  keyboardType: TextInputType.number,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                      // hintText: 'Nomor Telepon',

                                      ),
                                ),
                              ],
                            )),
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 25, right: 25, top: 5, bottom: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Password',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Nunito', fontSize: 20),
                                ),
                                TextField(
                                  controller: password,
                                  style: const TextStyle(fontSize: 17),
                                  keyboardType: TextInputType.text,
                                  textCapitalization: TextCapitalization.words,
                                  obscureText: hidePassword,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  decoration: InputDecoration(
                                    // hintText: 'Password',
                                    suffixIcon: IconButton(
                                      icon: Icon(!hidePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      onPressed: () {
                                        setState(() {});
                                        hidePassword = !hidePassword;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 25, right: 25, top: 5, bottom: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Konfirmasi Password',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Nunito', fontSize: 17),
                                ),
                                TextField(
                                  controller: confirmPassword,
                                  style: const TextStyle(fontSize: 18),
                                  keyboardType: TextInputType.text,
                                  textCapitalization: TextCapitalization.words,
                                  obscureText: hideConfirmPassword,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  decoration: InputDecoration(
                                    // hintText: 'Konfirmasi Password',
                                    suffixIcon: IconButton(
                                      icon: Icon(!hideConfirmPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      onPressed: () {
                                        setState(() {});
                                        hideConfirmPassword =
                                            !hideConfirmPassword;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              margin: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                  color: Colors.green, shape: BoxShape.circle),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: defaultColor,
                                  onPrimary: Colors.grey,
                                  onSurface: Colors.black,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(80.0)),
                                ),
                                onPressed: () {
                                  registerProsses();
                                },
                                child: Container(
                                  constraints: const BoxConstraints(
                                      maxWidth: 250.0, minHeight: 50.0),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "Registrasi",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                ),
                              ),
                            )),
                ]),
              ),
            ),
            Loading(isLoading)
          ]),
        )));
  }
}


// Container(
//                     decoration: const BoxDecoration(
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black26,
//                             offset: Offset(0.0, 2.0),
//                             blurRadius: 25.0,
//                           )
//                         ],
//                         color: Colors.white,
//                         borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(32),
//                             topRight: Radius.circular(32))),
//                     alignment: Alignment.topCenter,
//                     child: ListView(
//                       children: [
                        
//                       ],
//                     ),
//                   )