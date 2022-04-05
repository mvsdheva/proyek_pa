import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:herbal/api/api_services.dart';
import 'package:herbal/pages/newspaper_details/newspaper_details_public.dart';
import 'package:herbal/shared/shared.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListFavorite extends StatefulWidget {
  const ListFavorite({Key? key}) : super(key: key);

  @override
  ListFavoriteState createState() => ListFavoriteState();
}

class ListFavoriteState extends State<ListFavorite> {
  double windowHeight = 0;
  double windowWidth = 0;
  var tempData = [];
  String token = "";
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
    await ApiServices().getWish(token).then((json) {
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

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height - 25;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor("2C3246"),
        title: const Text("Daftar Keinginan"),
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Row(
                          children: [
                            !isLoading
                                ? tempData[i]['likeable_type'] ==
                                        "App\\Models\\Item"
                                    ? Image.network(
                                        tempData[i]['likeable']['image']['path']
                                            .toString(),
                                        width: 50,
                                        height: 50)
                                    : tempData[i]['likeable_type'] ==
                                            "App\\Models\\News"
                                        ? const Icon(
                                            Icons.library_books_outlined,
                                            size: 50,
                                          )
                                        : const Icon(
                                            Icons.radio,
                                            size: 50,
                                          )
                                : const Text(''),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      !isLoading
                                          ? tempData[i]['likeable_type'] ==
                                                  "App\\Models\\News"
                                              ? tempData[i]['likeable']['title']
                                              : tempData[i]['likeable']['name']
                                          : '',
                                      textAlign: TextAlign.left,
                                    ),
                                    Text(
                                      !isLoading
                                          ? tempData[i]['likeable_type'] ==
                                                  "App\\Models\\Radio"
                                              ? ''
                                              : tempData[i]['likeable']
                                                  ['description']
                                          : '',
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
