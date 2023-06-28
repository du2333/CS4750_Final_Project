import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../models/PlaylistProvider.dart';
import 'commons/PlaylistDetailsScreen.dart';

class PlayListPage extends StatefulWidget {
  const PlayListPage(this._player, {super.key});

  final AudioPlayer _player;

  @override
  State<PlayListPage> createState() => _PlayListPageState();
}

class _PlayListPageState extends State<PlayListPage> {
  Offset _tapPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    final playlists = playlistProvider.playlists;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.playlist_add_rounded),
        onPressed: () => newPlaylistDialog(playlistProvider),
      ),
      body: ListView.builder(
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          final playlistName = playlists.keys.toList()[index];
          if (playlistName == 'defaultPlaylist') {
            return const SizedBox.shrink();
          }
          final playlist = playlists[playlistName];

          return Container(
            margin: const EdgeInsets.only(top: 15.0, left: 12.0, right: 16.0),
            child: GestureDetector(
              onTapDown: (position) => {_getTapPosition(position)},
              onLongPress: () => showPopupMenu(playlistProvider, playlistName),
              child: ListTile(
                leading: playlist!.isNotEmpty
                    ? QueryArtworkWidget(
                        artworkBorder: BorderRadius.zero,
                        id: playlist[0].id,
                        type: ArtworkType.AUDIO,
                      )
                    : const Icon(
                        Icons.playlist_add_check_outlined,
                        size: 50.0,
                      ),
                title: Text(playlistName),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PlaylistDetailsScreen(
                              playlistName, widget._player)));
                },
              ),
            ),
          );
        },
      ),
    );
  }

  //Delete dialog
  Future deletePlaylistDialog(
      PlaylistProvider playlistProvider, String playlistName) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Are You Sure to Delete this Playlist?"),
              actions: [
                TextButton(
                  child: const Text('No'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  onPressed: () {
                    // Delete the playlist
                    playlistProvider.deletePlaylist(playlistName);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Yes'),
                ),
              ],
            ));
  }

  //Popup prompt creating new playlist
  Future newPlaylistDialog(PlaylistProvider playlistProvider) {
    var textEditingController = TextEditingController();

    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Create new playlist"),
              content: TextField(
                autofocus: true,
                decoration:
                    const InputDecoration(hintText: 'Enter your playlist name'),
                controller: textEditingController,
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Confirm'),
                  onPressed: () {
                    var text = textEditingController.text;

                    if (text.isEmpty) {
                      Fluttertoast.showToast(msg: 'Name Cannot Be Empty!');
                    } else if (playlistProvider.playlists.containsKey(text)) {
                      Fluttertoast.showToast(msg: 'Name Already Exists !');
                    } else {
                      playlistProvider.createPlaylist(text);
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ));
  }

  Future<void> showPopupMenu(
      PlaylistProvider playlistProvider, String playlistName) async {
    final RenderObject? overlay =
        Overlay.of(context).context.findRenderObject();

    final result = await showMenu(
        context: context,
        position: RelativeRect.fromRect(
            Rect.fromLTWH(_tapPosition.dx + 10, _tapPosition.dy + 50, 100, 100),
            Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
                overlay.paintBounds.size.height)),
        items: [
          const PopupMenuItem(
            value: 'option1',
            child: Text('Rename'),
          ),
          const PopupMenuItem(
            value: 'option2',
            child: Text('Delete'),
          ),
        ]);

    if (result == 'option1') {
      //TODO rename the playlist
    } else if (result == 'option2') {
      deletePlaylistDialog(playlistProvider, playlistName);
    }
  }

  void _getTapPosition(TapDownDetails tapPosition) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    setState(() {
      _tapPosition = referenceBox.globalToLocal(tapPosition.globalPosition);
    });
  }
}
