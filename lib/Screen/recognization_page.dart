import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../Audio/audiofile.dart';

class RecognizePage extends StatefulWidget {
  final String? path;
  const RecognizePage({Key? key, this.path}) : super(key: key);

  @override
  State<RecognizePage> createState() => _RecognizePageState();
  // State<RecognizePage> createState() => _MyAppState();
  // State<RecognizePage> createState() => _FlutterTTS();
}

class _RecognizePageState extends State<RecognizePage> {
  bool _isBusy = false;

  TextEditingController controller = TextEditingController();
  TextEditingController contransoller = TextEditingController();

  @override
  void initState() {
    super.initState();

    final InputImage inputImage = InputImage.fromFilePath(widget.path!);

    processImage(inputImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("recognized page")),
        body: _isBusy == true
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      if (controller.text != null)
                        Container(
                          child: Text(
                            controller.text.toUpperCase(),
                            style: TextStyle(
                                height: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      SizedBox(
                        height: 20,
                      ),
                      if (contransoller.text != null)
                        Container(
                          child: Text(contransoller.text),
                        ),
                      SizedBox(
                        height: 20,
                      ),
                      RaisedButton(
                        onPressed: () => {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) =>
                                  Audiofile(value: contransoller.text),
                            ),
                          )
                        },
                        child: Text('OnPress'),
                      ),
                    ],
                  ),
                ),
              ));
  }

  void processImage(InputImage image) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    setState(() {
      _isBusy = true;
    });

    log(image.filePath!);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(image);

    //controller.text = recognizedText.text;

    String a = recognizedText.text;
    a = a.replaceAll("\n", "<br>");
    a = a.replaceAll("&", "*");

    var temp = new Map();
    var response = new Map();

    print(a);
    var url = Uri.parse('http://10.0.2.2:5000/api?query=' + a);
    response[0] = await http.get(url);
    print('${response[0].body}');

    setState(() {
      controller.text = '${response[0].body}';
    });

    //this is for text scrapping
    String sam;
    sam = controller.text;
    var urll = Uri.parse('http://10.0.2.2:5000/search?query=' + sam);
    response[0] = await http.get(urll);
    print('${response[0].body}');

    setState(() {
      contransoller.text = '${response[0].body}';
    });

    ///End busy state
    setState(() {
      _isBusy = false;
    });
  }
}
