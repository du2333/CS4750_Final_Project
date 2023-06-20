import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloudjams/screens/LibraryPage.dart';
import 'package:cloudjams/screens/PlayListPage.dart';
import 'package:cloudjams/screens/PlayingPage.dart';
import 'package:just_audio/just_audio.dart';

import '../models/Song.dart';

class TopBarNavigation extends StatefulWidget {
  const TopBarNavigation({super.key});

  @override
  State<TopBarNavigation> createState() => _TopBarNavigationState();
}

class _TopBarNavigationState extends State<TopBarNavigation> {
  // 初始化播放器
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    //增加播放列表
    _player
        .setAudioSource(ConcatenatingAudioSource(children: [
      AudioSource.asset('assets/audios/Call of Silence 泽野弘之.mp3',
          tag: Song(
            title: 'Call of Silence 泽野弘之',
            artwork: '',
          )),
      AudioSource.asset('assets/audios/Curtain_Call_-_清水翔太.mp3',
          tag: Song(
            title: 'Curtain_Call_-_清水翔太',
            artwork: '',
          )),
      AudioSource.asset('assets/audios/Departures ~あなたにおくるアイの歌~ - EGOIST.mp3',
          tag: Song(
            title: 'Departures ~あなたにおくるアイの歌~ - EGOIST',
            artwork: '',
          )),
      AudioSource.asset('assets/audios/from Y to Y - H△G.mp3',
          tag: Song(
            title: 'from Y to Y - H△G',
            artwork: '',
          )),
      AudioSource.asset('assets/audios/glow-H△G.mp3',
          tag: Song(
            title: 'glow-H△G',
            artwork: '',
          )),
      AudioSource.asset('assets/audios/gravityWall - Tielle.mp3',
          tag: Song(
            title: 'gravityWall - Tielle',
            artwork: '',
          )),
      AudioSource.asset('assets/audios/halca - センチメンタルクライシス.mp3',
          tag: Song(
            title: 'halca - センチメンタルクライシス',
            artwork: '',
          )),
      AudioSource.asset('assets/audios/Headlight - MONKEY MAJIK.mp3',
          tag: Song(
            title: 'Headlight - MONKEY MAJIK',
            artwork: '',
          )),
      AudioSource.asset('assets/audios/inside you - milet.mp3',
          tag: Song(
            title: 'inside you - milet',
            artwork: '',
          )),
      AudioSource.asset('assets/audios/Voices_of_the_Chord.mp3',
          tag: Song(
            title: 'Voices_of_the_Chord',
            artwork: '',
          )),
    ]))
        .catchError((error) {
      log("An error occurred $error");
    });
  }

  //Destructor
  @override
  void dispose() {
    _player.dispose();
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
                //TODO 换图标
                child: Text("PlayList"),
              ),
              Tab(
                //TODO 换图标
                child: Text("Playing"),
              ),
              Tab(
                //TODO 换图标
                child: Text("Library"),
              ),
            ],
          ),
        ),
        body:TabBarView(
          children: <Widget>[
            PlayListPage(_player),
            PlayingPage(_player),
            LibraryPage(),
          ],
        ),
      ),
    );
  }
}
