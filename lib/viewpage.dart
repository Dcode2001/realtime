import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:realtime/insertpage.dart';

class viewpage extends StatefulWidget {
  const viewpage({Key? key}) : super(key: key);

  @override
  State<viewpage> createState() => _viewpageState();
}

class _viewpageState extends State<viewpage> {
  late StreamSubscription subscription = StreamSubscription as StreamSubscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;


  List l = [];

  @override
  void initState() {
    super.initState();
    loaddata();

    getConnectivity();
  }
  getConnectivity() =>
      subscription = Connectivity().onConnectivityChanged.listen(
            (ConnectivityResult result) async {
          isDeviceConnected = await InternetConnectionChecker().hasConnection;
          if (!isDeviceConnected && isAlertSet == false) {
            showDialogBox();
            setState(() => isAlertSet = true);
          }
        },
      );

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  loaddata() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref(
        "contact_save_realtime");

    DatabaseEvent de = await ref.once();

    DataSnapshot ds = de.snapshot;

    print(ds.value);

    Map map = ds.value as Map;

    map.forEach((key, value) {
      l.add(value);
    });

    setState(() {
      print(l);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Page & Check Internet"),
      ),
      body: l.length > 0
          ? ListView.builder(
        itemCount: l.length,
        itemBuilder: (context, index) {
          Map m = l[index];

          return ListTile(
            onTap: () {
              showDialog(builder: (context1) {
                return SimpleDialog(
                  title: Text("Select Choice"),
                  children: [
                    ListTile(onTap: () {
                      Navigator.pop(context1);
                      
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                        return insertpage(m: m);
                      },
                      ));
                    },
                    title: Text("Update"),
                    ),
                    
                    ListTile(onTap: () {
                      Navigator.pop(context1);

                      DatabaseReference ref = FirebaseDatabase.instance.ref("contact_save_realtime").child("${m['UserId']}");

                      ref.remove();

                      Fluttertoast.showToast(
                          msg: "Deleted....",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 2,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );

                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                        return viewpage();
                      },
                      ));
                    },
                    title: Text("Delete"),
                    ),
                  ],
                );
              },context: context);
            },
            title: Text("${m['name']}"),
            subtitle: Text("${m['contact']}"),
          );
        },
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return insertpage();
            },
          ));
        },
        child: Icon(Icons.add_box_outlined),
      ),
    );
  }

  showDialogBox() => showCupertinoDialog<String>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: const Text('No Connection'),
      content: const Text('Please check your internet connectivity'),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            Navigator.pop(context, 'Cancel');
            setState(() => isAlertSet = false);
            isDeviceConnected =
            await InternetConnectionChecker().hasConnection;
            if (!isDeviceConnected && isAlertSet == false) {
              showDialogBox();
              setState(() => isAlertSet = true);
            }
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
