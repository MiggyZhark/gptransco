import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class LyricDisplay extends StatefulWidget {
  @override
  _LyricDisplayState createState() => _LyricDisplayState();
}

class _LyricDisplayState extends State<LyricDisplay> {
  List<Map<String, dynamic>> lyrics = [
    {'line': "Your morning eyes", 'delay': 3000},
    {'line': "I could stare like watching stars", 'delay': 6000},
    {
      'line': "I could walk you by and I'll tell without a thought",
      'delay': 100000
    },
    {'line': "You'll be mine would you mind", 'delay': 25000},
    {'line': "If I took your hand tonight", 'delay': 25000},
    {'line': "Know you're all that I want is life", 'delay': 25000},
    {'line': "I'll imagine we fell in love", 'delay': 3500},
    {'line': "I'll nap under moonlight skies with you", 'delay': 3500},
    {'line': "I think I'll picture us, you with the waves", 'delay': 3500},
    {'line': "The oceans colors on your face", 'delay': 2000},
    {'line': "I'll leave my heart with your air", 'delay': 2000},
    {'line': "so let me fly with you", 'delay': 2000},
    {'line': "will you be forever with me?", 'delay': 2000},
    // Add more lyrics here
  ];

  int currentLyricIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startLyrics();
  }

  void startLyrics() {
    _timer = Timer.periodic(
        Duration(milliseconds: lyrics[currentLyricIndex]['delay']), (timer) {
      setState(() {
        currentLyricIndex++;
        if (currentLyricIndex >= lyrics.length) {
          _timer?.cancel(); // Stop when we reach the end
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Blue - Yung Kai", style: TextStyle(color: Colors.white)),
      ),
      body: Container(height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/test/anime.jpg"),fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 180),
          child: FadeIn(
            key: ValueKey(currentLyricIndex),
            // ensures a new animation for each lyric line
            duration: Duration(milliseconds: 800),
            // Customize fade-in duration as needed
            child: Text(
              lyrics[currentLyricIndex]['line'],
              style: TextStyle(fontSize: 24, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
