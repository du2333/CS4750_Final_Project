import 'package:cloudjams/screens/commons/PlayerButtons.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayingPage extends StatefulWidget {
  const PlayingPage(this._player, {super.key});

  final AudioPlayer _player;

  @override
  State<PlayingPage> createState() => _PlayingPageState();
}

class _PlayingPageState extends State<PlayingPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: PlayerButtons(widget._player),
    );
  }
}
