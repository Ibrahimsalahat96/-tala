import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

import 'package:image_picker/image_picker.dart';

import 'helper.dart';

class AiPage extends StatefulWidget {

  @override
  _AiPageState createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  ImageClassificationHelper? imageClassificationHelper;
  final imagePicker = ImagePicker();
  
  String? imagePath;
  img.Image? image;
  Map<String, double>? classification;

  var top = null; // object // u can use top.key and top.value to access it

  @override
  void initState() {
    imageClassificationHelper = ImageClassificationHelper();
    imageClassificationHelper!.initHelper(label_path: "assets/ai/mobilenet.tflite" , model_path: "assets/ai/labels.txt");
    super.initState();
  }


Future<void> processImage() async {
    if (imagePath != null) {
      // Read image bytes from file
      final imageData = File(imagePath!).readAsBytesSync();

      // Decode image using package:image/image.dart
      image = img.decodeImage(imageData);
      setState(() {});
      classification = await imageClassificationHelper?.inferenceImage(image!);
      if (classification != null){
       
       top = (classification!.entries.toList()
              ..sort(
                (a, b) => a.value.compareTo(b.value),
              ))
            .reversed.first;
            // top_name = top.value.toString();
            // top_rate = top.key.toString;
            // print("not empty ${top.toString()}");
              }
      else print("empty");
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Plants AI",
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: 
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children : [TextButton(
              
              onPressed: () async { 
                      final result = await imagePicker.pickImage( 
                      source: ImageSource.camera,
                    );

                    imagePath = result?.path;
                    setState(() {});
                    processImage();
               },
              child: Text(
                "SELECT IMAGE" ,
                style: TextStyle(color: Colors.white),),) ,
                top!=null? Column(
                  children: [
                    Text("${top.key.toString()}" , style: TextStyle(fontSize: 25 , fontWeight: FontWeight.bold , color: Colors.orangeAccent),) ,
                    Text("${(100*top.value).toStringAsFixed(0)}%" ,  style: TextStyle(fontSize: 25 , fontWeight: FontWeight.bold , color: Colors.redAccent ),)
                  ],
                ): SizedBox()
                ]
          )
      ),
    );
  }
}