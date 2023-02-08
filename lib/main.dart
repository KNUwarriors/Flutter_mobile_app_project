//////////////////////////////
//
// 2019, roipeker.com
// screencast - demo simple image:
// https://youtu.be/EJyRH4_pY8I
//
// screencast - demo snapshot:
// https://youtu.be/-LxPcL7T61E
//
//////////////////////////////

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:cross_file_image/cross_file_image.dart';

void main() => runApp(const MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  XFile? imageFile;
  GlobalKey imageKey = GlobalKey();
  GlobalKey paintKey = GlobalKey();
  List<String> toneList=[];
  int cnt=0;
  String tone="";

  // based on useSnapshot=true ? paintKey : imageKey ;
  // this key is used in this example to keep the code shorter.
  late GlobalKey currentKey;

  final StreamController<Color> _stateController = StreamController<Color>();
  img.Image? photo;

  @override
  void initState() {
    currentKey = imageKey;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xD9D9D9),
          title: Text("What's your color", style: TextStyle(fontSize: 25,
              color: Colors.black,
              fontFamily: 'sendFlowers',
              fontWeight: FontWeight.normal),),
          centerTitle: true,
          leading: Icon(Icons.menu, color: Colors.black,),
          elevation: 0.2,),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 50,),
              StreamBuilder(
                  initialData: Colors.white,
                  stream: _stateController.stream,
                  builder: (buildContext, snapshot) {
                    Color selectedColor = snapshot.data as Color ?? Colors.green;
                    return Stack(
                      children: [
                        RepaintBoundary(
                          key: paintKey,
                          child: GestureDetector(
                            onPanDown: (details) {
                              searchPixel(details.globalPosition);
                              //print("pandown");
                            },
                            onPanUpdate: (details) {
                              searchPixel(details.globalPosition);
                              //print("panup");
                            },
                            child: Center(
                              child: Column(
                                children: [
                                  if(imageFile != null)
                                    Image(image: XFileImage(imageFile!),
                                      key: imageKey,),
                                  if(imageFile == null)
                                    Container(
                                      width: 300,
                                      height: 300,
                                      color: Colors.grey,
                                    ),
                                  SizedBox(height: 20,),
                                  Container(
                                    //margin: const EdgeInsets.all(70),
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: selectedColor!,),
                                  ),
                                  if(photo != null)
                                    Container(
                                        child: Column(
                                            children:[
                                              Text('${selectedColor}',
                                                  style: const TextStyle(
                                                      color: Colors.black, fontSize: 17)),
                                              SizedBox(height: 15,),
                                              Text('${tone}',style: const TextStyle(
                                                  color: Colors.black, fontSize: 20)),
                                            ]
                                        )

                                    ),
                                  SizedBox(height: 50,),

                                  OutlinedButton(onPressed: () {
                                    getImage(ImageSource.gallery);
                                  },
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        side: BorderSide(
                                          color: Colors.black,
                                        ),
                                        minimumSize: Size(155, 50),
                                        maximumSize: Size(155, 100),
                                      ),
                                      child: Container(
                                        child: Row(
                                          children: [
                                            Text("Select picture   ",
                                              style: TextStyle(fontSize: 13,
                                                  color: Colors.black),),
                                            Icon(Icons.add, size: 30,),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
            ],

          ),
        ),
      ),
    );
  }

  void searchPixel(Offset globalPosition) async {
    if (photo == null) {
      await (loadImageBundleBytes());
    }
    _calculatePixel(globalPosition);
  }

  void _calculatePixel(Offset globalPosition) {
    RenderBox box = currentKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(globalPosition);

    double px = localPosition.dx;
    double py = localPosition.dy;


    double widgetScale = box.size.width / photo!.width;
    //print(py);
    px = (px / widgetScale);
    py = (py / widgetScale);


    img.Color a = photo!.getPixelCubic(px, py);
    //print(a);
    // String k = a.toString();
    // print(k);
    //print(a);
    //img.Pixel pixel32 = photo!.getPixelSafe(px.toInt(), py.toInt());
    //print(pixel32);
    //int t =
    //Iterable<R> cast<R>() => Iterable.castFrom<E, R>(this);
    //int hex = abgrToArgb(a as int);
    int a1 = a[0].toInt();
    int a2 = a[1].toInt();
    int a3 = a[2].toInt();
    int a4 = a[3].toInt();

    Color b = Color.fromARGB(a4, a1, a2, a3);
    _stateController.add(b);
    getTone(b);
    listToString(toneList);
  }

  Future loadImageBundleBytes() async {
    final path = imageFile!.path;
    final bytes = await File(path).readAsBytes();
    photo = img.decodeImage(bytes)!;
  }

  void getImage(ImageSource source) async {
    photo = null;
    imageFile = null;
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        imageFile = pickedImage;
        setState(() {});
      }
    } catch (e) {
      imageFile = null;
      setState(() {});
    }
  }


  void getTone(Color color){
    HSLColor hsl= HSLColor.fromColor(color);
    cnt=0;
    toneList=[];
    var lightness=hsl.lightness*100;
    var saturation=hsl.saturation*100;
    if (35<=lightness && lightness<=55 && saturation>=90 && saturation<=100){
      toneList.add("Vivid");
      cnt+=1;
    }
    if (70<=lightness && lightness<=90 && saturation>=70 && saturation<=97){
      toneList.add("Light");
      cnt+=1;
    }
    if (60<=lightness && lightness<=70 && saturation>=70 && saturation<=97){
      toneList.add("Bright");
      cnt+=1;
    }
    if (35<=lightness && lightness<=55 && saturation>=60 && saturation<=85){
      toneList.add("Strong");
      cnt+=1;
    }
    if (15<=lightness && lightness<=40 && saturation>=70 && saturation<=97){
      toneList.add("Deep");
      cnt+=1;
    }
    if (75<=lightness && lightness<=100 && saturation>=40 && saturation<=70){
      toneList.add("Pale");
      cnt+=1;
    }
    if (55<=lightness && lightness<=75 && saturation>=40 && saturation<=70){
      toneList.add("Soft");
      cnt+=1;
    }
    if (35<=lightness && lightness<=55 && saturation>=40 && saturation<=70){
      toneList.add("Dull");
      cnt+=1;
    }
    if (15<=lightness && lightness<=35 && saturation>=40 && saturation<=70){
      toneList.add("Dark");
      cnt+=1;
    }
    if (80<=lightness && lightness<=100 && saturation>=0 && saturation<=45){
      toneList.add("Very Pale");
      cnt+=1;
    }
    if (60<=lightness && lightness<=85 && saturation>=10 && saturation<=45){
      toneList.add("Light Grayish");
      cnt+=1;
    }
    if (40<=lightness && lightness<=65 && saturation>=10 && saturation<=45){
      toneList.add("Grayish");
      cnt+=1;
    }
    if (15<=lightness && lightness<=40 && saturation>=20 && saturation<=45){
      toneList.add("Dark Grayish");
      cnt+=1;
    }
    if (0<=lightness && lightness<=20 && saturation>=0 && saturation<=45){
      toneList.add("Very Dark");
      cnt+=1;
    }
    if(cnt>0) {
      print(lightness);
      print(saturation);
      print(toneList);
    }
    else{
      print("없다");
    }
  }

  void listToString(List<String> toneList){
    tone="";
    if(cnt>0){
      tone="Tone: ";
      for (String tonevar in toneList){
        if (tonevar == toneList[toneList.length -1]) {
          tone+=tonevar;
        }
        else{
          tone+=tonevar+", ";
        }
      }

    }
    else{
      tone="DB에 존재하지 않는 색깔입니다 ;ㅅ;";
    }
  }

}