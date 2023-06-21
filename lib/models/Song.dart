import 'package:just_audio/just_audio.dart';

class Song{
  final String title;
  final String? artwork;

  Song({required this.title, this.artwork = 'assets/images/music-placeholder.png'});

  //Hardcoded播放列表
  static var playlist = ConcatenatingAudioSource(children: [
    AudioSource.asset('assets/audios/Call of Silence 泽野弘之.mp3',
        tag: Song(
          title: 'Call of Silence 泽野弘之',
          //artwork: '',
        )),
    AudioSource.asset('assets/audios/Curtain_Call_-_清水翔太.mp3',
        tag: Song(
          title: 'Curtain_Call_-_清水翔太',
          //artwork: '',
        )),
    AudioSource.asset('assets/audios/Departures ~あなたにおくるアイの歌~ - EGOIST.mp3',
        tag: Song(
          title: 'Departures ~あなたにおくるアイの歌~ - EGOIST',
          //artwork: '',
        )),
    AudioSource.asset('assets/audios/from Y to Y - H△G.mp3',
        tag: Song(
          title: 'from Y to Y - H△G',
          //artwork: '',
        )),
    AudioSource.asset('assets/audios/glow-H△G.mp3',
        tag: Song(
          title: 'glow-H△G',
          //artwork: '',
        )),
    AudioSource.asset('assets/audios/gravityWall - Tielle.mp3',
        tag: Song(
          title: 'gravityWall - Tielle',
          // artwork: '',
        )),
    AudioSource.asset('assets/audios/halca - センチメンタルクライシス.mp3',
        tag: Song(
          title: 'halca - センチメンタルクライシス',
          // artwork: '',
        )),
    AudioSource.asset('assets/audios/Headlight - MONKEY MAJIK.mp3',
        tag: Song(
          title: 'Headlight - MONKEY MAJIK',
          // artwork: '',
        )),
    AudioSource.asset('assets/audios/inside you - milet.mp3',
        tag: Song(
          title: 'inside you - milet',
          // artwork: '',
        )),
    AudioSource.asset('assets/audios/Voices_of_the_Chord.mp3',
        tag: Song(
          title: 'Voices_of_the_Chord',
          // artwork: '',
        )),
  ]);
}