import 'dart:developer';

import 'package:cloudjams/screens/PLayerButtons.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayingPage extends StatefulWidget {
  const PlayingPage({super.key});

  @override
  State<PlayingPage> createState() => _PlayingPageState();
}

class _PlayingPageState extends State<PlayingPage> {
  // 初始化播放器
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    //增加播放列表
    //TODO 创建一个播放列表的class
    _player
        .setAudioSource(ConcatenatingAudioSource(children: [
      AudioSource.asset('assets/audios/Call of Silence 泽野弘之.mp3'),
      AudioSource.asset('assets/audios/Curtain_Call_-_清水翔太.mp3'),
      AudioSource.asset('assets/audios/Departures ~あなたにおくるアイの歌~ - EGOIST.mp3'),
      AudioSource.asset('assets/audios/from Y to Y - H△G.mp3'),
      AudioSource.asset('assets/audios/glow-H△G.mp3'),
      AudioSource.asset('assets/audios/gravityWall - Tielle.mp3'),
      AudioSource.asset('assets/audios/halca - センチメンタルクライシス.mp3'),
      AudioSource.asset('assets/audios/Headlight - MONKEY MAJIK.mp3'),
      AudioSource.asset('assets/audios/inside you - milet.mp3'),
      AudioSource.asset('assets/audios/Voices_of_the_Chord.mp3'),
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
    return Center(
      child: PlayerButtons(_player),
    );
  }
}
