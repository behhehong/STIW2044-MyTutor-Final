// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:my_tutor/models/tutor.dart';

import 'package:http/http.dart' as http;
import 'package:my_tutor/models/user.dart';

class TutorPage extends StatefulWidget {
  final User user;
  TutorPage({Key? key, required this.user}) : super(key: key);

  @override
  State<TutorPage> createState() => _TutorPageState();
}

class _TutorPageState extends State<TutorPage> {
  List<Tutor> tutorList = <Tutor>[];
  String titlecenter = "Loading data...";
  final df = DateFormat('dd/MM/yyyy hh:mm a');
  late double screenHeight, screenWidth, resWidth;
  var numofpage, curpage = 1;
  var color;
  TextEditingController searchController = TextEditingController();
  String search = "";

  @override
  void initState() {
    super.initState();
    _loadTutors(1, search);
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      resWidth = screenWidth;
      //rowcount = 2;
    } else {
      resWidth = screenWidth * 0.75;
      //rowcount = 3;
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tutors'),
          backgroundColor: const Color.fromARGB(255, 9, 56, 95),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _loadSearchDialog();
            },
          ),
        ),
        body: tutorList.isEmpty
            ? Center(
                child: Text(
                  titlecenter,
                  style: (const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              )
            : Container(
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 244, 243, 238)),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                    ),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        children: List.generate(
                          tutorList.length,
                          (index) {
                            return Stack(
                              children: [
                                InkWell(
                                  onTap: () => {_loadTutorDetails(index)},
                                  child: Card(
                                      child: Column(children: [
                                    Flexible(
                                        flex: 7,
                                        child: CachedNetworkImage(
                                            imageUrl:
                                                "https://hubbuddies.com/271513/myTutor/assets/tutors/" +
                                                    tutorList[index]
                                                        .tutor_id
                                                        .toString() +
                                                    '.jpg',
                                            fit: BoxFit.cover,
                                            width: resWidth,
                                            height: screenHeight)),
                                    const SizedBox(height: 5),
                                    Flexible(
                                      flex: 3,
                                      child: Column(children: [
                                        Text(
                                            tutorList[index]
                                                .tutor_name
                                                .toString(),
                                            style:
                                                const TextStyle(fontSize: 15),
                                            textAlign: TextAlign.center)
                                      ]),
                                    ),
                                  ])),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                        height: 30,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: numofpage,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              if ((curpage - 1) == index) {
                                color = const Color.fromARGB(255, 219, 80, 74);
                              } else {
                                color = Colors.black;
                              }
                              return SizedBox(
                                  width: 40,
                                  child: TextButton(
                                    onPressed: () =>
                                        {_loadTutors(index + 1, search)},
                                    child: Text(
                                      (index + 1).toString(),
                                      style: TextStyle(color: color),
                                    ),
                                  ));
                            }))
                  ],
                ),
              ),
      ),
    );
  }

  void _loadTutors(int pageno, String search) {
    curpage = pageno;
    numofpage ?? 1;
    http.post(
        Uri.parse("https://hubbuddies.com/271513/myTutor/php/load_tutors.php"),
        body: {
          'pageno': pageno.toString(),
          'search': search,
        }).then((response) {
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        var extractdata = jsondata['data'];
        numofpage = int.parse(jsondata['numofpage']);

        if (extractdata['tutors'] != null) {
          tutorList = <Tutor>[];
          extractdata['tutors'].forEach((v) {
            tutorList.add(Tutor.fromJson(v));
          });
          titlecenter = tutorList.length.toString() + " Subjects Available";
        } else {
          titlecenter = "No Subject Available";
          tutorList.clear();
        }
        setState(() {});
      } else {
        //do something
        titlecenter = "No Subject Available";
        tutorList.clear();
        setState(() {});
      }
    });
  }

  _loadTutorDetails(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: const Text(
              "Tutor Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
                child: Column(
              children: [
                CachedNetworkImage(
                  imageUrl:
                      "https://hubbuddies.com/271513/myTutor/assets/tutors/" +
                          tutorList[index].tutor_id.toString() +
                          '.jpg',
                  fit: BoxFit.cover,
                  width: resWidth,
                  placeholder: (context, url) =>
                      const LinearProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                Text(
                  tutorList[index].tutor_name.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text("Tutor Description: ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(tutorList[index].tutor_description.toString(),
                      style: const TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(255, 98, 144, 195))),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Text("Email: ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(
                        tutorList[index].tutor_email.toString(),
                        style: const TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 98, 144, 195)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Text("Phone: ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(tutorList[index].tutor_phone.toString(),
                          style: const TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 98, 144, 195))),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Text("Subject Owned: ",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(tutorList[index].subject_name.toString(),
                            style: const TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 98, 144, 195))),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                        df.format(DateTime.parse(
                            tutorList[index].tutor_datereg.toString())),
                        style:
                            const TextStyle(fontSize: 15, color: Colors.black)),
                  ),
                ])
              ],
            )),
            actions: [
              TextButton(
                child: const Text(
                  "Close",
                  style: TextStyle(),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _loadSearchDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            title: const Text(
              "Search",
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Enter the name of tutor',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: searchController.clear,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () {
                      search = searchController.text;
                      Navigator.of(context).pop();
                      _loadTutors(1, search);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromARGB(255, 9, 56, 95),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child: const Text("Search",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
