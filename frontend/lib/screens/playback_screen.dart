import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../services/api_client.dart';
import 'library_screen.dart';

class PlaybackScreen extends StatefulWidget {
  final Shloka shloka;
  final String referenceId;

  const PlaybackScreen({Key? key, required this.shloka, required this.referenceId}) : super(key: key);

  @override
  _PlaybackScreenState createState() => _PlaybackScreenState();
}

class _PlaybackScreenState extends State<PlaybackScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isLoading = true;
  bool _hasError = false;
  String _status = "Synthesizing voice... this may take a moment on the GPU server.";

  @override
  void initState() {
    super.initState();
    _synthesizeAndPlay();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _synthesizeAndPlay() async {
    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/synth_${widget.shloka.id}.wav';

    final path = await ApiClient.synthesize(widget.shloka.id, widget.referenceId, savePath);

    if (path != null) {
      setState(() {
        _status = "Playing...";
        _isLoading = false;
      });
      await _player.setFilePath(path);
      _player.play();
    } else {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _status = "Failed to synthesize.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.shloka.title)),
      body: Center(
        child: _isLoading 
          ? Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(_status, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                ],
              ),
            )
          : _hasError
            ? Text(_status, style: const TextStyle(color: Colors.red))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.music_note, size: 100, color: Colors.blue),
                  const SizedBox(height: 20),
                  Text(widget.shloka.description, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 40),
                  IconButton(
                    icon: StreamBuilder<PlayerState>(
                      stream: _player.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final processingState = playerState?.processingState;
                        final playing = playerState?.playing;
                        if (processingState == ProcessingState.loading ||
                            processingState == ProcessingState.buffering) {
                          return const CircularProgressIndicator();
                        } else if (playing != true) {
                          return const Icon(Icons.play_arrow, size: 64);
                        } else if (processingState != ProcessingState.completed) {
                          return const Icon(Icons.pause, size: 64);
                        } else {
                          return const Icon(Icons.replay, size: 64);
                        }
                      },
                    ),
                    onPressed: () {
                      if (_player.playing) {
                        _player.pause();
                      } else {
                        if (_player.processingState == ProcessingState.completed) {
                          _player.seek(Duration.zero);
                        }
                        _player.play();
                      }
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
