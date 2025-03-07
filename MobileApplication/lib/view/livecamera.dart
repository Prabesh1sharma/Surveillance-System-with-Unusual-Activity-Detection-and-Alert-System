import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:http/http.dart' as http;
import 'package:universal_io/io.dart'; // Use universal_io instead of dart:io
import 'package:http_parser/http_parser.dart';

class LiveCameraPage extends StatefulWidget {
  const LiveCameraPage({Key? key}) : super(key: key);

  @override
  _LiveCameraPageState createState() => _LiveCameraPageState();
}

class _LiveCameraPageState extends State<LiveCameraPage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  bool _isStreaming = false;
  String _otp = "";
  WebSocketChannel? _channel;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  bool _wsInitialized = false;

  // For interval recording
  bool _isRecording = false;
  XFile? _videoFile;
  DateTime? _recordingStartTime;
  bool _isProcessing = false;
  Map<String, dynamic>? _lastProcessingResult;

  // Timer for periodic recording
  Timer? _recordingTimer;
  Timer? _updateTimer;

  // Define your API endpoint - updated to match HTML
  final String _videoProcessEndpoint = "http://127.0.0.1:8000/process-video/";

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = Future.value();
    _initializeCamera();
    _initializeWebSocket();

    // Set up a timer to update recording time display
    _updateTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_isRecording) {
        setState(() {
          // Just to update the recording time display
        });
      }
    });
  }

  @override
  void dispose() {
    _stopStream();
    _stopIntervalRecording();
    _updateTimer?.cancel();
    _cameraController.dispose();
    _peerConnection?.dispose();
    _localStream?.dispose();
    _channel?.sink.close(status.normalClosure);
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint("No available cameras.");
        return;
      }

      // Use the back camera by default
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      _initializeControllerFuture = _cameraController.initialize();
      await _initializeControllerFuture;
      debugPrint("Camera initialized successfully.");
      setState(() {});
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  void _initializeWebSocket() {
    if (_wsInitialized) return;

    String sessionId = "OGxfLq7eQxECaC9p"; // Consider making this dynamic
    // Replace with your actual server IP/domain
    String serverUrl = "ws://127.0.0.1:8000/ws/live-stream/$sessionId/";

    try {
      _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
      _wsInitialized = true;

      // Single listener for the WebSocket stream
      _channel?.stream.listen(
        (message) {
          debugPrint("Received WebSocket message: $message");
          final data = jsonDecode(message);

          if (data["type"] == "otp") {
            setState(() {
              _otp = data["otp"];
            });
          } else if (data["type"] == "answer") {
            _handleAnswer(data);
          } else if (data["type"] == "candidate") {
            _handleIceCandidate(data);
          }
        },
        onError: (error) {
          debugPrint("WebSocket error: $error");
          _wsInitialized = false;
        },
        onDone: () {
          debugPrint("WebSocket connection closed.");
          _wsInitialized = false;
        },
      );

      // Request OTP after connection is established
      Future.delayed(const Duration(seconds: 1), () {
        _channel?.sink.add(jsonEncode({"type": "get_otp"}));
      });
    } catch (e) {
      debugPrint("Failed to connect to WebSocket: $e");
      _wsInitialized = false;
    }
  }

  Future<void> _handleAnswer(Map<String, dynamic> data) async {
    try {
      RTCSessionDescription answer = RTCSessionDescription(
        data["answer"]["sdp"],
        data["answer"]["type"],
      );
      await _peerConnection?.setRemoteDescription(answer);
      debugPrint("Remote description set successfully");
    } catch (e) {
      debugPrint("Error handling answer: $e");
    }
  }

  Future<void> _handleIceCandidate(Map<String, dynamic> data) async {
    try {
      RTCIceCandidate candidate = RTCIceCandidate(
        data["candidate"]["candidate"],
        data["candidate"]["sdpMid"],
        data["candidate"]["sdpMLineIndex"],
      );
      await _peerConnection?.addCandidate(candidate);
      debugPrint("Added ICE candidate");
    } catch (e) {
      debugPrint("Error handling ICE candidate: $e");
    }
  }

  Future<void> _initializeWebRTC() async {
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"urls": "stun:stun.l.google.com:19302"},
        // Add TURN server configuration if needed
      ],
      "sdpSemantics": "unified-plan",
    };

    try {
      _peerConnection = await createPeerConnection(configuration);
      debugPrint("PeerConnection created");

      // Get local media stream
      final Map<String, dynamic> mediaConstraints = {
        'audio': true,
        'video': {
          'facingMode': 'environment',
          // 'mandatory': {
          //   'minWidth': '640',
          //   'minHeight': '480',
          //   'minFrameRate': '30',
          // }
        }
      };

      _localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      debugPrint("Local stream obtained");

      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
        debugPrint("Added track: ${track.kind}");
      });

      // Handle ICE candidates
      _peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
        if (candidate == null) return;
        debugPrint("Sending ICE candidate");
        _channel?.sink.add(jsonEncode({
          "type": "candidate",
          "candidate": candidate.toMap(),
        }));
      };

      // Create and send offer
      RTCSessionDescription offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });

      await _peerConnection!.setLocalDescription(offer);
      debugPrint("Local description set, sending offer");

      _channel?.sink.add(jsonEncode({
        "type": "offer",
        "offer": offer.toMap(),
      }));
    } catch (e) {
      debugPrint("Error initializing WebRTC: $e");
    }
  }

  Future<void> _startStream() async {
    if (!_cameraController.value.isInitialized) {
      debugPrint("Camera not initialized yet.");
      return;
    }

    await _initializeWebRTC();
    setState(() {
      _isStreaming = true;
    });

    // Start interval recording after streaming begins
    _startIntervalRecording();
  }

  Future<void> _stopStream() async {
    _stopIntervalRecording();

    _localStream?.getTracks().forEach((track) {
      track.stop();
    });
    await _localStream?.dispose();
    await _peerConnection?.close();
    _localStream = null;
    _peerConnection = null;
    setState(() {
      _isStreaming = false;
    });
  }

  // Modified to match HTML implementation - 5 second intervals
  void _startIntervalRecording() {
    // Cancel any existing timer
    _recordingTimer?.cancel();

    // Start a timer to capture videos every 5 seconds
    _recordingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isStreaming && !_isRecording && !_isProcessing) {
        _captureVideoAndProcess();
      }
    });

    // Start the first capture immediately
    if (_isStreaming && !_isRecording && !_isProcessing) {
      _captureVideoAndProcess();
    }
  }

  void _stopIntervalRecording() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _isRecording = false;
  }

  Future<void> _captureVideoAndProcess() async {
    if (!_cameraController.value.isInitialized ||
        _isRecording ||
        _isProcessing) {
      return;
    }

    setState(() {
      _isRecording = true;
      _isProcessing = false;
      _recordingStartTime = DateTime.now();
    });

    try {
      // Start recording video
      debugPrint("Starting video recording");
      await _cameraController.startVideoRecording();

      // Record for 5 seconds (matching HTML)
      await Future.delayed(const Duration(seconds: 5));

      // Stop recording
      _videoFile = await _cameraController.stopVideoRecording();
      debugPrint("Video recording completed: ${_videoFile?.path}");

      // Process the video
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      await _sendVideoToServer(_videoFile!);
    } catch (e) {
      debugPrint("Error during video recording: $e");
    } finally {
      setState(() {
        _isRecording = false;
        _isProcessing = false;
      });
    }
  }

  // Updated to match HTML implementation
  Future<void> _sendVideoToServer(XFile videoFile) async {
    debugPrint("Sending video to server for processing");

    try {
      // Read the video file as bytes
      final Uint8List videoBytes = await videoFile.readAsBytes();

      // Create a multipart request
      var uri = Uri.parse(_videoProcessEndpoint);
      var request = http.MultipartRequest('POST', uri);

      // Add the video file - using 'video' field name to match HTML
      request.files.add(http.MultipartFile.fromBytes(
        'video', // Changed from 'file' to 'video' to match HTML
        videoBytes,
        filename: 'clip.webm', // Changed filename to match HTML
        contentType: MediaType('video', 'webm'),
      ));

      // Add source field to match HTML
      request.fields['source'] = 'livestream';

      // Send the request
      debugPrint("Sending HTTP request to: $_videoProcessEndpoint");
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint("HTTP response status: ${response.statusCode}");
      debugPrint("HTTP response body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          var result = jsonDecode(response.body);
          setState(() {
            _lastProcessingResult = result;
          });

          // Send analysis result through WebSocket as in HTML
          if (_wsInitialized &&
              result.containsKey('status') &&
              result.containsKey('predictions')) {
            _channel?.sink.add(jsonEncode({
              "type": "analysis_result",
              "data": result,
            }));
            debugPrint("Analysis result sent to server via WebSocket");
          }

          if (result['status'] == 'abnormal') {
            _handleAbnormalActivity(result);
          }
        } catch (e) {
          debugPrint("Error parsing response: $e");
        }
      } else {
        debugPrint("Server returned error code: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");
      }
    } catch (e) {
      debugPrint("HTTP request error: $e");
    }
  }

  void _handleAbnormalActivity(Map<String, dynamic> result) {
    // You can implement your own handling of abnormal activity here
    // For example, you might want to show a local notification or alert
    debugPrint(
        "ALERT: Abnormal activity detected with score: ${result['predictions'][0]['score']}");

    // You could also send this back through your WebSocket if needed
    if (_wsInitialized) {
      _channel?.sink.add(jsonEncode({
        "type": "abnormal_activity",
        "data": result,
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_cameraController);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "OTP: $_otp",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isRecording)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "Recording: ${_recordingStartTime != null ? DateTime.now().difference(_recordingStartTime!).inSeconds : 0}s",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      if (_isProcessing)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 8),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const Text(
                              "Processing...",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      if (_lastProcessingResult != null)
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color:
                                _lastProcessingResult!['status'] == 'abnormal'
                                    ? Colors.red.withOpacity(0.7)
                                    : Colors.green.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "Status: ${_lastProcessingResult!['status']} ${_lastProcessingResult!['predictions'] != null ? '(${(_lastProcessingResult!['predictions'][0]['score'] * 100).toStringAsFixed(1)}%)' : ''}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isStreaming) {
            _stopStream();
          } else {
            _startStream();
          }
        },
        backgroundColor: _isStreaming ? Colors.red : Colors.blue,
        child: Icon(_isStreaming ? Icons.stop : Icons.videocam),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
