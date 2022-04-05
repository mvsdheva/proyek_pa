// ignore_for_file: unused_import, avoid_print, unnecessary_null_comparison

import 'dart:convert';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/auth/authregister.dart';
import 'package:herbal/pages/home_public.dart';
import 'package:herbal/pages/home.dart';
import 'package:herbal/shared/shared.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:herbal/widgets/loading.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLoginPage extends StatefulWidget {
  const AuthLoginPage({Key? key}) : super(key: key);

  @override
  AuthLoginPageState createState() => AuthLoginPageState();
}

GoogleSignIn _googleSignIn = GoogleSignIn();

class AuthLoginPageState extends State<AuthLoginPage> {
  double windowHeight = 0;
  double windowWidth = 0;
  bool hidePassword = true;
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController emailForgetPassword = TextEditingController();
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

  forgetPasswordDialog() async {
    emailForgetPassword.text = "";
    AwesomeDialog(
      context: context,
      onDissmissCallback: (type) {
        emailForgetPassword.text = "";
      },
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.SCALE,
      headerAnimationLoop: false,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            const Text(
              'Forgot Your Password?',
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: emailForgetPassword,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  icon: Icon(Icons.email), labelText: "Your Email"),
            ),
          ],
        ),
      ),
      btnOk: DialogButton(
        onPressed: () => {
          forgetPassword(),
          Navigator.pop(context),
        },
        child: const Text(
          "Reset Password",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      btnOkOnPress: () {},
    ).show();
  }

  forgetPassword() async {
    setState(() {
      isLoading = true;
    });
    await ApiServices().forgetPassword(emailForgetPassword.text).then((json) {
      if (json != null) {
        if (json['status'] == 'We have emailed your password reset link!') {
          alertError('Please check your email', 0);
        } else {
          alertError(json['email'], 0);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
    setState(() {
      isLoading = false;
    });
  }

  loginProsses() async {
    if (username.text != "" && password.text != "") {
      setState(() {
        isLoading = true;
      });
      await ApiServices()
          .postLogin(username.text, password.text)
          .then((json) async {
        if (json != null) {
          var jsonConvert = jsonDecode(json);
          if (jsonConvert['status'] == 'success') {
            setState(() {
              isLoading = false;
            });
            final prefs = await SharedPreferences.getInstance();
            prefs.setString('token', jsonConvert['data']["token"]);
            prefs.setString('role', jsonConvert['data']["user"]["access"]);
            print('set user');
            print(jsonConvert['data']["user"]["access"]);
            if (jsonConvert['data']["user"]["access"] == "users") {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const HomePublicPage(),
                ),
                (Route route) => false,
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const HomeAdminPage(),
                ),
                (Route route) => false,
              );
              // Navigator.of(context)
              //     .pushReplacement(MaterialPageRoute(builder: (_) {
              //   return const HomeAdminPage();
              // }));
            }
          } else {
            alertError(json, 1);
          }
        }
      }).catchError((e) {
        alertError(e, 1);
      });
    } else {
      alertError("Username dan Password tidak boleh kosong!", 0);
    }
  }

  loginWithGoogle(String email, String name) async {
    setState(() {
      isLoading = true;
    });
    await ApiServices().postLoginWithGoole(email, name).then((json) async {
      print(json);
      if (json != null) {
        var jsonConvert = jsonDecode(json);
        if (jsonConvert['status'] == 'success') {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('token', jsonConvert['data']["token"]);
          prefs.setString('role', jsonConvert['data']["user"]["access"]);
          if (jsonConvert['data']["user"]["access"] == "users") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const HomePublicPage(),
              ),
              (Route route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const HomeAdminPage(),
              ),
              (Route route) => false,
            );
          }
        } else {
          alertError(json.toString(), 1);
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
      _handleSignOut();
    });
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _handleSignIn() async {
    try {
      var res = await _googleSignIn.signIn();
      if (res!.email != null) {
        loginWithGoogle(res.email, res.displayName.toString());
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();
   @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height - 25;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Stack(
              children: [
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
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 70,
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        _logo(),
                        const SizedBox(
                          height: 70,
                        ),
                       Padding(
                          padding: const EdgeInsets.only(
                              left: 25,
                              right: 25,
                              top: 60,
                              bottom: 20),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Email atau Nomor Telepon',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 20),
                              ),
                              TextField(
                                controller: username,
                                style:
                                    const TextStyle(fontSize: 18),
                                keyboardType:
                                    TextInputType.emailAddress,
                                textCapitalization:
                                    TextCapitalization.words,
                                decoration: const InputDecoration(
                                    // hintText: 'Email atau Nomor Telepon',
                                    ),
                              ),
                            ],
                          )),
                        const SizedBox(
                          height: 50,
                        ),
                       Padding(
                          padding: const EdgeInsets.only(
                              left: 25,
                              right: 25,
                              top: 20,
                              bottom: 20),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Password',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 20),
                              ),
                              TextField(
                                controller: password,
                                style:
                                    const TextStyle(fontSize: 18),
                                keyboardType: TextInputType.text,
                                obscureText: hidePassword,
                                enableSuggestions: false,
                                autocorrect: false,
                                textCapitalization:
                                    TextCapitalization.words,
                                decoration: InputDecoration(
                                  // hintText: 'Password',
                                  suffixIcon: IconButton(
                                    icon: Icon(hidePassword
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
                        const SizedBox(
                          height: 10,
                        ),
                        //forgot password
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              forgetPasswordDialog();
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(
                                  left: 15,
                                  right: 20,
                                  top: 2,
                                  bottom: 2),
                              child: Text(
                                'Forgot Password',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AuthRegisterPage()),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(
                                  left: 15,
                                  right: 20,
                                  top: 2,
                                  bottom: 2),
                                child: Text(
                                  'Sudah Punya Akun ?',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                          height: 10,
                        ),
                        //login google
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  top: 8,
                                  bottom: 8),
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    // ignore: deprecated_member_use
                                    FlatButton(
                                        onPressed: _handleSignIn,
                                        padding:
                                            const EdgeInsets.all(0.0),
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    100.0),
                                            child: Image.asset(
                                              'assets/images/logogoogle.png',
                                              width: 50,
                                              height: 50,
                                            ))),
                                  ])),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        //login
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: HexColor("2C3246"),
                                onPrimary: HexColor("2C3246"),
                                onSurface: HexColor("2C3246"),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            80.0)),
                              ),
                              onPressed: () {
                                loginProsses();
                              },
                              child: Container(
                                constraints: const BoxConstraints(
                                    maxWidth: 250.0,
                                    minHeight: 50.0),
                                alignment: Alignment.center,
                                child: const Text(
                                  "Login",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                          )),
                        const SizedBox(
                          height: 30,
                        ),                   
                      ],
                    ),
                  ),
                ),
                Loading(isLoading)
              ],
            ),
          ),
        ),
      );
  }
}

Widget _logo() {
  return Center(
    child: SizedBox(
      child: Image.asset("assets/images/bsk.png"),
      height: 80,
    ),
  );
}
