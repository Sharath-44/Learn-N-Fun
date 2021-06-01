import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnnfun/commonPages/informationCard.dart';
import 'package:learnnfun/widgets.dart';
import 'package:overlay_support/overlay_support.dart';

import '../auth.dart';
import '../Persona.dart';

class Prototype extends StatefulWidget {
  const Prototype({Key key}) : super(key: key);

  @override
  _PrototypeState createState() => _PrototypeState();
}

class _PrototypeState extends State<Prototype> {
  int step = 0;
  int indexSelected;
  String choiceSelected = "Category";
  String nextPath;

  Future<ListResult> details;
  String centralImageUrl;
  bool expand=false;

  void initState() {
    details = getDetailsFromStorage("prototypes");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Color(0xfff4f4f4),
        body: SafeArea(
          child: Center(
              child: Column(children: [
            expand?backButton(context, onTap: (){
              setState(() {
              expand=false;
            });}):backButton(context),
            Text("Prototype",
                style: GoogleFonts.quicksand(
                    color: const Color(0xff489fb5),
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    fontSize: height * 0.05)),
            Padding(
              padding: EdgeInsets.only(
                  left: width * 0.2,
                  right: width * 0.2,
                  top: height * 0.001,
                  bottom: height * 0.001),
              child: Text(
                  "Select items from the inventory to assemble the gift!",
                  style: GoogleFonts.quicksand(
                      color: const Color(0xff1a1b41),
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: height * 0.02)),
            ),
            Container(height: height * 0.03),
            whiteScreen(context, height: expand?height*0.6:height * 0.3, children: [
              centralImageUrl != null
                  ? Image.network(centralImageUrl, fit: BoxFit.contain,height: expand?height*0.6:height * 0.3, loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes
                        : null,
                  ),
                );
              },)
                  : Container()
            ]),
            Container(height: height * 0.03),
            expand?
            button(context, text: "Continue", onTap: (){
              userDocReference.update({
                "trophies": 0,
                "rewards": FieldValue.increment(1),
                "taskUnlocked": 5
              });
              currentProgress.taskUnlocked = 5;
              currentProgress.rewards += 1;
              currentProgress.trophies = 0;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          InformationCard(
                              cardNumber: 3),
                      settings: RouteSettings(
                          name: 'Actual game')));
            }):Expanded(
              child: Container(
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height * 0.05),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x338b8b8b),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: width * 0.06),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(children: [
                            Visibility(
                                maintainState: true,
                                maintainAnimation: true,
                                maintainSize: true,
                                visible: step != 0,
                                child: IconButton(
                                    iconSize: 50,
                                    icon: Icon(Icons.chevron_left),
                                    onPressed: () {
                                      setState(() {
                                        int lastSlashIndex =
                                        nextPath.lastIndexOf('/');
                                        nextPath = nextPath.substring(
                                            0, lastSlashIndex);
                                        details =
                                            getDetailsFromStorage(nextPath);
                                        int lastSlashIndex2 =
                                        nextPath.lastIndexOf('/');
                                        choiceSelected = nextPath
                                            .substring(lastSlashIndex2 + 1);
                                        step--;
                                        centralImageUrl = null;
                                        indexSelected = null;
                                      });
                                    })),
                            Container(
                              width: width * 0.5,
                              child: Text("Choose $choiceSelected",
                                  style: GoogleFonts.quicksand(
                                      color: const Color(0xff489fb5),
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.normal,
                                      fontSize: height * 0.03),
                                  textAlign: TextAlign.center),
                            ),
                            centralImageUrl==null
                                ? IconButton(
                                iconSize: 50,
                                icon: Icon(Icons.chevron_right),
                                onPressed: () {
                                  if (indexSelected != null &&
                                      nextPath != null) {
                                    setState(() {
                                      details =
                                          getDetailsFromStorage(nextPath);
                                      int lastSlashIndex =
                                      nextPath.lastIndexOf('/');
                                      choiceSelected = nextPath
                                          .substring(lastSlashIndex + 1);
                                      indexSelected = null;
                                      step++;
                                    });
                                  } else {
                                    showSimpleNotification(
                                        Text(
                                            "You have not selected an option"),
                                        background: Colors.redAccent,
                                        position:
                                        NotificationPosition.bottom);
                                  }
                                })
                                : IconButton(
                                iconSize: 50,
                                icon: Icon(Icons.check),
                                onPressed: () {
                                  setState(() {
                                    expand=true;
                                  });
                                }),
                          ]),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: width * 0.05,
                                  right: width * 0.05,
                                  top: height * 0.01,
                                  bottom: height * 0.01),
                              child: SingleChildScrollView(
                                child: FutureBuilder<ListResult>(
                                    future: details,
                                    builder: (context,
                                        AsyncSnapshot<ListResult> snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.connectionState ==
                                              ConnectionState.done) {
                                        //This is the image selection page
                                        return ListView.builder(
                                          shrinkWrap: true,
                                          physics: ScrollPhysics(),
                                          itemCount: snapshot
                                              .data.prefixes.isEmpty
                                              ? snapshot.data.items.length
                                              : snapshot.data.prefixes.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    indexSelected = index;
                                                  });
                                                  snapshot.data.prefixes.isEmpty
                                                      ? setCentralImage(snapshot
                                                      .data.items[index])
                                                      : nextPath = snapshot
                                                      .data
                                                      .prefixes[index]
                                                      .fullPath;
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: height * 0.02),
                                                  child: Container(
                                                      height: height * 0.08,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                20)),
                                                        border: indexSelected ==
                                                            index
                                                            ? Border.all(
                                                            color: const Color(
                                                                0xffffa62b),
                                                            width: 5)
                                                            : null,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: const Color(
                                                                  0x40b9b9b9),
                                                              offset:
                                                              Offset(0, 4),
                                                              blurRadius: 4,
                                                              spreadRadius: 4)
                                                        ],
                                                        color: const Color(
                                                            0xffffffff),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                            snapshot.data.prefixes.isEmpty
                                                                ? snapshot
                                                                .data
                                                                .items[
                                                            index]
                                                                .name.replaceAll(".png", "")
                                                                : snapshot
                                                                .data
                                                                .prefixes[
                                                            index]
                                                                .name,
                                                            style: GoogleFonts.quicksand(
                                                                color: const Color(
                                                                    0xff1a1b41),
                                                                fontWeight:
                                                                FontWeight
                                                                    .w400,
                                                                fontStyle:
                                                                FontStyle
                                                                    .normal,
                                                                fontSize:
                                                                height *
                                                                    0.02),
                                                            textAlign:
                                                            TextAlign.left),
                                                      )),
                                                ));
                                          },
                                        );
                                      } else
                                        return Center(
                                            child: CircularProgressIndicator());
                                    }),
                              ),
                            ),
                          )
                        ]),
                  )),
            )
          ])),
        ));
  }

  Future<ListResult> getDetailsFromStorage(String name) async {
    return await FirebaseStorage.instance.ref(name).listAll();
  }

  void setCentralImage(Reference item) {
    item.getDownloadURL().then((value) {
      setState(() {
        centralImageUrl = value;
      });
    });
  }
}
