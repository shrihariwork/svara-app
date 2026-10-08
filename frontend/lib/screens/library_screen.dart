import 'package:flutter/material.dart';
import 'playback_screen.dart';

class Shloka {
  final String id;
  final String title;
  final String description;

  Shloka(this.id, this.title, this.description);
}

final List<Shloka> mockLibrary = [
  Shloka("g3", "Gayatri Mantra", "Om Bhur Bhuva Swaha..."),
  Shloka("gita_2_47", "Bhagavad Gita 2.47", "Karmanye Vadhikaraste..."),
  Shloka("shanti", "Shanti Mantra", "Om Sahana Bhavatu..."),
];

class LibraryScreen extends StatelessWidget {
  final String referenceId;

  const LibraryScreen({Key? key, required this.referenceId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shloka Library')),
      body: ListView.builder(
        itemCount: mockLibrary.length,
        itemBuilder: (context, index) {
          final shloka = mockLibrary[index];
          return ListTile(
            title: Text(shloka.title),
            subtitle: Text(shloka.description),
            trailing: const Icon(Icons.play_arrow),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaybackScreen(
                    shloka: shloka,
                    referenceId: referenceId,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
