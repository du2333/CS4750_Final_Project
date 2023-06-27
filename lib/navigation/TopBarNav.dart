import 'package:cloudjams/screens/LibraryPage.dart';
import 'package:cloudjams/screens/PlayListPage.dart';
import 'package:cloudjams/screens/PlayingPage.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class TopBarNavigation extends StatefulWidget {
  const TopBarNavigation({super.key, required this.player, required this.audioQuery});

  final AudioPlayer player;
  final OnAudioQuery audioQuery;

  @override
  State<TopBarNavigation> createState() => _TopBarNavigationState();
}

class _TopBarNavigationState extends State<TopBarNavigation> {

  //Destructor
  @override
  void dispose() {
    widget.player.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const TabBar(
            tabs: <Widget>[
              Tab(
                child: Icon(Icons.playlist_play_rounded),
              ),
              Tab(
                child: Icon(Icons.music_note_rounded),
              ),
              Tab(
                child: Icon(Icons.library_music_rounded),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                PlayListPage(widget.player),
                PlayingPage(widget.player),
                LibraryPage(widget.audioQuery, widget.player),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
