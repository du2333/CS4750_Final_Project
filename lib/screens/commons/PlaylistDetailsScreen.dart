import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../../models/Playlist.dart';
import '../../models/PlaylistProvider.dart';

class PlaylistDetailsScreen extends StatelessWidget {
  final String playlistName;
  final AudioPlayer _player;

  const PlaylistDetailsScreen(this.playlistName, this._player, {super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the selected playlist from the PlaylistProvider
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    final playlist = playlistProvider.playlists[playlistName];

    // Display the playlist details
    return Scaffold(
      appBar: AppBar(
        title: Text(playlistName),
      ),
      body: ListView.builder(
          itemCount: playlist?.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(top: 15.0, left: 12.0, right: 16.0),
              child: ListTile(
                title: Text(playlist![index].title),
                subtitle: Text(
                  playlist[index].artist ?? '',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                //获取歌曲封面
                leading: QueryArtworkWidget(
                  id: playlist[index].id,
                  type: ArtworkType.AUDIO,
                ),
                onTap: () async {
                  //首先创建播放列表然后添加给播放器
                  var currentPlaying = Playlist.convertToPlaylist(playlist);

                  await _player.setAudioSource(currentPlaying,
                      initialIndex: index);

                  //然后播放点击的歌曲
                  await _player.play();
                },
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_rounded),
        onPressed: () {

        },
      ),
    );
  }
}
