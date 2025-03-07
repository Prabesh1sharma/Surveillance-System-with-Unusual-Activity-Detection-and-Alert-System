import 'package:flutter/material.dart';

class StoragePage extends StatelessWidget {
  final List<Map<String, String>> unusualActivityClips = [
    {"timestamp": "10:15 AM", "filePath": "/path/to/unusual_activity_1.mp4"},
    {"timestamp": "11:30 AM", "filePath": "/path/to/unusual_activity_2.mp4"},
    {"timestamp": "02:45 PM", "filePath": "/path/to/unusual_activity_3.mp4"},
  ]; // Example clips

  final List<Map<String, String>> fullDayRecordings = [
    {"date": "2025-01-13", "filePath": "/path/to/full_day_recording_1.mp4"},
    {"date": "2025-01-12", "filePath": "/path/to/full_day_recording_2.mp4"},
    {"date": "2025-01-12", "filePath": "/path/to/full_day_recording_2.mp4"},
    {"date": "2025-01-12", "filePath": "/path/to/full_day_recording_2.mp4"},
  ]; // Example full-day recordings

  StoragePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: const Text('Storage'),
          // centerTitle: true,
          // backgroundColor: const Color.fromRGBO(198, 160, 206, 1),
          ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Unusual Activity Clips',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: unusualActivityClips.length,
                itemBuilder: (context, index) {
                  final clip = unusualActivityClips[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.video_collection,
                        color: Colors.blue,
                      ),
                      title: Text('Unusual Activity - ${clip["timestamp"]}'),
                      subtitle: Text('Path: ${clip["filePath"]}'),
                      onTap: () {
                        // Handle video playback
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Playing ${clip["filePath"]}'),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            const Text(
              'Full Day Recordings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: fullDayRecordings.length,
                itemBuilder: (context, index) {
                  final recording = fullDayRecordings[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.video_camera_back,
                        color: Colors.green,
                      ),
                      title: Text('Recording - ${recording["date"]}'),
                      subtitle: Text('Path: ${recording["filePath"]}'),
                      onTap: () {
                        // Handle video playback
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Playing ${recording["filePath"]}'),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
