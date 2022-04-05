import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileName extends StatefulWidget {
  const EditProfileName({Key? key}) : super(key: key);

  @override
  EditProfileNameState createState() => EditProfileNameState();
}

class EditProfileNameState extends State<EditProfileName> {
  double windowHeight = 0;
  double windowWidth = 0;
  String token = '';
  bool isLoading = true;
  int id = 0;
  String email = "";
  String noTelephone = "";
  String address = "";
  TextEditingController name = TextEditingController();
  bool isEditAdmin = false;

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
    var edit_name = prefs.getString('edit_name').toString();
    if (edit_name == 'admin') {
      isEditAdmin = true;
    }
    await getItem();
    setState(() {
      isLoading = false;
    });
  }

  getItem() async {
    await ApiServices().getProfileUser(token).then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          setState(() {
            id = json['data']["id"];
            email = json['data']["email"];
            noTelephone = json['data']["no_telephone"] != null
                ? json['data']["no_telephone"].toString()
                : '';
            address =
                json['data']["address"] != null ? json['data']["address"] : '';
            name.text = json['data']["name"];
          });
        }
      }
    }).catchError((e) {
      alertError(e.toString(), 1);
    });
  }

  updateProfile() async {
    await ApiServices()
        .updateProfileUser(
            token, id.toString(), name.text, email, noTelephone, address)
        .then((json) {
      if (json != null) {
        if (json['status'] == 'success') {
          Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          title: const Text("Ubah Nama Lengkap",
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.black,
                fontSize: 18,
              )),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  margin: EdgeInsets.only(top: 50, left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                          "Kamu hanya dapat mengubah nama 1 kali. Pastikan nama sudah benar.",
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              color: Colors.black54,
                              fontSize: 15)),
                      SizedBox(
                        height: windowHeight * 0.1,
                      ),
                      const Text("Nama Lengkap",
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              color: Colors.black54,
                              fontSize: 20)),
                      TextField(
                        controller: name,
                        style: const TextStyle(fontSize: 18),
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                            // hintText: 'Email atau Nomor Telepon',
                            ),
                      ),
                      SizedBox(
                        height: windowHeight * 0.1,
                      ),
                      // ignore: sized_box_for_whitespace
                      Container(
                        width: windowWidth * 0.9,
                        height: windowWidth * 0.12,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                onPrimary: Colors.amber,
                                onSurface: Colors.amber,
                                primary: defaultColor,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0)))),
                            onPressed: () => updateProfile(),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                "Simpan",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            )),
                      )
                    ],
                  )),
            ],
          ),
        ));
  }
}
