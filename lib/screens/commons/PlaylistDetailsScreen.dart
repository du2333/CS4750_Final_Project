import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../../models/Playlist.dart';
import '../../models/PlaylistProvider.dart';
import '../LibraryPage.dart';

class PlaylistDetailsScreen extends StatefulWidget {
  final String playlistName;
  final AudioPlayer _player;

  const PlaylistDetailsScreen(this.playlistName, this._player, {super.key});

  @override
  State<PlaylistDetailsScreen> createState() => _PlaylistDetailsScreenState();
}

class _PlaylistDetailsScreenState extends State<PlaylistDetailsScreen> {
  bool isSelectItem = false;
  Map<int, bool> selectedItem = {};
  List<SongModel> selectedSongs = [];

  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    final playlist = playlistProvider.playlists[widget.playlistName] ?? [];

    // Display the playlist details
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlistName),
      ),
      body: ListView.builder(
          itemCount: playlist.length,
          itemBuilder: (context, index) {
            selectedItem[index] = selectedItem[index] ?? false;
            bool? isSelectedData = selectedItem[index];

            return Container(
              margin: const EdgeInsets.only(top: 15.0, left: 12.0, right: 16.0),
              child: ListTile(
                onLongPress: () {
                  setState(() {
                    selectedItem[index] = !isSelectedData;
                    //开启多选模式
                    isSelectItem = selectedItem.containsValue(true);
                  });
                },
                onTap: () async {
                  if (isSelectItem) {
                    setState(() {
                      selectedItem[index] = !isSelectedData;
                      isSelectItem = selectedItem.containsValue(true);
                    });
                  } else {
                    var currentPlaying = Playlist.convertToPlaylist(playlist);
                    await widget._player
                        .setAudioSource(currentPlaying, initialIndex: index);
                    await widget._player.play();
                  }
                },
                title: Text(playlist[index].title),
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
                trailing: trailingContent(isSelectedData!, context),
              ),
            );
          }),
      floatingActionButton: isSelectItem
          ? FloatingActionButton(
              onPressed: () {
                showDeleteSongDialog(context, playlistProvider, selectedSongs,
                        playlist, selectedItem, widget.playlistName)
                    .then((_) {//得等到删除歌曲操作后再更新UI
                  setState(() {});
                });
              },
              child: const Icon(Icons.delete),
            )
          : Container(
              width: 0,
            ),
    );
  }
}

Future showDeleteSongDialog(
    BuildContext context,
    PlaylistProvider playlistProvider,
    List<SongModel> selectedSongs,
    List<SongModel> songs,
    Map<int, bool> selectedItem,
    String playlistName) {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text("Are You Sure to Delete these Songs?"),
            actions: [
              TextButton(
                child: const Text('No'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                onPressed: () {
                  // Delete songs
                  selectedItem.forEach((index, isSelected) {
                    if (isSelected) {
                      final song = songs[index];
                      playlistProvider.removeSongFromPlaylist(playlistName, song);
                    }
                  });
                  //重置多选状态
                  selectedItem.clear();
                  Navigator.of(context).pop();
                },
                child: const Text('Yes'),
              ),
            ],
          ));
}
