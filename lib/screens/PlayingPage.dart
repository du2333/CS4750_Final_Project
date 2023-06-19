import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayingPage extends StatefulWidget {
  const PlayingPage({super.key});

  @override
  State<PlayingPage> createState() => _PlayingPageState();
}

class _PlayingPageState extends State<PlayingPage> {
  // 初始化播放器
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    //增加播放列表
    //TODO 创建一个播放列表的class
    _player
        .setAudioSource(ConcatenatingAudioSource(children: [
      AudioSource.asset('assets/audios/Call of Silence 泽野弘之.mp3'),
      AudioSource.asset('assets/audios/Curtain_Call_-_清水翔太.mp3'),
      AudioSource.asset('assets/audios/Voices_of_the_Chord.mp3'),
    ]))
        .catchError((error) {
      print("An error occurred $error");
    });
  }

  //Destructor
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

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
      icon: isEnabled
            ? Icon(Icons.shuffle_on_outlined)
            : Icon(Icons.shuffle),
      //改成异步方法，才能被StreamBuilder异步更新UI
      onPressed: () async {
        //获取相反的状态
        final enable = !isEnabled;
        //如果随机播放模式没有被激活，那么按下按钮就表示激活随机播放
        if(enable) {
          await _player.shuffle();
        }
        //按下按钮之后，设定成相反的状态
        await _player.setShuffleModeEnabled(enable);
      },
    );
  }

  //TODO 实现功能
  Widget _previousButton() {
    return IconButton(
      icon: Icon(Icons.skip_previous),
      onPressed: () {},
    );
  }

  //TODO 实现功能
  Widget _nextButton() {
    return IconButton(
      icon: Icon(Icons.skip_next),
      onPressed: () {},
    );
  }

  //TODO 实现功能
  Widget _loopButton(BuildContext context, LoopMode loopMode) {
    return IconButton(
      icon: Icon(Icons.repeat),
      onPressed: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
          children: [
            //随机播放按钮
            StreamBuilder<bool>(
              stream: _player.shuffleModeEnabledStream,
              builder: (_, snapshot) {
                return _shuffleButton(snapshot.data ?? false);// ??表示前面如果有值就取前面，否则取后面和 snapshot.data ? snapshot.data : false 一样
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
          ]),
    );
  }
}
