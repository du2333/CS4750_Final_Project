import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Playerlist {
  String playlistName;
  ConcatenatingAudioSource playlist;

  Playerlist({required this.playlistName, required this.playlist});

  void add(SongModel song) {
    playlist.add(AudioSource.uri(Uri.parse(song.uri!), tag: song));
  }

  static ConcatenatingAudioSource createPlaylist(List<SongModel> songs) {
    List<AudioSource> sources = [];
    for (var song in songs) {
      sources.add(AudioSource.uri(Uri.parse(song.uri!), tag: song));
    }
    return ConcatenatingAudioSource(children: sources);
  }

  int get count => playlist.length;
}
