import 'dart:async';
import 'dart:math';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:mpmed_doctor/authOtp/theme.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechScreen extends StatefulWidget {
  static const String routeName = '/speech_screen';

  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  bool _hasSpeech = false;
  bool _logEvents = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = 'fa_IR';
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();

  @override
  void initState() {
    super.initState();
  }

  /// This initializes SpeechToText. That only has to be done
  /// once per application, though calling it again is harmless
  /// it also does nothing. The UX of the sample app ensures that
  /// it can only be called once.
  Future<void> initSpeechState() async {
    _logEvent('Initialize');
    var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: true,
        finalTimeout: Duration(milliseconds: 0));
    // if (hasSpeech) {
    //   // Get the list of languages installed on the supporting platform so they
    //   // can be displayed in the UI for selection by the user.
    //   _localeNames = await speech.locales();

    //   var systemLocale = await speech.systemLocale();
    //   _currentLocaleId = systemLocale?.localeId ?? '';
    // }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        // Container(
        //   child: Column(
        //     children: <Widget>[
        //       InitSpeechWidget(_hasSpeech, initSpeechState),
        //       SpeechControlWidget(_hasSpeech, speech.isListening,
        //           startListening, stopListening, cancelListening),
        //       SessionOptionsWidget(_currentLocaleId, _switchLang,
        //           _localeNames, _logEvents, _switchLogging),
        //     ],
        //   ),
        // ),
        Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: ListTile(
                          leading: IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                                color: MyColors.primaryColorLight.withAlpha(20),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: MyColors.primaryColor,
                                size: 16,
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          title: Text('پردازش صدای شما',style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        ),
                      ),
        Expanded(
          flex: 4,
          child: RecognitionResultsWidget(
            lastWords: lastWords,
            level: level,
            speech: speech,
            cancelListening: cancelListening,
            hasSpeech: _hasSpeech,
            isListening: speech.isListening,
            startListening: startListening,
            stopListening: stopListening,
            initSpeechState: initSpeechState,
          ),
        ),
        SpeechStatusWidget(speech: speech),
      ]),
    );
  }

  // This is called each time the users wants to start a new speech
  // recognition session
  void startListening() {
    _logEvent('start listening');
    lastWords = '';
    lastError = '';
    // Note that `listenFor` is the maximum, not the minimun, on some
    // recognition will be stopped before this value is reached.
    // Similarly `pauseFor` is a maximum not a minimum and may be ignored
    // on some devices.
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 5),
        partialResults: true,
        localeId: 'fa_IR',
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setState(() {});
  }

  void stopListening() {
    _logEvent('stop');
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    _logEvent('cancel');
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  /// This callback is invoked each time new recognition results are
  /// available after `listen` is called.
  void resultListener(SpeechRecognitionResult result) {
    _logEvent(
        'Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');
    setState(() {
      lastWords = '${result.recognizedWords}';
    });
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // _logEvent('sound level $level: $minSoundLevel - $maxSoundLevel ');
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    _logEvent(
        'Received error status: $error, listening: ${speech.isListening}');
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  void statusListener(String status) {
    _logEvent(
        'Received listener status: $status, listening: ${speech.isListening}');
    setState(() {
      lastStatus = '$status';
    });
  }

  void _switchLang(selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
    print(selectedVal);
  }

  void _logEvent(String eventDescription) {
    if (_logEvents) {
      var eventTime = DateTime.now().toIso8601String();
      print('$eventTime $eventDescription');
    }
  }

  void _switchLogging(bool? val) {
    setState(() {
      _logEvents = val ?? false;
    });
  }
}

/// Displays the most recently recognized words and the sound level.
class RecognitionResultsWidget extends StatelessWidget {
  RecognitionResultsWidget({
    Key? key,
    required this.lastWords,
    required this.level,
    required this.speech,
    required this.hasSpeech,
    required this.isListening,
    required this.startListening,
    required this.stopListening,
    required this.cancelListening,
    required this.initSpeechState,
  }) : super(key: key);

  final String lastWords;
  final double level;
  final SpeechToText speech;

  final bool hasSpeech;
  final bool isListening;
  final void Function() startListening;
  final void Function() stopListening;
  final void Function() cancelListening;
  final Future<void> Function() initSpeechState;

  final Map<String, HighlightedWord> _highlights = {
    'flutter': HighlightedWord(
        onTap: () => print('flutter'),
        textStyle:
            const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
    'voice': HighlightedWord(
        onTap: () => print('voice'),
        textStyle:
            const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
    'subscribe': HighlightedWord(
        onTap: () => print('subscribe'),
        textStyle:
            const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
    'like': HighlightedWord(
        onTap: () => print('like'),
        textStyle:
            const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
  };

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: <Widget>[
//         Center(
//           child: Text(
//             'Recognized Words',
//             style: TextStyle(fontSize: 22.0),
//           ),
//         ),
//         Expanded(
//           child: Stack(
//             children: <Widget>[
//               Container(
//                 color: Theme.of(context).selectedRowColor,
//                 child: Center(
//                   child: Text(
//                     lastWords,
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//               Positioned.fill(
//                 bottom: 10,
//                 child: Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Container(
//                     width: 40,
//                     height: 40,
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       boxShadow: [
//                         BoxShadow(
//                             blurRadius: .26,
//                             spreadRadius: level * 1.5,
//                             color: Colors.black.withOpacity(.05))
//                       ],
//                       color: Colors.white,
//                       borderRadius: BorderRadius.all(Radius.circular(50)),
//                     ),
//                     child: IconButton(
//                       icon: Icon(Icons.mic),
//                       onPressed: () => null,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

  @override
  Widget build(BuildContext context) {
    hasSpeech ? null : initSpeechState();
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Stack(
          children: <Widget>[
            if (!speech.isListening)
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pop(context, lastWords);
                  },
                  child: Icon(Icons.check),
                ),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AvatarGlow(
                  animate: speech.isListening,
                  glowColor: Theme.of(context).primaryColor,
                  duration: const Duration(milliseconds: 2000),
                  repeatPauseDuration: const Duration(milliseconds: 100),
                  repeat: true,
                  child: FloatingActionButton(
                    onPressed:
                        !hasSpeech || isListening ? null : startListening,
                    child:
                        Icon(speech.isListening ? Icons.mic : Icons.mic_none),
                  ),
                  endRadius: 75.0),
            ),
            if (!speech.isListening)
              Align(
                alignment: Alignment.bottomLeft,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pop(context, '');
                  },
                  child: Icon(Icons.arrow_back),
                ),
              ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 150),
          child: TextHighlight(
            text: lastWords,
            words: _highlights,
            textStyle: const TextStyle(
              fontSize: 32,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

/// Controls to start and stop speech recognition

// class InitSpeechWidget extends StatelessWidget {
//   const InitSpeechWidget(this.hasSpeech, this.initSpeechState, {Key? key})
//       : super(key: key);

//   final bool hasSpeech;
//   final Future<void> Function() initSpeechState;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: <Widget>[
//         TextButton(
//           onPressed: hasSpeech ? null : initSpeechState,
//           child: Text('Initialize'),
//         ),
//       ],
//     );
//   }
// }

/// Display the current status of the listener
class SpeechStatusWidget extends StatelessWidget {
  const SpeechStatusWidget({
    Key? key,
    required this.speech,
  }) : super(key: key);

  final SpeechToText speech;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      color: Theme.of(context).backgroundColor,
      child: Center(
        child: speech.isListening
            ? Text(
                "درحال پردازش صدای شما",
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : Text(
                'پردازش صدای شما متوقف شده است',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
