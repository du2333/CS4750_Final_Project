import 'package:flutter/material.dart';

class UploadIconButton extends StatefulWidget {
  final bool completed;
  final BuildContext context;
  final String path;
  final Function(String) uploadTask;
  final Function(BuildContext, String) deleteTask;

  const UploadIconButton({
    super.key,
    required this.path,
    required this.uploadTask,
    required this.context,
    required this.deleteTask,
    required this.completed,
  });

  @override
  _UploadIconButtonState createState() => _UploadIconButtonState();
}

class _UploadIconButtonState extends State<UploadIconButton> {
  bool uploading = false;
  bool completed = false;

  @override
  void initState() {
    super.initState();
    completed = widget.completed;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: uploading
          ? const CircularProgressIndicator()
          : Icon(
              completed ? Icons.cloud_done_rounded : Icons.cloud_upload_rounded,
              color: completed ? Colors.green : null,
            ),
      onPressed: completed
          ? () async {
              final confirmed =
                  await widget.deleteTask(widget.context, widget.path);

              if (confirmed) {
                setState(() {
                  completed = false;
                });
              }
            }
          : () async {
              setState(() {
                uploading = true;
              });

              try {
                final uploadTask = widget.uploadTask(widget.path);
                await uploadTask.whenComplete(() {
                  setState(() {
                    completed = true;
                    uploading = false;
                  });
                });
              } catch (error) {
                setState(() {
                  completed = false;
                  uploading = false;
                });
              }
            },
    );
  }
}
