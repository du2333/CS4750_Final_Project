import 'dart:io';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class PlaylistProvider extends ChangeNotifier {
  Map<String, List<SongModel>> playlists = {};

  Database? database;

  // Initialize the provider
  PlaylistProvider() {
    // Initialize the database
    initializeDatabase().then((_) {
      // Load playlists from the database
      loadPlaylists();
    });
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
          .execute('CREATE TABLE playlist (id TEXT PRIMARY KEY, name TEXT)');
      // Create the song table
      await db.execute(
          'CREATE TABLE song (id TEXT PRIMARY KEY, playlist_id TEXT, uri TEXT, album TEXT, album_id INTEGER, artist TEXT, artist_id INTEGER, title TEXT)');
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
          'id': song.id.toString(),
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
}
