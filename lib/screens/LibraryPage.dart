import 'package:cloudjams/models/Playlist.dart';
import 'package:cloudjams/models/PlaylistProvider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage(this._onAudioQuery, this._player, {super.key});

  final OnAudioQuery _onAudioQuery;
  final AudioPlayer _player;

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  //记录多选
  bool isSelectItem = false;
  Map<int, bool> selectedItem = {};
  List<SongModel> songs = [];
  List<SongModel> selectedSongs = [];

  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);

    return Stack(
      children: [
        FutureBuilder<List<SongModel>>(
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
                  selectedItem[index] = selectedItem[index] ?? false;
                  bool? isSelectedData = selectedItem[index];
                  songs = item.data!;

                  return Container(
                    margin: const EdgeInsets.only(
                        top: 15.0, left: 12.0, right: 16.0),
                    child: ListTile(
                      onLongPress: () {
                        setState(() {
                          selectedItem[index] = !isSelectedData;
                          isSelectItem = selectedItem.containsValue(true);
                        });
                      },
                      onTap: () async {
                        //如果激活了多选模式
                        if (isSelectItem) {
                          setState(() {
                            selectedItem[index] = !isSelectedData;
                            isSelectItem = selectedItem.containsValue(true);
                          });
                        }
                        //没有激活多选模式
                        else {
                          //首先创建播放列表然后添加给播放器
                          var playlist =
                              Playlist.convertToPlaylist(item.data!);

                          await widget._player.setAudioSource(playlist,
                              initialIndex: index);

                          //然后播放点击的歌曲
                          await widget._player.play();
                        }
                      },
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
                      trailing: trailingContent(isSelectedData!, context),
                    ),
                  );
                });
          },
        ),
        if (isSelectItem)
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                showPlaylistSelection(context, playlistProvider, selectedSongs,
                    songs, selectedItem);
              },
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }
}

//根据多选模式来渲染每行数据的尾部部勾选框
Widget trailingContent(bool isSelected, BuildContext context) {
  if (isSelected) {
    return Icon(
      isSelected ? Icons.check_box : Icons.check_box_outline_blank,
      color: Theme.of(context).primaryColor,
    );
  } else {
    return Container(
      width: 0,
    );
  }
}

//卡片展示可选的播放列表
void showPlaylistSelection(
    BuildContext context,
    PlaylistProvider playlistProvider,
    List<SongModel> selectedSongs,
    List<SongModel> songs,
    Map<int, bool> selectedItem) {
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Select Playlist',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: playlistProvider.playlists.length,
                itemBuilder: (context, index) {
                  final playlistName =
                      playlistProvider.playlists.keys.toList()[index];
                  return ListTile(
                    title: Text(playlistName),
                    onTap: () {
                      //获取已经选中的歌曲
                      selectedItem.forEach((index, isSelected) {
                        if (isSelected) {
                          selectedSongs.add(songs[index]);
                        }
                      });

                      //歌曲去重
                      var success = selectedSongs.length;
                      List<SongModel> songsToRemove = List.from(selectedSongs);

                      for (var element in selectedSongs) {
                        for (var song
                            in playlistProvider.playlists[playlistName]!) {
                          if (element.uri == song.uri) {
                            songsToRemove.remove(element);
                            success--;
                          }
                        }
                      }

                      selectedSongs = songsToRemove;

                      //添加选中歌曲
                      playlistProvider.addSongsToPlaylist(
                          playlistName, selectedSongs);

                      Fluttertoast.showToast(
                          msg:
                              "Successfully added $success songs to $playlistName!");
                      Navigator.of(context).pop();

                      selectedSongs.clear();
                      selectedItem.clear();
                    },
                  );
                },
              ),
            ),
          ],
        );
      });
}
