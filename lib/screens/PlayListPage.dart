import 'package:cloudjams/screens/commons/CurrentPlaylist.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../models/Playerlist.dart';
import '../models/PlaylistProvider.dart';

class PlayListPage extends StatefulWidget {
  const PlayListPage(this._player, {super.key});

  final AudioPlayer _player;

  @override
  State<PlayListPage> createState() => _PlayListPageState();
}

class _PlayListPageState extends State<PlayListPage> {
  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    final playlists = playlistProvider.playlists;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.playlist_add_rounded),
        //TODO 新建播放列表
        onPressed: () {},
      ),
      body: ListView.builder(
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          final playlistName = playlists.keys.toList()[index];
          final playlist = playlists[playlistName];

          return ListTile(
            leading: playlist!.isNotEmpty
                ? QueryArtworkWidget(
                    artworkBorder: BorderRadius.zero,
                    id: playlist![0].id,
                    type: ArtworkType.AUDIO,
                  )
                : Image.asset(
                    "assets/images/music-placeholder.png",
                    fit: BoxFit.cover,
                  ),
            title: Text(playlistName),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PlaylistDetailsScreen(playlistName, widget._player)));
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Delete the playlist
                playlistProvider.deletePlaylist(playlistName);
              },
            ),
          );
        },
      ),
    );
  }
}

//Playlist details screen
class PlaylistDetailsScreen extends StatelessWidget {
  final String playlistName;
  final AudioPlayer player;

  const PlaylistDetailsScreen(this.playlistName, this.player, {super.key});

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
                  var currentPlaying = Playerlist.createPlaylist(playlist);

                  await player.setAudioSource(currentPlaying,
                      initialIndex: index);

                  //然后播放点击的歌曲
                  await player.play();
                },
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_rounded),
        //TODO 添加歌曲
        onPressed: () {},
      ),
    );
  }
}
