import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class CurrentPlaylist extends StatelessWidget {
  const CurrentPlaylist(this._player, {super.key, required this.onTap});

  final Function onTap;

  final AudioPlayer _player;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => onTap(),
                  child: Container(
                    width: 70,
                    height: 70,
                    child: const Icon(
                      Icons.expand_more,
                      size: 36,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<SequenceState?>(
                stream: _player.sequenceStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  final sequence = state?.sequence ?? [];
                  return ListView(
                    children: [
                      //list comprehension用法
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
                }),
          ),
        ],
      ),
    );
  }
}
