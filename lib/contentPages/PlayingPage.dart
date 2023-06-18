import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PlayingPage extends StatefulWidget {
  const PlayingPage({super.key});

  @override
  State<PlayingPage> createState() => _PlayingPageState();
}

class _PlayingPageState extends State<PlayingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IconButton(
          icon: Icon(Icons.play_circle),
          onPressed: () async {
            final player = AudioPlayer();
            await player.play(AssetSource('1.mp3'));
          },
        ),
      ),
    );
  }
}
