import 'package:cloudjams/screens/commons/CurrentPlaylist.dart';
import 'package:cloudjams/screens/commons/PlayerButtons.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:we_slide/we_slide.dart';

class PlayingPage extends StatefulWidget {
  const PlayingPage(this._player, {super.key});

  final AudioPlayer _player;

  @override
  State<PlayingPage> createState() => _PlayingPageState();
}

class _PlayingPageState extends State<PlayingPage> {
  @override
  Widget build(BuildContext context) {
    final controller = WeSlideController();
    const double panelMinSize = 0;
    final double panelMaxSize = MediaQuery.of(context).size.height;

    return Scaffold(
      body: WeSlide(
        controller: controller,
        backgroundColor: Colors.white,
        panelMinSize: panelMinSize,
        panelMaxSize: panelMaxSize * 0.7,
        parallax: true,
        transformScale: true,
        isDismissible: true,
        hideFooter: true,
        footerHeight: 200,
        body: Center(
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
                  color: Colors.white,
                  margin: const EdgeInsets.only(top: 30, bottom: 30),
                  child: state != null
                      ? QueryArtworkWidget(
                          artworkBorder: BorderRadius.circular(20.0),
                          id: state.currentSource!.tag.id,
                          type: ArtworkType.AUDIO,
                          format: ArtworkFormat.PNG,
                          size: 400,
                        )
                      : Image.asset(
                          "assets/images/music-placeholder.png",
                          fit: BoxFit.cover,
                        ),
                ),
                Text(
                  state != null ? state.currentSource!.tag.title : '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(state != null ? state.currentSource!.tag.artist : ''),
              ],
            );
          },
        )),
        panel: CurrentPlaylist(
          widget._player,
          onTap: controller.hide,
        ),
        footer: PlayerButtons(widget._player, onTap: controller.show),
      ),
    );
  }
}
