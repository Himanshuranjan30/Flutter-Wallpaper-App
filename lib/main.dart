import 'dart:convert';
import 'package:demo/shared/loading.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_shake_plugin/flutter_shake_plugin.dart';
import 'package:image_downloader/image_downloader.dart';
import './shared/loading.dart';
import 'package:swipedetector/swipedetector.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterShakePlugin _shakePlugin;
  List data = []; //List to store urls of images
  String _search = 'nature';
  int index = 0;
  int count = 100;
  int c = 0; // c:no of left swipes
  int r = 0; // r: no of right swipes
  bool isloading = false; // parameter to set the loading icon

  @override
  void initState() {
    super.initState();
    // shake plugin that sets the working of the app when the screen is shaked!
    _shakePlugin = FlutterShakePlugin(
      onPhoneShaken: () {
        //do stuff on phone shake
        setState(() {
          if (c <
              10) //if we shake the screen before even seeing 10 photos i.e without 10 left swipes.
          {
            data.removeRange(0, 9);

            index = index + ((10 - c) - 1);
            c = 0; // setting wipe count to 0 again.
            isloading = true;
          }

          data.removeRange(0, 9);
          c = 0; // setting wipe count to 0 again.
          index = index + 1;
          isloading = true;
        });
      },
    )..startListening();
  }

  @override
  void dispose() {
    super.dispose();
    _shakePlugin.stopListening(); // stopping the shake plugin
  }

  Future<String> getjsondata() async {
    try {
      var response = await http.get(
          'https://api.unsplash.com/search/photos?per_page=$count&client_id='APIKEY&query=$_search');

      setState(() {
        var converted = json.decode(response.body);
        data = converted['results'];
        isloading = false;
      });
    } catch (e) {}
    return 'success';
  }

  void saveImage(int i) async {
    var url = data[i]['urls']['small'].toString();

    await ImageDownloader.downloadImage(url); // saving image to the gallery
  }

  @override
  Widget build(BuildContext context) {
    getjsondata();

    return isloading
        ? Loading()
        : GestureDetector(
            child: SwipeDetector(
              child: Container(
                child: Image.network(
                  data[index]['urls']['small'],
                  fit: BoxFit.fill,
                ),
              ),
              onSwipeLeft: () {
                c = c + 1; //incrementing swipe count on every swipe

                if (c >= 10)
                  setState(() {
                    index = index;
                  });
                else
                  setState(() {
                    index = index + 1;
                  });
              },
              onSwipeRight: () {
                r = r + 1; //incrementing swipe count on every swipe
                if (index > 0) {
                  setState(() {
                    index = index - 1;
                    c = c -
                        r; //incase we use right swipe while going through images and we left swipe to go back again then the left swipe must not counted again.
                  });
                } else
                  index = index;
              },
              swipeConfiguration: SwipeConfiguration(
                  verticalSwipeMinVelocity: 100.0,
                  verticalSwipeMinDisplacement: 50.0,
                  verticalSwipeMaxWidthThreshold: 100.0,
                  horizontalSwipeMaxHeightThreshold: 50.0,
                  horizontalSwipeMinDisplacement: 50.0,
                  horizontalSwipeMinVelocity: 100.0), //Swipe Config
            ),
            onDoubleTap: () => {
              saveImage(index),
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('IMAGE SAVED!'),
                  );
                },
              )
            }, // image save functionality on double tap with an alert!
          );
  }
}
