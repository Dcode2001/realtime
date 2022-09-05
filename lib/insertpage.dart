import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:realtime/viewpage.dart';

class insertpage extends StatefulWidget {
  // const insertpage(Map m, {Key? key}) : super(key: key);

  Map? m ;


  insertpage({this.m});

  @override
  State<insertpage> createState() => _insertpageState();
}

class _insertpageState extends State<insertpage> {

  late StreamSubscription subscription = StreamSubscription as StreamSubscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;


  TextEditingController tname = TextEditingController();
  TextEditingController tcontact = TextEditingController();


  @override
  void initState() {
    super.initState();

    if(widget.m!=null)
      {
        tname.text = widget.m!['name'];
        tcontact.text = widget.m!['contact'];
      }

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
  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
      appBar: AppBar(title: Text("Insertpage & Check Internet")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: tname,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  label: Text("Name"),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                controller: tcontact,
                maxLength: 10,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  label: Text("Contact"),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
              SizedBox(
                height: 15,
              ),

              ElevatedButton(onPressed: () {

                // FirebaseDatabase database = FirebaseDatabase.instance;

                String name = tname.text;
                String contact = tcontact.text;

                if(widget.m == null)
                {
                  DatabaseReference ref = FirebaseDatabase.instance.ref("contact_save_realtime").push();

                  String? userid = ref.key;

                  Map m = {"name":name,"contact":contact,"UserId":userid};

                  ref.set(m);

                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                    return viewpage();
                  },));

                  Fluttertoast.showToast(
                      msg: "Saved",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 2,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      fontSize: 16.0
                  );
                }
                else
                {
                  String userid = widget.m!['UserId'];

                  DatabaseReference ref = FirebaseDatabase.instance.ref("contact_save_realtime").child(userid);

                  Map m = {"name":name,"contact":contact,"UserId":userid};

                  ref.set(m);

                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                    return viewpage();
                  },));

                  Fluttertoast.showToast(
                      msg: "Updated....",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 2,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      fontSize: 16.0
                  );
                }


              }, child: widget.m == null ? Text("Save") : Text("Update"))
            ],
          ),
        ),
      ),
    ), onWillPop: goback);
  }

  Future<bool> goback()
  {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return viewpage();
      },));
     return Future.value();
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
