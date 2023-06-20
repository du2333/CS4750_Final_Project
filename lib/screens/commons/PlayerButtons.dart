import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayerButtons extends StatelessWidget {
  const PlayerButtons(this._player, {super.key});

  final AudioPlayer _player;

  //根据播放器状态来渲染对应的按钮样式
  Widget _playerButton(PlayerState playerState) {
    //获取状态
    final processingState = playerState.processingState;
    //判断如果加载或缓冲则变成缓冲图标
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return Container(
        margin: EdgeInsets.all(8.0),
        width: 64.0,
        height: 64.0,
        //缓冲图标
        child: const CircularProgressIndicator(),
      );
      //如果没有在播放，则换成播放图标，并且把事件绑定成播放
    } else if (!_player.playing) {
      return IconButton(
        onPressed: _player.play,
        icon: Icon(Icons.play_arrow),
        iconSize: 64.0,
      );
    } else if (processingState != ProcessingState.completed) {
      return IconButton(
        onPressed: _player.pause,
        icon: Icon(Icons.pause),
        iconSize: 64.0,
      );
    } else {
      return IconButton(
        onPressed: () =>
            _player.seek(Duration.zero, index: _player.effectiveIndices?.first),
        icon: Icon(Icons.replay),
        iconSize: 64.0,
      );
    }
  }

  //context用来获取当前主题色
  Widget _shuffleButton(bool isEnabled) {
    return IconButton(
      icon: isEnabled ? Icon(Icons.shuffle_on_outlined) : Icon(Icons.shuffle),
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
      icon: Icon(Icons.skip_previous),
      onPressed: () {
        _player.hasPrevious ? _player.seekToPrevious() : null;
      },
    );
  }

  Widget _nextButton() {
    return IconButton(
      icon: Icon(Icons.skip_next),
      onPressed: () {
        _player.hasNext ? _player.seekToNext() : null;
      },
    );
  }

  Widget _loopButton(BuildContext context, LoopMode loopMode) {
    final icons = [
      Icon(Icons.repeat), //未激活循环按钮
      Icon(Icons.repeat_on_outlined), //激活循环按钮
      Icon(Icons.repeat_one_on_outlined), //激活单曲循环按钮
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

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
            return _playerButton(playerState!);
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
      ]);
  }
}

