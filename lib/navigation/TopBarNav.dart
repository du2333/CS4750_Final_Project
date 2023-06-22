import 'package:cloudjams/screens/LibraryPage.dart';
import 'package:cloudjams/screens/PlayListPage.dart';
import 'package:cloudjams/screens/PlayingPage.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../screens/commons/PlayerButtons.dart';

class TopBarNavigation extends StatefulWidget {
  const TopBarNavigation({super.key});

  @override
  State<TopBarNavigation> createState() => _TopBarNavigationState();
}

class _TopBarNavigationState extends State<TopBarNavigation> {
  late AudioPlayer _player;
  late OnAudioQuery _audioQuery;

  @override
  void initState() {
    super.initState();
    // 初始化播放器
    _player = AudioPlayer();
    //初始化获取歌曲信息插件
    _audioQuery = OnAudioQuery();
    //获取读写权限
    requestStoragePermission();


    // //添加播放列表
    // _player.setAudioSource().catchError((error) {
    //   log("An error occurred $error");
    // });
  }

  //Destructor
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
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
                //TODO 换图标
                child: Text("PlayList"),
              ),
              Tab(
                //TODO 换图标
                child: Text("Playing"),
              ),
              Tab(
                //TODO 换图标
                child: Text("Library"),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                //TODO 保存并读取播放列表
                PlayListPage(_player),
                PlayingPage(_player),
                LibraryPage(_audioQuery, _player),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: PlayerButtons(_player),
            )
          ],
        ),
      ),
    );
  }

  Future<void> requestStoragePermission() async {
    bool permissionStatus = await _audioQuery.permissionsStatus();
    if(!permissionStatus) {
      await _audioQuery.permissionsRequest();
    }

    setState(() {

    });
  }

}
