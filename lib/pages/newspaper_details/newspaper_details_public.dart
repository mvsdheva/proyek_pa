import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class NewspaperDetailsPublic extends StatefulWidget {
  const NewspaperDetailsPublic({Key? key}) : super(key: key);

  @override
  NewspaperDetailsPublicState createState() => NewspaperDetailsPublicState();
}

class NewspaperDetailsPublicState extends State<NewspaperDetailsPublic> {
  double windowHeight = 0;
  double windowWidth = 0;
  var dataNews = [];
  bool isLoading = true;
  String token = "";
  var datePublish = "";
  @override
  void initState() {
    initializeDateFormatting('id');
    initiateData();
    super.initState();
  }

  initiateData() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token').toString();
    String tempDataIdCart = prefs.getString('dataBerita')!;
    dataNews = json.decode(tempDataIdCart);
    datePublish = getCustomFormattedDateTime(
        dataNews[0]['created_at'], 'EEE, dd MMMM yyyy hh:mm a');
    setState(() {
      isLoading = false;
    });
  }

  getCustomFormattedDateTime(String givenDateTime, String dateFormat) {
    final DateTime docDateTime = DateTime.parse(givenDateTime).toLocal();
    return DateFormat(dateFormat, 'id').format(docDateTime);
  }

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height - 25;
    windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.blue, title: const Text("Detail Berita")),
        body: SafeArea(
            child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  !isLoading ? dataNews[0]['title'] : '',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Image.network(
                    !isLoading
                        ? dataNews[0]['image']['path'].toString()
                        : 'https://t4.ftcdn.net/jpg/00/89/55/15/360_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg',
                    width: windowWidth * 0.9,
                    height: windowWidth * 0.9),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                !isLoading ? dataNews[0]['author'] : '',
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                !isLoading ? datePublish : '',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              ),
              const SizedBox(
                height: 40,
              ),
              Text(
                !isLoading ? dataNews[0]['description'] : '',
                style: const TextStyle(fontSize: 17),
              ),
            ],
          ),
        )));
  }
}
