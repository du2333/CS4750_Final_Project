import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlayingPage extends StatefulWidget {
  const PlayingPage(this._player, {super.key});

  final AudioPlayer _player;

  @override
  State<PlayingPage> createState() => _PlayingPageState();
}

class _PlayingPageState extends State<PlayingPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: StreamBuilder<SequenceState?>(
      stream: widget._player.sequenceStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        return Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              margin: const EdgeInsets.only(top: 30, bottom: 30),
              child: state != null
              //TODO Make the artwork quality better
                  ? QueryArtworkWidget(
                      id: state.currentSource!.tag.id,
                      type: ArtworkType.AUDIO,
                      quality: 100,
                    )
                  : Image.asset(
                      "assets/images/music-placeholder.png",
                      fit: BoxFit.cover,
                    ),
            ),
            Text(
              state!.currentSource!.tag.title ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(state.currentSource!.tag.artist ?? ''),
          ],
        );
      },
    ));
  }
}
