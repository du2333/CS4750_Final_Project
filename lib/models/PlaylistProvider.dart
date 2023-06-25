import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlaylistProvider extends ChangeNotifier {
  Map<String, List<SongModel>> playlists = {};

  //TODO testing purpose
  PlaylistProvider() {
    createPlaylist('default');
  }

  void createPlaylist(String name) {
    playlists[name] = [];
    notifyListeners();
  }

  void addSongsToPlaylist(String playlistName, List<SongModel> songs) {
    playlists[playlistName]?.addAll(songs);
    notifyListeners();
  }

  void deletePlaylist(String playlistName) {
    playlists.remove(playlistName);
    notifyListeners();
  }

  void addSongToPlaylist(String playlistName, SongModel song) {
    playlists[playlistName]?.add(song);
    notifyListeners();
  }

  void removeSongFromPlaylist(String playlistName, SongModel song) {
    playlists[playlistName]?.remove(song);
    notifyListeners();
  }
}
