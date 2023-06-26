import 'package:cloudjams/screens/LibraryPage.dart';
import 'package:cloudjams/screens/PlayListPage.dart';
import 'package:cloudjams/screens/PlayingPage.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../models/Playlist.dart';
import '../models/PlaylistProvider.dart';

class TopBarNavigation extends StatefulWidget {
  const TopBarNavigation({super.key});

  @override
  State<TopBarNavigation> createState() => _TopBarNavigationState();
}

class _TopBarNavigationState extends State<TopBarNavigation> {
  late AudioPlayer _player;
  late OnAudioQuery _audioQuery;
  bool _isAudioSourceInitialized = false;

  @override
  void initState() {
    super.initState();
    // 初始化播放器
    _player = AudioPlayer();
    //初始化获取歌曲信息插件
    _audioQuery = OnAudioQuery();
    //获取读写权限
    requestStoragePermission();

    _initializeAudioSource();
  }

  //Destructor
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _initializeAudioSource() async {
    final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    final playlist = Song.convertToPlaylist(
      playlistProvider.playlists[playlistProvider.playlistName] ?? [],
      playlistProvider.playlistName,
    );
    final currentIndex = playlistProvider.currentIndex;
    final currentDuration = playlistProvider.currentDuration;
    if (playlist.length != 0) {
      await _player.setAudioSource(
        playlist,
        initialIndex: currentIndex,
        initialPosition: currentDuration,
      );
    }
    setState(() {
      _isAudioSourceInitialized = true;
    });
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
                child: Icon(Icons.playlist_play_rounded),
              ),
              Tab(
                child: Icon(Icons.music_note_rounded),
              ),
              Tab(
                child: Icon(Icons.library_music_rounded),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                PlayListPage(_player),
                _isAudioSourceInitialized ? PlayingPage(_player) : const Center(
                  child: CircularProgressIndicator(),
                ),
                LibraryPage(_audioQuery, _player),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> requestStoragePermission() async {
    bool permissionStatus = await _audioQuery.permissionsStatus();
    if (!permissionStatus) {
      await _audioQuery.permissionsRequest();
    }

    setState(() {});
  }
}
