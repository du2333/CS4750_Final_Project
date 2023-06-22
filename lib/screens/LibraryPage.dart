import 'dart:developer';

import 'package:cloudjams/models/Playerlist.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage(this._onAudioQuery, this._player, {super.key});

  final OnAudioQuery _onAudioQuery;
  final AudioPlayer _player;

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: FutureBuilder<List<SongModel>>(
          future: widget._onAudioQuery.querySongs(
            orderType: OrderType.ASC_OR_SMALLER,
            uriType: UriType.EXTERNAL,
            ignoreCase: true,
          ),
          builder: (context, item) {
            //如果还没加载完歌曲就转圈圈
            if (item.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            //提示没找到歌曲
            if (item.data!.isEmpty) {
              return const Center(
                child: Text("No Songs Found"),
              );
            }

            //构建歌曲列表的listview
            return ListView.builder(
                itemCount: item.data!.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(
                        top: 15.0, left: 12.0, right: 16.0),
                    child: ListTile(
                      title: Text(item.data![index].title),
                      subtitle: Text(
                        item.data![index].artist ?? '',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      //获取歌曲封面
                      leading: QueryArtworkWidget(
                        id: item.data![index].id,
                        type: ArtworkType.AUDIO,
                      ),
                      onTap: () async {
                        //TODO 先把本地曲库作为播放列表
                        //首先创建播放列表然后添加给播放器
                        var playlist = Playerlist.createPlaylist(item.data!);
                        await widget._player
                            .setAudioSource(playlist, initialIndex: index)
                            .catchError((error) {
                          log('$error');
                        });
                        //然后播放点击的歌曲
                        await widget._player.play();
                      },
                    ),
                  );
                });
          },
        ),
      ),
    ]);
  }
}
