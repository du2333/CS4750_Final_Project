import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Playlist extends StatelessWidget {
  const Playlist(this._player, {super.key});

  final AudioPlayer _player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SequenceState?>(
        stream: _player.sequenceStateStream,
        builder: (context, snapshot) {
          final state = snapshot.data;
          final sequence = state?.sequence ?? [];
          return ListView(
            children: [//list comprehension用法
              for (var i = 0; i < sequence.length; i++)
                ListTile(
                  selected: i == state?.currentIndex,
                  leading: QueryArtworkWidget(
                    id: sequence[i].tag.id,
                    type: ArtworkType.AUDIO,
                  ),
                  title: Text(sequence[i].tag.title),
                  subtitle: Text(
                    sequence[i].tag.artist ?? '',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  onTap: () {
                    //点击播放相应歌曲
                    _player.seek(Duration.zero, index: i);
                    _player.play();
                  },
                )
            ],
          );
        });
  }
}
