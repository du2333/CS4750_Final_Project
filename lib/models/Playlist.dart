import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Playlist {
  String name;
  List<SongModel> songs;

  Playlist(this.name, this.songs);

  static ConcatenatingAudioSource convertToPlaylist(List<SongModel> songs) {
    List<AudioSource> sources = [];
    for (var song in songs) {
      sources.add(AudioSource.uri(Uri.parse(song.uri!), tag: song));
    }
    return ConcatenatingAudioSource(children: sources);
  }
}