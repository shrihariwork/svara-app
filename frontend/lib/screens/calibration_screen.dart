import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/api_client.dart';
import 'library_screen.dart'; // We will create this next

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({Key? key}) : super(key: key);

  @override
  _CalibrationScreenState createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordedFilePath;
  bool _isUploading = false;
  String _statusMessage = "Press the mic to start reading.";

  final String _calibrationText = "Vakratunda Mahakaya\nSuryakoti Samaprabha\nNirvighnam Kuru Me Deva\nSarva Karyeshu Sarvada";

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await Permission.microphone.request().isGranted) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/calibration_${DateTime.now().millisecondsSinceEpoch}.wav';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _statusMessage = "Recording... Read the text aloud.";
          _recordedFilePath = path;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error starting record: $e";
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordedFilePath = path;
        _statusMessage = "Recording saved. Tap Upload to calibrate.";
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Error stopping record: $e";
      });
    }
  }

  Future<void> _uploadCalibration() async {
    if (_recordedFilePath == null) return;

    setState(() {
      _isUploading = true;
      _statusMessage = "Uploading for calibration...";
    });

    String? referenceId = await ApiClient.calibrate(File(_recordedFilePath!));

    setState(() {
      _isUploading = false;
    });

    if (referenceId != null) {
      setState(() {
        _statusMessage = "Calibration successful!";
      });
      // Navigate to library
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LibraryScreen(referenceId: referenceId)),
      );
    } else {
      setState(() {
        _statusMessage = "Failed to calibrate. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Calibration')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Please read the following text clearly in a quiet environment:",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _calibrationText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            if (!_isUploading) ...[
              GestureDetector(
                onTap: _isRecording ? _stopRecording : _startRecording,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: _isRecording ? Colors.red : Colors.blue,
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_recordedFilePath != null && !_isRecording)
                ElevatedButton.icon(
                  onPressed: _uploadCalibration,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text("Upload & Calibrate"),
                ),
            ] else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
