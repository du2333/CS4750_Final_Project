class DurationStatusBar {
  Duration progress;
  Duration total;

  //进度条条默认设为0
  DurationStatusBar(
      {this.progress = Duration.zero, this.total = Duration.zero});
}
