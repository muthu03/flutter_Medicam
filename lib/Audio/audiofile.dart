import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

class Audiofile extends StatefulWidget {
  String value;
  Audiofile({required this.value});
  @override
  AudiofileState createState() => AudiofileState();
}

enum TtsState { playing, stopped }

class AudiofileState extends State<Audiofile> {
  late FlutterTts _flutterTts;
  String? _tts;
  TtsState _ttsState = TtsState.stopped;

  @override
  void initState() {
    super.initState();
    setState(() {
      this._tts = widget.value;
    });
    initTts();
  }

  @override
  void dispose() {
    super.dispose();
    _flutterTts.stop();
  }

  initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        _ttsState = TtsState.playing;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        _ttsState = TtsState.stopped;
      });
    });

    _flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        _ttsState = TtsState.stopped;
      });
    });

    _flutterTts.setErrorHandler((message) {
      setState(() {
        print("Error: $message");
        _ttsState = TtsState.stopped;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: const Text('Flutter TTS')),
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(children: [button()]),
            )));
  }

  Widget button() {
    if (_ttsState == TtsState.stopped) {
      return TextButton(onPressed: speak, child: const Text('Play'));
    } else {
      return TextButton(onPressed: stop, child: const Text('Stop'));
    }
  }

  Future speak() async {
    await _flutterTts.setVolume(1);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1);

    if (_tts != null) {
      if (_tts!.isNotEmpty) {
        await _flutterTts.speak(_tts!);
      }
    }
  }

  Future stop() async {
    var result = await _flutterTts.stop();
    if (result == 1) {
      setState(() {
        _ttsState = TtsState.stopped;
      });
    }
  }
}
