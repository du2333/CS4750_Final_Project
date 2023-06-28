import 'package:cloudjams/screens/UserPage.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../models/Playlist.dart';
import '../models/PlaylistProvider.dart';
import '../navigation/TopBarNav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AudioPlayer _player;
  late OnAudioQuery _audioQuery;

  @override
  void initState() {
    super.initState();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 初始化播放器
    _player = AudioPlayer();
    //初始化获取歌曲信息插件
    _audioQuery = OnAudioQuery();
    //获取读写权限
    requestStoragePermission();

    _initializeAudioSource();

    // Wait for a certain duration
    await Future.delayed(const Duration(seconds: 2));

    // Navigate to the main/home screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => /*UserPage()*/ TopBarNavigation(
          player: _player,
          audioQuery: _audioQuery,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'CloudJams',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> requestStoragePermission() async {
    bool permissionStatus = await _audioQuery.permissionsStatus();
    if (!permissionStatus) {
      await _audioQuery.permissionsRequest();
    }

  }

  Future<void> _initializeAudioSource() async {
    final playlistProvider =
        Provider.of<PlaylistProvider>(context, listen: false);
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
  }
}
