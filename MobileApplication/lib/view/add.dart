import 'package:flutter/material.dart';

import 'surveillance_page.dart'; // Import SurveillancePage
import 'livecamera.dart'; // Import LiveCameraPage

class AddPage extends StatelessWidget {
  const AddPage({Key? key}) : super(key: key);

  Future<void> _fetchSessionAndNavigate(BuildContext context) async {
    try {
      String sessionId = 'OGxfLq7eQxECaC9p'; // Backend must return session_id
      String expectedOtp = '106996'; // Backend must return otp

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SurveillancePage(
            sessionId: sessionId,
            expectedOtp: expectedOtp,
          ),
        ),
      );
    } catch (e) {
      _showErrorDialog(context, "Error fetching session: $e");
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _fetchSessionAndNavigate(context),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  backgroundColor: const Color.fromRGBO(198, 160, 206, 1),
                ),
                child: const Text(
                  'Surveillance',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LiveCameraPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  backgroundColor: const Color.fromRGBO(198, 160, 206, 1),
                ),
                child: const Text(
                  'Live Camera',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
