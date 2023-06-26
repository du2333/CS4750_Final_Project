import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../../models/PlaylistProvider.dart';

class CurrentPlaylist extends StatefulWidget {
  const CurrentPlaylist(this._player, {super.key, required this.onTap, this.currentPlaylistName = ''});

  final Function onTap;
  final String currentPlaylistName;
  final AudioPlayer _player;

  @override
  State<CurrentPlaylist> createState() => _CurrentPlaylistState();
}

class _CurrentPlaylistState extends State<CurrentPlaylist> with WidgetsBindingObserver {

  late Timer? saveTimer;

  @override
  void initState() {
    super.initState();
    startPeriodicSaving();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopPeriodicSaving();
    super.dispose();
  }

  void startPeriodicSaving() {
    saveTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      savePlayStatus();
    });
  }

  void stopPeriodicSaving() {
    saveTimer?.cancel();
    saveTimer = null;
  }

  //关闭App之前保存播放进度
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //当app后台运行每5秒保存播放进度
    if (state == AppLifecycleState.paused) {
      savePlayStatus();
      startPeriodicSaving();
      super.didChangeAppLifecycleState(state);
    } else if(state == AppLifecycleState.resumed) {
      stopPeriodicSaving();
    }
  }

  Future<void> savePlayStatus() async {
    final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    playlistProvider.playlistName = widget.currentPlaylistName;
    playlistProvider.currentIndex = widget._player.currentIndex ?? 0;
    playlistProvider.currentDuration = widget._player.position;
    await playlistProvider.savePlayStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => widget.onTap(),
                  child: Container(
                    width: 70,
                    height: 70,
                    child: const Icon(
                      Icons.expand_more,
                      size: 36,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<SequenceState?>(
                stream: widget._player.sequenceStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  final sequence = state?.sequence ?? [];
                  return ListView(
                    children: [
                      //list comprehension用法
                      for (var i = 0; i < sequence.length; i++)
                        ListTile(
                          selected: i == state?.currentIndex,
                          leading: QueryArtworkWidget(
                            id: sequence[i].tag.song.id,
                            type: ArtworkType.AUDIO,
                          ),
                          title: Text(sequence[i].tag.song.title),
                          subtitle: Text(
                            sequence[i].tag.song.artist ?? '',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          onTap: () {
                            //点击播放相应歌曲
                            widget._player.seek(Duration.zero, index: i);
                            widget._player.play();
                          },
                        )
                    ],
                  );
                }),
          ),
        ],
      ),
    );
  }
}
