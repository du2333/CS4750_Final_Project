import 'dart:io';

import 'package:cloudjams/models/Playlist.dart';
import 'package:cloudjams/models/PlaylistProvider.dart';
import 'package:cloudjams/screens/UserPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import 'commons/Authentication.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage(this._onAudioQuery, this._player, {super.key});

  final OnAudioQuery _onAudioQuery;
  final AudioPlayer _player;

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  //记录多选
  bool isMultiSelection = false;
  Map<int, bool> selectedItem = {};
  Map<int, bool> syncMap = {};
  List<SongModel> songs = [];
  List<SongModel> selectedSongs = [];
  final Authentication _authentication = Authentication();
  final storageRef = FirebaseStorage.instance.ref();
  static const String musicFolderPath = '/storage/emulated/0//Music';


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);

    return Stack(
      children: [
        FutureBuilder<List<SongModel>>(
          future: scanSongs(widget._onAudioQuery),
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
                          isMultiSelection = selectedItem.containsValue(true);
                        });
                      },
                      onTap: () async {
                        //如果激活了多选模式
                        if (isMultiSelection) {
                          setState(() {
                            selectedItem[index] = !isSelectedData;
                            isMultiSelection = selectedItem.containsValue(true);
                          });
                        }
                        //没有激活多选模式
                        else {
                          const name = 'defaultPlaylist';

                          //首先创建播放列表然后添加给播放器
                          var playlist =
                              Song.convertToPlaylist(item.data!, name);

                          if (playlistProvider.playlists.containsKey(name)) {
                            playlistProvider.deletePlaylist(name);
                          }
                          playlistProvider.createPlaylist(name);
                          playlistProvider.addSongsToPlaylist(name, item.data!);

                          await widget._player
                              .setAudioSource(playlist, initialIndex: index);

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
                      leading: headingContent(
                          isSelectedData!, item.data![index].id, context),
                      trailing: buildFileWidget(item.data![index].data, index),
                    ),
                  );
                });
          },
        ),
        //Sync button
        Positioned(
          bottom: 16.0,
          right: 90.0,
          child: StreamBuilder<User?>(
            stream: _authentication.userStateChanges,
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                return FloatingActionButton(
                  onPressed: () {
                    fetchFromCloud().then((value) {
                      //make sure update the media file
                      widget._onAudioQuery.scanMedia(musicFolderPath);
                    });
                    ;
                  },
                  child: const Icon(Icons.sync_rounded),
                );
              } else {
                return Container(
                  width: 0,
                );
              }
            },
          ),
        ),
        //Login button
        Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserPage())).then((value) {
                  setState(() {});
                });
              },
              child: StreamBuilder<User?>(
                stream: _authentication.userStateChanges,
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return const Icon(Icons.person_rounded);
                  } else {
                    return const Icon(Icons.login_rounded);
                  }
                },
              ),
            )),
        if (isMultiSelection)
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

  //根据多选模式来渲染每行数据的头部部部勾选框
  Widget headingContent(bool isSelected, int id, BuildContext context) {
    if (isSelected && isMultiSelection) {
      return Icon(
        Icons.check_box_rounded,
        color: Theme.of(context).primaryColor,
      );
    } else {
      return QueryArtworkWidget(
        id: id,
        type: ArtworkType.AUDIO,
      );
    }
  }

  //尾部图标
  Widget buildFileWidget(String path, int index) {
    return FutureBuilder<bool>(
      future: checkIfFileExists(path),
      builder: (context, snapshot) {
        if (isMultiSelection || _authentication.currentUser == null) {
          return Container(
            width: 0,
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Display a loading indicator while checking the file existence
          return const CircularProgressIndicator();
        } else {
          // Check if the file exists
          bool fileExists = snapshot.data ?? false;

          if (fileExists) {
            syncMap[index] = true;
            //Handle delete
            return IconButton(
              icon: const Icon(
                Icons.cloud_done_rounded,
                color: Colors.green,
              ),
              onPressed: () {
                deleteSongDialog(context, path);
              },
            );
          } else {
            syncMap[index] = false;
            //Handle upload
            return IconButton(
              icon: const Icon(Icons.cloud_upload_rounded),
              onPressed: () {
                setState(() {
                  File file = File(path);
                  final ref = storageRef.child('/${_authentication.currentUser!.uid}/${basename(file.path)}');
                  final uploadTask = ref.putFile(file);

                  final progressUpdates = Stream.periodic(
                          const Duration(seconds: 3),
                          (_) => uploadTask.snapshot)
                      .takeWhile(
                          (snapshot) => snapshot.state == TaskState.running);

                  final subscription =
                      progressUpdates.listen((TaskSnapshot snapshot) {
                    double progress =
                        snapshot.bytesTransferred / snapshot.totalBytes * 100;
                    Fluttertoast.showToast(
                        msg: 'Uploading in progress: ${progress.round()}%');
                  });

                  uploadTask.whenComplete(() {
                    subscription.cancel();
                    Fluttertoast.showToast(msg: 'Completed!');
                    setState(() {});
                  }).catchError((error) {
                    setState(() {
                      Fluttertoast.showToast(msg: 'An Error Occurred $error');
                    });
                  });
                });
              },
            );
          }
        }
      },
    );
  }

  Future<bool> checkIfFileExists(String path) async {
    try {
      final reference = storageRef.child('/${_authentication.currentUser!.uid}/${basename(path)}');
      await reference.getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }

  //扫描时长大于30秒的歌曲
  Future<List<SongModel>> scanSongs(OnAudioQuery onAudioQuery) async {
    // Query all songs
    List<SongModel> allSongs = await onAudioQuery.querySongs();

    // Filter songs longer than 30 seconds
    List<SongModel> songsLongerThan30Seconds = allSongs
        .where((song) =>
    song.duration != null &&
        song.duration! > 30 * 1000) // Convert duration to milliseconds
        .toList();

    return songsLongerThan30Seconds;
  }


  //Delete dialog
  Future deleteSongDialog(BuildContext context, String path) {
    return showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
              title: const Text("Are You Sure to Delete from Cloud?"),
              actions: [
                TextButton(
                  child: const Text('No'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                TextButton(
                  onPressed: () async {
                    final ref = storageRef.child('/${_authentication.currentUser!.uid}/${basename(path)}');

                    Navigator.of(dialogContext).pop();

                    await ref.delete().then((value) {
                      Fluttertoast.showToast(msg: "Delete Success!");
                    }).catchError((error) {
                      Fluttertoast.showToast(msg: 'An Error Occurred: $error');
                    });

                    setState(() {});
                  },
                  child: const Text('Yes'),
                ),
              ],
            ));
  }

  //获取云端文件
  Future<void> fetchFromCloud() async {
    final ref = storageRef.child('/${_authentication.currentUser!.uid}');
    final listResult = await ref.listAll();
    int total = 0;
    int downloaded = 0;

    //local files
    List<String> localFiles = songs.map((song) => basename(song.data)).toList();

    // Songs in the cloud not present in local
    List<String> songsToDownload = [];

    for (var item in listResult.items) {
      String cloudSongName = basename(item.name);
      if (!localFiles.contains(cloudSongName)) {
        songsToDownload.add(cloudSongName);
      }
    }

    total = songsToDownload.length;
    // If all songs in the cloud are present in local
    if (songsToDownload.isEmpty) {
      Fluttertoast.showToast(msg: 'All songs synced');
      return;
    }

    // Perform download for songs not present locally
    for (var songToDownload in songsToDownload) {
      final cloudSongRef = storageRef.child('/${_authentication.currentUser!.uid}/$songToDownload');
      final localFilePath = '$musicFolderPath/$songToDownload';
      print('$localFilePath======================================');
      final downloadTask = cloudSongRef.writeToFile(File(localFilePath));

      await downloadTask.whenComplete(() {
        downloaded++;
        Fluttertoast.showToast(msg: 'Downloaded: $downloaded/$total');
        setState(() {});
      });
    }
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
                  if (playlistName == 'defaultPlaylist') {
                    return const SizedBox.shrink();
                  }
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
