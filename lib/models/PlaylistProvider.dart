import 'dart:io';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class PlaylistProvider extends ChangeNotifier {
  Map<String, List<SongModel>> playlists = {};

  Database? database;

  //Player status
  String playlistName = '';
  int currentIndex = 0;
  Duration currentDuration = Duration.zero;

  // Initialize the provider
  PlaylistProvider._();


  // 得保证获取了数据后才可以构建实例
  static Future<PlaylistProvider> createInstance() async {
    final provider = PlaylistProvider._();

    // Initialize the database
    await provider.initializeDatabase();

    // Load playlists from the database
    await provider.loadPlaylists();

    // Load play status from the database
    await provider.loadPlayStatus();

    return provider;
  }

  // Initialize the database
  Future<void> initializeDatabase() async {
    // Get the application documents directory
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'playlist.db');

    // Open the database
    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // Create the playlist table
      await db
          .execute('CREATE TABLE playlist (id INTEGER PRIMARY KEY, name TEXT)');
      // Create the song table
      await db.execute(
          'CREATE TABLE song (id TEXT INTEGER KEY, playlist_id TEXT, uri TEXT, album TEXT, album_id INTEGER, artist TEXT, artist_id INTEGER, title TEXT)');
      // Create the play status table
      await db.execute(
          'CREATE TABLE play_status (id INTEGER PRIMARY KEY AUTOINCREMENT, playlist_name TEXT, current_index INTEGER, current_duration INTEGER)');
    });
  }

// Load playlists from the database
  Future<void> loadPlaylists() async {
    Database? db = database;
    if (db == null) return;

    // Clear existing playlists
    playlists = {};

    // Load playlists
    List<Map<String, dynamic>> playlistData = await db.query('playlist');
    for (var data in playlistData) {
      int playlistId = data['id'];
      String playlistName = data['name'];
      playlists[playlistName] = [];

      // Load songs for the playlist
      List<Map<String, dynamic>> songData = await db
          .query('song', where: 'playlist_id = ?', whereArgs: [playlistId]);
      for (var song in songData) {
        playlists[playlistName]!.add(
          SongModel({
            "_id": song['id'],
            "_uri": song['uri'],
            "album": song['album'],
            "album_id": song['album_id'],
            "artist": song['artist'],
            "artist_id": song['artist_id'],
            "title": song['title'],
          }),
        );
      }
    }

    notifyListeners();
  }

  // Load play status from the database
  Future<void> loadPlayStatus() async {
    Database? db = database;
    if (db == null) return;

    // Load play status
    List<Map<String, dynamic>> playStatusData = await db.query('play_status');
    if (playStatusData.isNotEmpty) {
      var playStatus = playStatusData[0];
      playlistName = playStatus['playlist_name'];
      currentIndex = playStatus['current_index'];
      int durationMilliseconds = playStatus['current_duration'];
      currentDuration = Duration(milliseconds: durationMilliseconds);
    }

    notifyListeners();
  }

// Save playlists to the database
  Future<void> savePlaylists() async {
    Database? db = database;
    if (db == null) return;

    // Clear existing playlists and songs
    await db.transaction((txn) async {
      await txn.delete('playlist');
      await txn.delete('song');
    });

    // Insert playlists into the database
    for (var entry in playlists.entries) {
      String playlistName = entry.key;
      List<SongModel> songs = entry.value;

      // Insert playlist
      int playlistId = await db.insert('playlist', {'name': playlistName});

      // Insert songs for the playlist
      for (var song in songs) {
        await db.insert('song', {
          'id': song.id,
          'playlist_id': playlistId,
          'uri': song.uri,
          'album': song.album,
          'album_id': song.albumId,
          'artist': song.artist,
          'artist_id': song.artistId,
          'title': song.title,
        });
      }
    }
  }

  // Save play status to the database
  Future<void> savePlayStatus() async {
    Database? db = database;
    if (db == null) return;

    // Clear existing play status
    await db.delete('play_status');

    // Insert play status into the database
    await db.insert('play_status', {
      'playlist_name': playlistName,
      'current_index': currentIndex,
      'current_duration': currentDuration.inMilliseconds,
    });
  }

  // Create a playlist
  void createPlaylist(String name) {
    playlists[name] = [];
    savePlaylists().then((_) {
      notifyListeners();
    });
  }

  // Delete a playlist
  void deletePlaylist(String playlistName) {
    playlists.remove(playlistName);
    savePlaylists().then((_) {
      notifyListeners();
    });
  }

  // Add songs to a playlist
  void addSongsToPlaylist(String playlistName, List<SongModel> songs) {
    playlists[playlistName]?.addAll(songs);
    savePlaylists().then((_) {
      notifyListeners();
    });
  }

  // Remove a song from a playlist
  void removeSongFromPlaylist(String playlistName, SongModel song) {
    playlists[playlistName]?.remove(song);
    savePlaylists().then((_) {
      notifyListeners();
    });
  }

  // Update the current index and duration
  void updatePlayStatus(int index, Duration duration) {
    currentIndex = index;
    currentDuration = duration;
    savePlayStatus().then((_) {
      notifyListeners();
    });
  }
}
