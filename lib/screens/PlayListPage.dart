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
  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    final playlists = playlistProvider.playlists;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.playlist_add_rounded),
        onPressed: () => newPlaylistDialog(context, playlistProvider),
      ),
      body: ListView.builder(
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          final playlistName = playlists.keys.toList()[index];
          if (playlistName == 'defaultPlaylist') {
            return null;
          }
          final playlist = playlists[playlistName];

          return ListTile(
            leading: playlist!.isNotEmpty
                ? QueryArtworkWidget(
                    artworkBorder: BorderRadius.zero,
                    id: playlist[0].id,
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
            onLongPress: () =>
                deletePlaylistDialog(context, playlistProvider, playlistName),
          );
        },
      ),
    );
  }
}

//Popup prompt creating new playlist
Future newPlaylistDialog(
    BuildContext context, PlaylistProvider playlistProvider) {
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

//Delete dialog
Future deletePlaylistDialog(BuildContext context,
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
