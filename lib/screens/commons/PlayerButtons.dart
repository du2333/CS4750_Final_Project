import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cloudjams/models/DurationStatusBar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class PlayerButtons extends StatelessWidget {
  const PlayerButtons(this._player, {super.key, required this.onTap});

  final Function onTap;

  final AudioPlayer _player;

  //当前播放列表按钮
  Widget _currentPlayingButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.playlist_play_rounded),
          iconSize: 36,
          onPressed: () => onTap(),
        ),
      ],
    );
  }

  //根据播放器状态来渲染对应的按钮样式
  Widget _playerButton(PlayerState? playerState) {
    //获取状态
    final processingState = playerState?.processingState;
    if (processingState == null || !_player.playing) {
      return IconButton(
        onPressed: _player.play,
        icon: const Icon(Icons.play_arrow),
        iconSize: 64.0,
      );
    } else if (processingState != ProcessingState.completed) {
      return IconButton(
        onPressed: _player.pause,
        icon: const Icon(Icons.pause),
        iconSize: 64.0,
      );
    } else {
      return IconButton(
        onPressed: () =>
            _player.seek(Duration.zero, index: _player.effectiveIndices?.first),
        icon: const Icon(Icons.replay),
        iconSize: 64.0,
      );
    }
  }

  //context用来获取当前主题色
  Widget _shuffleButton(bool isEnabled) {
    return IconButton(
      icon: isEnabled
          ? const Icon(Icons.shuffle_on_outlined)
          : const Icon(Icons.shuffle),
      //改成异步方法，才能被StreamBuilder异步更新UI
      onPressed: () async {
        //获取相反的状态
        final enable = !isEnabled;
        //如果随机播放模式没有被激活，那么按下按钮就表示激活随机播放
        if (enable) {
          await _player.shuffle();
        }
        //按下按钮之后，设定成相反的状态
        await _player.setShuffleModeEnabled(enable);
      },
    );
  }

  Widget _previousButton() {
    return IconButton(
      icon: const Icon(Icons.skip_previous),
      iconSize: 54.0,
      onPressed: () {
        if (_player.hasPrevious) {
          _player.seekToPrevious();
        }
      },
    );
  }

  Widget _nextButton() {
    return IconButton(
      icon: const Icon(Icons.skip_next),
      iconSize: 54.0,
      onPressed: () {
        if (_player.hasNext) {
          _player.seekToNext();
        }
      },
    );
  }

  Widget _loopButton(BuildContext context, LoopMode loopMode) {
    final icons = [
      const Icon(Icons.repeat), //未激活循环按钮
      const Icon(Icons.repeat_on_outlined), //激活循环按钮
      const Icon(Icons.repeat_one_on_outlined), //激活单曲循环按钮
    ];

    const cycleModes = [
      LoopMode.off, //关闭循环
      LoopMode.all, //列表循环
      LoopMode.one, //单曲循环
    ];

    //获取当前循环模式
    final index = cycleModes.indexOf(loopMode);

    return IconButton(
      icon: icons[index],
      onPressed: () {
        //每按一次就切换到下一个循环模式
        _player.setLoopMode(cycleModes[(index + 1) % cycleModes.length]);
      },
    );
  }

  //获取当前播放进度
  Stream<DurationStatusBar> get _durationStateStream =>
      Rx.combineLatest2<Duration, Duration?, DurationStatusBar>(
          _player.positionStream,
          _player.durationStream,
          (progress, duration) => DurationStatusBar(
              progress: progress, total: duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.only(right: 25),
              child: _currentPlayingButton()),
          Container(
            margin: const EdgeInsets.only(top: 4.0, left: 32.0, right: 32.0),
            child: StreamBuilder<DurationStatusBar>(
              stream: _durationStateStream,
              builder: (context, snapshot) {
                final durationState = snapshot.data;
                final progress = durationState?.progress ?? Duration.zero;
                final total = durationState?.total ?? Duration.zero;

                return ProgressBar(
                  progress: progress,
                  total: total,
                  onSeek: (duration) {
                    //拖动进度条
                    _player.seek(duration);
                  },
                );
              },
            ),
          ),
          Row(mainAxisSize: MainAxisSize.min, children: [
            //随机播放按钮
            StreamBuilder<bool>(
              stream: _player.shuffleModeEnabledStream,
              builder: (_, snapshot) {
                return _shuffleButton(snapshot.data ??
                    false); // ??表示前面如果有值就取前面，否则取后面和 snapshot.data ? snapshot.data : false 一样
              },
            ),
            //上一首按钮
            StreamBuilder<SequenceState?>(
              stream: _player.sequenceStateStream,
              builder: (_, __) {
                return _previousButton();
              },
            ),
            //播放按钮
            StreamBuilder<PlayerState>(
              stream: _player.playerStateStream,
              //Widget构建器
              builder: (_, snapshot) {
                final playerState = snapshot.data;
                return _playerButton(playerState);
              },
            ),
            //下一首按钮
            StreamBuilder<SequenceState?>(
              stream: _player.sequenceStateStream,
              builder: (_, __) {
                return _nextButton();
              },
            ),
            //循环播放按钮
            StreamBuilder<LoopMode>(
              stream: _player.loopModeStream,
              builder: (context, snapshot) {
                return _loopButton(context, snapshot.data ?? LoopMode.off);
              },
            )
          ]),
        ],
      ),
    );
  }
}
