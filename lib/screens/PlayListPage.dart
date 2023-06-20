import 'package:cloudjams/screens/commons/Playlist.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'commons/PlayerButtons.dart';

class PlayListPage extends StatefulWidget {
  const PlayListPage(this._player, {super.key});

  final AudioPlayer _player;

  @override
  State<PlayListPage> createState() => _PlayListPageState();
}

class _PlayListPageState extends State<PlayListPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(child: Playlist(widget._player)),
              PlayerButtons(widget._player)
            ],
          ),
        ),
      ),
    );
  }
}
