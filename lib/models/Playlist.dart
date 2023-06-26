import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Song {
  String playlistName;
  SongModel song;

  Song(this.playlistName, this.song);

  static ConcatenatingAudioSource convertToPlaylist(List<SongModel> songs, String playlistName) {
    List<AudioSource> sources = [];
    for (var song in songs) {
      sources.add(AudioSource.uri(Uri.parse(song.uri!), tag: Song(playlistName, song)));
    }
    return ConcatenatingAudioSource(children: sources);
  }
}