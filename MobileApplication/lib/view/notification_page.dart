import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class NotificationPage extends StatefulWidget {
  final List<String> notifications;

  NotificationPage({Key? key})
      : notifications = [
          "Unusual activity detected at 10:15 AM",
          "Unusual activity detected at 11:30 AM",
          "Unusual activity detected at 02:45 PM",
        ], // Example notifications
        super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _previousNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _previousNotificationCount = widget.notifications.length;
  }

  @override
  void didUpdateWidget(covariant NotificationPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If new notification is added, play the beep
    if (widget.notifications.length > _previousNotificationCount) {
      _playBeep();
    }

    // Update previous notification count
    _previousNotificationCount = widget.notifications.length;
  }

  Future<void> _playBeep() async {
    await _audioPlayer.play(
      AssetSource('beep.mp3'),
    ); // Ensure beep.mp3 is in assets
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: widget.notifications.isNotEmpty
          ? ListView.builder(
              itemCount: widget.notifications.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.red),
                    title: Text(widget.notifications[index]),
                    subtitle: const Text('Tap for more details'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Details for: ${widget.notifications[index]}',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            )
          : const Center(
              child: Text(
                'No unusual activity detected.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
