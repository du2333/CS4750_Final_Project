import 'package:just_audio/just_audio.dart';

import 'Song.dart';

class Playerlist {
  String playlistName;
  ConcatenatingAudioSource playlist;

  Playerlist({required this.playlistName, required this.playlist});

  void add(String path, Song song) {
    playlist.add(AudioSource.file(path));
  }
}
